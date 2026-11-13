// HTTP(S) client and web-text helpers (std.http).
//
// A request is built on a handle (method, URL, headers, body, timeout) and sent; each send runs on a
// worker OS thread, and the caller waits cooperatively, so other microthreads of the calling thread
// keep running while a request is in flight. Backends: WinHTTP on Windows (system TLS and proxy
// settings), libcurl elsewhere (loaded at run time, so the runtime has no link-time dependency on it).
//
// csec_http_send waits for the whole response. csec_http_open returns as soon as the status and
// headers are in, and the body can then be consumed incrementally: line by line
// (csec_http_next_line), or as Server-Sent Events (csec_http_next_event), which is how streaming
// chat-completion APIs deliver tokens. A transport failure gives a response with status 0 and the
// reason in csec_http_error.
//
// The helpers at the end percent-encode URLs, resolve relative links, and turn HTML into plain text.

#include <atomic>
#include <cctype>
#include <cstdio>
#include <memory>
#include <mutex>
#include <string>
#include <thread>
#include <utility>
#include <vector>

#ifdef _WIN32
#include <winhttp.h>
#ifndef WINHTTP_ACCESS_TYPE_AUTOMATIC_PROXY
#define WINHTTP_ACCESS_TYPE_AUTOMATIC_PROXY 4
#endif
#ifndef WINHTTP_OPTION_DECOMPRESSION
#define WINHTTP_OPTION_DECOMPRESSION 118
#endif
#ifndef WINHTTP_DECOMPRESSION_FLAG_ALL
#define WINHTTP_DECOMPRESSION_FLAG_ALL 3
#endif
#else
#include <dlfcn.h>
#endif

namespace csec_http {

const char* kUserAgent = "tessera-http/1.0";

struct Request {
    std::string method = "GET";
    std::string url;
    std::string body;
    bool hasBody = false;
    std::vector<std::pair<std::string, std::string>> headers;
    long long timeoutMs = 120000;
};

struct Response {
    std::mutex mutex;
    int status = 0;
    std::string headers;  // header lines of the final response: "Name: value\r\n"
    std::string data;     // body bytes received and not yet consumed
    long long received = 0;
    bool headersReady = false;
    bool done = false;
    std::string error;
    std::atomic<bool> cancelled{false};
    // Read state, used only by the calling thread.
    std::string line;
    std::string eventName;
    std::string eventData;
    std::string eventId;
};

csec_threads::HandleTable<Request>& requests() {
    static auto* table = new csec_threads::HandleTable<Request>();
    return *table;
}
csec_threads::HandleTable<Response>& responses() {
    static auto* table = new csec_threads::HandleTable<Response>();
    return *table;
}

std::mutex& errorMutex() {
    static std::mutex mutex;
    return mutex;
}
std::string& lastError() {
    static std::string error;
    return error;
}
void setError(const std::string& message) {
    std::lock_guard<std::mutex> lock(errorMutex());
    lastError() = message;
}

char* owned(const std::string& text) {
    return csec_microthread::ownedText(text);
}

bool equalsIgnoreCase(const std::string& a, const std::string& b) {
    if (a.size() != b.size()) return false;
    for (size_t i = 0; i < a.size(); ++i) {
        if (std::tolower(static_cast<unsigned char>(a[i])) != std::tolower(static_cast<unsigned char>(b[i]))) return false;
    }
    return true;
}

std::string trim(const std::string& text) {
    size_t start = 0;
    size_t end = text.size();
    while (start < end && std::isspace(static_cast<unsigned char>(text[start]))) ++start;
    while (end > start && std::isspace(static_cast<unsigned char>(text[end - 1]))) --end;
    return text.substr(start, end - start);
}

bool hasHeader(const Request& request, const char* name) {
    for (const auto& header : request.headers) {
        if (equalsIgnoreCase(header.first, name)) return true;
    }
    return false;
}

void append(Response& response, const char* bytes, size_t size) {
    std::lock_guard<std::mutex> lock(response.mutex);
    response.data.append(bytes, size);
    response.received += static_cast<long long>(size);
    response.headersReady = true;
}

void finish(Response& response, const std::string& error) {
    std::lock_guard<std::mutex> lock(response.mutex);
    if (!error.empty() && response.error.empty()) response.error = error;
    response.headersReady = true;
    response.done = true;
}

#ifdef _WIN32

std::wstring widen(const std::string& text) {
    if (text.empty()) return std::wstring();
    const int count = MultiByteToWideChar(CP_UTF8, 0, text.data(), static_cast<int>(text.size()), nullptr, 0);
    std::wstring out(static_cast<size_t>(count), L'\0');
    MultiByteToWideChar(CP_UTF8, 0, text.data(), static_cast<int>(text.size()), &out[0], count);
    return out;
}

std::string narrow(const wchar_t* text, size_t size) {
    if (size == 0) return std::string();
    const int count = WideCharToMultiByte(CP_UTF8, 0, text, static_cast<int>(size), nullptr, 0, nullptr, nullptr);
    std::string out(static_cast<size_t>(count), '\0');
    WideCharToMultiByte(CP_UTF8, 0, text, static_cast<int>(size), &out[0], count, nullptr, nullptr);
    return out;
}

std::string systemError(const char* what) {
    const DWORD code = GetLastError();
    wchar_t* message = nullptr;
    const DWORD flags = FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS |
                        FORMAT_MESSAGE_FROM_HMODULE;
    const DWORD length = FormatMessageW(flags, GetModuleHandleW(L"winhttp.dll"), code, 0,
                                        reinterpret_cast<wchar_t*>(&message), 0, nullptr);
    std::string text = std::string(what) + " failed (error " + std::to_string(code) + ")";
    if (length && message) text += ": " + trim(narrow(message, length));
    if (message) LocalFree(message);
    return text;
}

struct InternetHandle {
    HINTERNET handle = nullptr;
    explicit InternetHandle(HINTERNET h) : handle(h) {}
    ~InternetHandle() {
        if (handle) WinHttpCloseHandle(handle);
    }
    InternetHandle(const InternetHandle&) = delete;
    InternetHandle& operator=(const InternetHandle&) = delete;
};

std::string perform(const Request& request, Response& response) {
    const std::wstring url = widen(request.url);
    URL_COMPONENTS parts{};
    parts.dwStructSize = sizeof(parts);
    parts.dwSchemeLength = static_cast<DWORD>(-1);
    parts.dwHostNameLength = static_cast<DWORD>(-1);
    parts.dwUrlPathLength = static_cast<DWORD>(-1);
    parts.dwExtraInfoLength = static_cast<DWORD>(-1);
    if (!WinHttpCrackUrl(url.c_str(), static_cast<DWORD>(url.size()), 0, &parts)) {
        return "invalid URL '" + request.url + "'";
    }
    if (parts.nScheme != INTERNET_SCHEME_HTTP && parts.nScheme != INTERNET_SCHEME_HTTPS) {
        return "only http and https URLs are supported";
    }
    const std::wstring host(parts.lpszHostName, parts.dwHostNameLength);
    std::wstring path(parts.lpszUrlPath ? parts.lpszUrlPath : L"", parts.dwUrlPathLength);
    if (parts.lpszExtraInfo) path.append(parts.lpszExtraInfo, parts.dwExtraInfoLength);
    if (path.empty()) path = L"/";

    const std::wstring agent = widen(kUserAgent);
    HINTERNET rawSession = WinHttpOpen(agent.c_str(), WINHTTP_ACCESS_TYPE_AUTOMATIC_PROXY, WINHTTP_NO_PROXY_NAME,
                                       WINHTTP_NO_PROXY_BYPASS, 0);
    if (!rawSession) {
        rawSession = WinHttpOpen(agent.c_str(), WINHTTP_ACCESS_TYPE_DEFAULT_PROXY, WINHTTP_NO_PROXY_NAME,
                                 WINHTTP_NO_PROXY_BYPASS, 0);
    }
    InternetHandle session(rawSession);
    if (!session.handle) return systemError("WinHttpOpen");
    const int timeout = request.timeoutMs > 0x7fffffffLL ? 0x7fffffff : static_cast<int>(request.timeoutMs);
    if (request.timeoutMs > 0) WinHttpSetTimeouts(session.handle, timeout, timeout, timeout, timeout);
    DWORD decompression = WINHTTP_DECOMPRESSION_FLAG_ALL;
    WinHttpSetOption(session.handle, WINHTTP_OPTION_DECOMPRESSION, &decompression, sizeof(decompression));

    InternetHandle connection(WinHttpConnect(session.handle, host.c_str(), parts.nPort, 0));
    if (!connection.handle) return systemError("WinHttpConnect");

    const std::wstring method = widen(request.method);
    const DWORD flags = parts.nScheme == INTERNET_SCHEME_HTTPS ? WINHTTP_FLAG_SECURE : 0;
    InternetHandle handle(WinHttpOpenRequest(connection.handle, method.c_str(), path.c_str(), nullptr,
                                             WINHTTP_NO_REFERER, WINHTTP_DEFAULT_ACCEPT_TYPES, flags));
    if (!handle.handle) return systemError("WinHttpOpenRequest");

    std::string headerText;
    for (const auto& header : request.headers) headerText += header.first + ": " + header.second + "\r\n";
    const std::wstring headers = widen(headerText);
    const DWORD bodySize = static_cast<DWORD>(request.body.size());
    if (!WinHttpSendRequest(handle.handle, headers.empty() ? WINHTTP_NO_ADDITIONAL_HEADERS : headers.c_str(),
                            headers.empty() ? 0 : static_cast<DWORD>(headers.size()),
                            bodySize ? const_cast<char*>(request.body.data()) : WINHTTP_NO_REQUEST_DATA, bodySize,
                            bodySize, 0)) {
        return systemError("sending the request");
    }
    if (!WinHttpReceiveResponse(handle.handle, nullptr)) return systemError("receiving the response");

    DWORD status = 0;
    DWORD size = sizeof(status);
    WinHttpQueryHeaders(handle.handle, WINHTTP_QUERY_STATUS_CODE | WINHTTP_QUERY_FLAG_NUMBER,
                        WINHTTP_HEADER_NAME_BY_INDEX, &status, &size, WINHTTP_NO_HEADER_INDEX);
    size = 0;
    WinHttpQueryHeaders(handle.handle, WINHTTP_QUERY_RAW_HEADERS_CRLF, WINHTTP_HEADER_NAME_BY_INDEX, nullptr,
                        &size, WINHTTP_NO_HEADER_INDEX);
    std::string rawHeaders;
    if (size > 0) {
        std::wstring buffer(size / sizeof(wchar_t) + 1, L'\0');
        if (WinHttpQueryHeaders(handle.handle, WINHTTP_QUERY_RAW_HEADERS_CRLF, WINHTTP_HEADER_NAME_BY_INDEX,
                                &buffer[0], &size, WINHTTP_NO_HEADER_INDEX)) {
            rawHeaders = narrow(buffer.c_str(), size / sizeof(wchar_t));
        }
    }
    // Drop the status line; keep "Name: value" lines.
    const size_t firstLine = rawHeaders.find("\r\n");
    rawHeaders = firstLine == std::string::npos ? std::string() : rawHeaders.substr(firstLine + 2);
    {
        std::lock_guard<std::mutex> lock(response.mutex);
        response.status = static_cast<int>(status);
        response.headers = rawHeaders;
        response.headersReady = true;
    }

    std::vector<char> buffer(64 * 1024);
    for (;;) {
        if (response.cancelled.load()) return "cancelled";
        DWORD available = 0;
        if (!WinHttpQueryDataAvailable(handle.handle, &available)) return systemError("reading the response");
        if (available == 0) break;
        while (available > 0) {
            const DWORD want = available < buffer.size() ? available : static_cast<DWORD>(buffer.size());
            DWORD read = 0;
            if (!WinHttpReadData(handle.handle, buffer.data(), want, &read)) return systemError("reading the response");
            if (read == 0) break;
            append(response, buffer.data(), read);
            available -= read;
        }
    }
    return std::string();
}

#else  // libcurl

struct Curl {
    bool loaded = false;
    std::string error;
    void* (*easy_init)() = nullptr;
    int (*easy_setopt)(void*, int, ...) = nullptr;
    int (*easy_perform)(void*) = nullptr;
    void (*easy_cleanup)(void*) = nullptr;
    const char* (*easy_strerror)(int) = nullptr;
    void* (*slist_append)(void*, const char*) = nullptr;
    void (*slist_free_all)(void*) = nullptr;
    int (*global_init)(long) = nullptr;
};

// Option numbers from curl.h (stable ABI).
enum : int {
    kOptWriteData = 10001,
    kOptUrl = 10002,
    kOptPostFields = 10015,
    kOptUserAgent = 10018,
    kOptHttpHeader = 10023,
    kOptHeaderData = 10029,
    kOptCustomRequest = 10036,
    kOptAcceptEncoding = 10102,
    kOptWriteFunction = 20011,
    kOptHeaderFunction = 20079,
    kOptLowSpeedLimit = 19,
    kOptLowSpeedTime = 20,
    kOptNoBody = 44,
    kOptFollowLocation = 52,
    kOptNoSignal = 99,
    kOptConnectTimeoutMs = 156,
    kOptPostFieldSizeLarge = 30120,
};

Curl& curl() {
    static Curl api;
    static std::once_flag once;
    std::call_once(once, [] {
        const char* names[] = {"libcurl.so.4", "libcurl.so", "libcurl.4.dylib", "libcurl.dylib",
                               "/usr/lib/libcurl.4.dylib", "libcurl-gnutls.so.4"};
        void* library = nullptr;
        for (const char* name : names) {
            library = dlopen(name, RTLD_NOW | RTLD_LOCAL);
            if (library) break;
        }
        if (!library) {
            api.error = "libcurl was not found; install libcurl to use std.http";
            return;
        }
        api.easy_init = reinterpret_cast<void* (*)()>(dlsym(library, "curl_easy_init"));
        api.easy_setopt = reinterpret_cast<int (*)(void*, int, ...)>(dlsym(library, "curl_easy_setopt"));
        api.easy_perform = reinterpret_cast<int (*)(void*)>(dlsym(library, "curl_easy_perform"));
        api.easy_cleanup = reinterpret_cast<void (*)(void*)>(dlsym(library, "curl_easy_cleanup"));
        api.easy_strerror = reinterpret_cast<const char* (*)(int)>(dlsym(library, "curl_easy_strerror"));
        api.slist_append = reinterpret_cast<void* (*)(void*, const char*)>(dlsym(library, "curl_slist_append"));
        api.slist_free_all = reinterpret_cast<void (*)(void*)>(dlsym(library, "curl_slist_free_all"));
        api.global_init = reinterpret_cast<int (*)(long)>(dlsym(library, "curl_global_init"));
        if (!api.easy_init || !api.easy_setopt || !api.easy_perform || !api.easy_cleanup || !api.easy_strerror ||
            !api.slist_append || !api.slist_free_all || !api.global_init) {
            api.error = "the libcurl found lacks required functions";
            return;
        }
        api.global_init(3);  // CURL_GLOBAL_ALL
        api.loaded = true;
    });
    return api;
}

struct Transfer {
    Response* response;
    bool redirectPending = false;
};

size_t onBody(char* bytes, size_t size, size_t count, void* user) {
    auto* transfer = static_cast<Transfer*>(user);
    if (transfer->response->cancelled.load()) return 0;
    append(*transfer->response, bytes, size * count);
    return size * count;
}

size_t onHeader(char* bytes, size_t size, size_t count, void* user) {
    auto* transfer = static_cast<Transfer*>(user);
    Response& response = *transfer->response;
    const std::string line(bytes, size * count);
    std::lock_guard<std::mutex> lock(response.mutex);
    if (line.compare(0, 5, "HTTP/") == 0) {
        // A new response (after a redirect or a 100 Continue): start over.
        const size_t space = line.find(' ');
        response.status = space == std::string::npos ? 0 : std::atoi(line.c_str() + space + 1);
        response.headers.clear();
        transfer->redirectPending = false;
    } else if (line == "\r\n" || line == "\n") {
        const bool interim = response.status >= 100 && response.status < 200;
        if (!interim && !transfer->redirectPending) response.headersReady = true;
    } else {
        response.headers += trim(line) + "\r\n";
        const size_t colon = line.find(':');
        if (colon != std::string::npos && equalsIgnoreCase(line.substr(0, colon), "location") &&
            response.status >= 300 && response.status < 400) {
            transfer->redirectPending = true;
        }
    }
    return size * count;
}

std::string perform(const Request& request, Response& response) {
    Curl& api = curl();
    if (!api.loaded) return api.error;
    void* easy = api.easy_init();
    if (!easy) return "curl_easy_init failed";
    Transfer transfer{&response};
    void* headerList = nullptr;
    for (const auto& header : request.headers) {
        headerList = api.slist_append(headerList, (header.first + ": " + header.second).c_str());
    }
    headerList = api.slist_append(headerList, "Expect:");
    api.easy_setopt(easy, kOptUrl, request.url.c_str());
    api.easy_setopt(easy, kOptNoSignal, 1L);
    api.easy_setopt(easy, kOptFollowLocation, 1L);
    api.easy_setopt(easy, kOptAcceptEncoding, "");
    if (!hasHeader(request, "User-Agent")) api.easy_setopt(easy, kOptUserAgent, kUserAgent);
    api.easy_setopt(easy, kOptHttpHeader, headerList);
    api.easy_setopt(easy, kOptWriteFunction, &onBody);
    api.easy_setopt(easy, kOptWriteData, &transfer);
    api.easy_setopt(easy, kOptHeaderFunction, &onHeader);
    api.easy_setopt(easy, kOptHeaderData, &transfer);
    if (request.timeoutMs > 0) {
        api.easy_setopt(easy, kOptConnectTimeoutMs, static_cast<long>(request.timeoutMs));
        long seconds = static_cast<long>((request.timeoutMs + 999) / 1000);
        api.easy_setopt(easy, kOptLowSpeedLimit, 1L);
        api.easy_setopt(easy, kOptLowSpeedTime, seconds);
    }
    if (request.method == "HEAD") {
        api.easy_setopt(easy, kOptNoBody, 1L);
    } else if (request.method != "GET" || request.hasBody) {
        api.easy_setopt(easy, kOptCustomRequest, request.method.c_str());
    }
    if (request.hasBody) {
        api.easy_setopt(easy, kOptPostFieldSizeLarge, static_cast<long long>(request.body.size()));
        api.easy_setopt(easy, kOptPostFields, request.body.c_str());
    }
    const int code = api.easy_perform(easy);
    api.easy_cleanup(easy);
    api.slist_free_all(headerList);
    if (code != 0) {
        if (response.cancelled.load()) return "cancelled";
        return std::string("request failed: ") + api.easy_strerror(code);
    }
    return std::string();
}

#endif

std::shared_ptr<Response> start(const Request& request) {
    auto response = std::make_shared<Response>();
    std::thread([request, response] {
        std::string error;
        try {
            error = perform(request, *response);
        } catch (const std::exception& e) {
            error = e.what();
        }
        finish(*response, error);
    }).detach();
    return response;
}

template <typename Ready>
void wait(Response& response, Ready ready) {
    csec_ipc::csecCooperativeWait([&] {
        std::lock_guard<std::mutex> lock(response.mutex);
        return ready();
    }, -1);
}

void waitDone(Response& response) {
    wait(response, [&] { return response.done; });
}

// Take the next body line (without "\n" or "\r\n"); false at the end of the body.
bool nextLine(Response& response) {
    wait(response, [&] { return response.done || response.data.find('\n') != std::string::npos; });
    std::lock_guard<std::mutex> lock(response.mutex);
    const size_t newline = response.data.find('\n');
    if (newline == std::string::npos) {
        if (response.data.empty()) {
            response.line.clear();
            return false;
        }
        response.line.swap(response.data);
        response.data.clear();
    } else {
        response.line.assign(response.data, 0, newline);
        response.data.erase(0, newline + 1);
    }
    if (!response.line.empty() && response.line.back() == '\r') response.line.pop_back();
    return true;
}

// Server-Sent Events: read lines up to the next blank line and collect the event's fields.
bool nextEvent(Response& response) {
    response.eventName.clear();
    response.eventData.clear();
    bool hasData = false;
    for (;;) {
        if (!nextLine(response)) return hasData;
        const std::string& line = response.line;
        if (line.empty()) {
            if (hasData) return true;
            continue;
        }
        if (line[0] == ':') continue;  // comment / keep-alive
        const size_t colon = line.find(':');
        const std::string field = colon == std::string::npos ? line : line.substr(0, colon);
        std::string value = colon == std::string::npos ? std::string() : line.substr(colon + 1);
        if (!value.empty() && value[0] == ' ') value.erase(0, 1);
        if (field == "data") {
            if (hasData) response.eventData += '\n';
            response.eventData += value;
            hasData = true;
        } else if (field == "event") {
            response.eventName = value;
        } else if (field == "id") {
            response.eventId = value;
        }
    }
}

// ---- URLs and HTML ----

std::string urlEncode(const std::string& text) {
    static const char* hex = "0123456789ABCDEF";
    std::string out;
    for (unsigned char c : text) {
        if (std::isalnum(c) || c == '-' || c == '_' || c == '.' || c == '~') {
            out += static_cast<char>(c);
        } else {
            out += '%';
            out += hex[c >> 4];
            out += hex[c & 15];
        }
    }
    return out;
}

int hexValue(char c) {
    if (c >= '0' && c <= '9') return c - '0';
    if (c >= 'a' && c <= 'f') return c - 'a' + 10;
    if (c >= 'A' && c <= 'F') return c - 'A' + 10;
    return -1;
}

std::string urlDecode(const std::string& text) {
    std::string out;
    for (size_t i = 0; i < text.size(); ++i) {
        if (text[i] == '%' && i + 2 < text.size() && hexValue(text[i + 1]) >= 0 && hexValue(text[i + 2]) >= 0) {
            out += static_cast<char>(hexValue(text[i + 1]) * 16 + hexValue(text[i + 2]));
            i += 2;
        } else if (text[i] == '+') {
            out += ' ';
        } else {
            out += text[i];
        }
    }
    return out;
}

// Resolve `ref` against the absolute URL `base` (enough for links in web pages).
std::string resolveUrl(const std::string& base, const std::string& ref) {
    const std::string link = trim(ref);
    const size_t colon = link.find(':');
    const size_t firstSlash = link.find('/');
    if (colon != std::string::npos && (firstSlash == std::string::npos || colon < firstSlash)) return link;  // has a scheme
    const size_t schemeEnd = base.find("://");
    if (schemeEnd == std::string::npos) return link;
    const std::string scheme = base.substr(0, schemeEnd);
    const size_t hostEnd = base.find_first_of("/?#", schemeEnd + 3);
    const std::string origin = base.substr(0, hostEnd);
    if (link.compare(0, 2, "//") == 0) return scheme + ":" + link;
    if (link.empty()) return base;
    if (link[0] == '/') return origin + link;
    std::string basePath = hostEnd == std::string::npos ? "/" : base.substr(hostEnd);
    const size_t cut = basePath.find_first_of("?#");
    if (link[0] == '#' || link[0] == '?') {
        return origin + (cut == std::string::npos ? basePath : basePath.substr(0, cut)) + link;
    }
    if (cut != std::string::npos) basePath.erase(cut);
    basePath.erase(basePath.rfind('/') + 1);
    // Normalise "." and ".." segments.
    std::vector<std::string> segments;
    const std::string joined = basePath + link;
    size_t pos = 1;
    std::string tail;
    const size_t query = joined.find_first_of("?#");
    const std::string pathPart = query == std::string::npos ? joined : joined.substr(0, query);
    if (query != std::string::npos) tail = joined.substr(query);
    while (pos <= pathPart.size()) {
        size_t next = pathPart.find('/', pos);
        if (next == std::string::npos) next = pathPart.size();
        const std::string segment = pathPart.substr(pos, next - pos);
        if (segment == "..") {
            if (!segments.empty()) segments.pop_back();
            if (next == pathPart.size()) segments.push_back("");
        } else if (segment == ".") {
            if (next == pathPart.size()) segments.push_back("");
        } else {
            segments.push_back(segment);
        }
        pos = next + 1;
    }
    std::string path;
    for (const auto& segment : segments) path += "/" + segment;
    if (path.empty()) path = "/";
    return origin + path + tail;
}

void appendCodePoint(std::string& out, unsigned code) {
    if (code == 0 || code > 0x10FFFF || (code >= 0xD800 && code <= 0xDFFF)) code = 0xFFFD;
    if (code < 0x80) {
        out += static_cast<char>(code);
    } else if (code < 0x800) {
        out += static_cast<char>(0xC0 | (code >> 6));
        out += static_cast<char>(0x80 | (code & 0x3F));
    } else if (code < 0x10000) {
        out += static_cast<char>(0xE0 | (code >> 12));
        out += static_cast<char>(0x80 | ((code >> 6) & 0x3F));
        out += static_cast<char>(0x80 | (code & 0x3F));
    } else {
        out += static_cast<char>(0xF0 | (code >> 18));
        out += static_cast<char>(0x80 | ((code >> 12) & 0x3F));
        out += static_cast<char>(0x80 | ((code >> 6) & 0x3F));
        out += static_cast<char>(0x80 | (code & 0x3F));
    }
}

std::string decodeEntities(const std::string& text) {
    static const struct {
        const char* name;
        unsigned code;
    } named[] = {{"amp", '&'},     {"lt", '<'},      {"gt", '>'},      {"quot", '"'},    {"apos", '\''},
                 {"nbsp", 0xA0},   {"copy", 0xA9},   {"reg", 0xAE},    {"hellip", 0x2026}, {"mdash", 0x2014},
                 {"ndash", 0x2013}, {"lsquo", 0x2018}, {"rsquo", 0x2019}, {"ldquo", 0x201C}, {"rdquo", 0x201D},
                 {"middot", 0xB7}, {"bull", 0x2022}, {"trade", 0x2122}, {"times", 0xD7},  {"euro", 0x20AC}};
    std::string out;
    for (size_t i = 0; i < text.size(); ++i) {
        if (text[i] != '&') {
            out += text[i];
            continue;
        }
        const size_t semi = text.find(';', i + 1);
        if (semi == std::string::npos || semi - i > 12) {
            out += '&';
            continue;
        }
        const std::string entity = text.substr(i + 1, semi - i - 1);
        bool decoded = false;
        if (!entity.empty() && entity[0] == '#') {
            const bool hexForm = entity.size() > 1 && (entity[1] == 'x' || entity[1] == 'X');
            const std::string digits = entity.substr(hexForm ? 2 : 1);
            char* stop = nullptr;
            const unsigned long code = std::strtoul(digits.c_str(), &stop, hexForm ? 16 : 10);
            if (!digits.empty() && stop && *stop == '\0') {
                appendCodePoint(out, code == 0xA0 ? ' ' : static_cast<unsigned>(code));
                decoded = true;
            }
        } else {
            for (const auto& item : named) {
                if (entity == item.name) {
                    appendCodePoint(out, item.code == 0xA0 ? ' ' : item.code);
                    decoded = true;
                    break;
                }
            }
        }
        if (decoded) {
            i = semi;
        } else {
            out += '&';
        }
    }
    return out;
}

std::string lower(std::string text) {
    for (auto& c : text) c = static_cast<char>(std::tolower(static_cast<unsigned char>(c)));
    return text;
}

// Name of the tag starting at html[pos] == '<' ("/p" for a closing tag), lowercase.
std::string tagName(const std::string& html, size_t pos) {
    size_t i = pos + 1;
    std::string name;
    if (i < html.size() && html[i] == '/') {
        name += '/';
        ++i;
    }
    while (i < html.size() && (std::isalnum(static_cast<unsigned char>(html[i])) || html[i] == '-' || html[i] == '!')) {
        name += static_cast<char>(std::tolower(static_cast<unsigned char>(html[i])));
        ++i;
    }
    return name;
}

// Value of attribute `attr` in the tag text `tag` ("<a href=...>"), or "" (and found = false).
std::string attribute(const std::string& tag, const char* attr, bool& found) {
    const std::string lowered = lower(tag);
    const std::string key = attr;
    size_t pos = 0;
    found = false;
    while ((pos = lowered.find(key, pos)) != std::string::npos) {
        const bool boundary = pos > 0 && (std::isspace(static_cast<unsigned char>(lowered[pos - 1])) || lowered[pos - 1] == '<');
        size_t i = pos + key.size();
        while (i < tag.size() && std::isspace(static_cast<unsigned char>(tag[i]))) ++i;
        if (!boundary || i >= tag.size() || tag[i] != '=') {
            pos += key.size();
            continue;
        }
        ++i;
        while (i < tag.size() && std::isspace(static_cast<unsigned char>(tag[i]))) ++i;
        std::string value;
        if (i < tag.size() && (tag[i] == '"' || tag[i] == '\'')) {
            const char q = tag[i++];
            const size_t end = tag.find(q, i);
            value = tag.substr(i, end == std::string::npos ? std::string::npos : end - i);
        } else {
            while (i < tag.size() && !std::isspace(static_cast<unsigned char>(tag[i])) && tag[i] != '>') value += tag[i++];
        }
        found = true;
        return decodeEntities(value);
    }
    return std::string();
}

// Line-break (1) and paragraph-break (2) elements; 0 for inline ones.
int breakKind(const std::string& name) {
    static const char* paragraphs[] = {"p",    "h1",      "h2",     "h3",     "h4",   "h5",     "h6",
                                       "ul",   "ol",      "dl",     "table",  "pre",  "blockquote", "hr",
                                       "section", "article", "header", "footer", "nav", "aside", "main",
                                       "figure", "form"};
    static const char* lines[] = {"br", "div", "li", "tr", "dt", "dd", "figcaption", "title", "caption", "address"};
    const std::string bare = !name.empty() && name[0] == '/' ? name.substr(1) : name;
    for (const char* tag : paragraphs) {
        if (bare == tag) return 2;
    }
    for (const char* tag : lines) {
        if (bare == tag) return 1;
    }
    return 0;
}

std::string htmlToText(const std::string& html) {
    std::string raw;
    raw.reserve(html.size() / 2);
    size_t i = 0;
    while (i < html.size()) {
        if (html[i] != '<') {
            raw += html[i++];
            continue;
        }
        if (html.compare(i, 4, "<!--") == 0) {
            const size_t end = html.find("-->", i + 4);
            i = end == std::string::npos ? html.size() : end + 3;
            continue;
        }
        const std::string name = tagName(html, i);
        const size_t close = html.find('>', i);
        if (name.empty() || close == std::string::npos) {
            raw += html[i++];
            continue;
        }
        if (name == "script" || name == "style" || name == "noscript" || name == "template" || name == "svg" ||
            name == "head") {
            const std::string endTag = "</" + name;
            size_t end = close + 1;
            for (;;) {
                end = html.find('<', end);
                if (end == std::string::npos || lower(html.substr(end, endTag.size())) == endTag) break;
                ++end;
            }
            if (end == std::string::npos) {
                i = html.size();
            } else {
                const size_t endClose = html.find('>', end);
                i = endClose == std::string::npos ? html.size() : endClose + 1;
            }
            continue;
        }
        if (name == "li") {
            raw += "\x01- ";
        } else if (name == "td" || name == "th") {
            raw += ' ';
        } else if (name != "/li") {
            const int kind = breakKind(name);
            if (kind == 1) raw += '\x01';
            if (kind == 2) raw += '\x02';
        }
        i = close + 1;
    }
    const std::string text = decodeEntities(raw);
    // Collapse whitespace. Source line breaks are spaces (as in a browser); \x01 marks a line break
    // and \x02 a paragraph break (one blank line), from the tags above.
    std::string out;
    std::string lineText;
    bool paragraph = false;
    auto flush = [&]() {
        const std::string trimmed = trim(lineText);
        lineText.clear();
        if (trimmed.empty()) return;
        if (!out.empty()) out += paragraph ? "\n\n" : "\n";
        paragraph = false;
        out += trimmed;
    };
    bool lastSpace = false;
    for (char c : text) {
        if (c == '\x01' || c == '\x02') {
            flush();
            if (c == '\x02' && !out.empty()) paragraph = true;
            lastSpace = false;
        } else if (c == ' ' || c == '\t' || c == '\r' || c == '\n' || c == '\f' || c == '\v') {
            if (!lastSpace) lineText += ' ';
            lastSpace = true;
        } else {
            lineText += c;
            lastSpace = false;
        }
    }
    flush();
    return out;
}

std::string htmlTitle(const std::string& html) {
    const std::string lowered = lower(html);
    const size_t open = lowered.find("<title");
    if (open == std::string::npos) return std::string();
    const size_t start = lowered.find('>', open);
    if (start == std::string::npos) return std::string();
    const size_t end = lowered.find("</title", start);
    std::string title = html.substr(start + 1, end == std::string::npos ? std::string::npos : end - start - 1);
    std::string collapsed;
    bool lastSpace = false;
    for (char c : decodeEntities(title)) {
        const bool space = std::isspace(static_cast<unsigned char>(c)) != 0;
        if (space && lastSpace) continue;
        collapsed += space ? ' ' : c;
        lastSpace = space;
    }
    return trim(collapsed);
}

// Absolute http(s) links of <a href> tags, one per line, without duplicates.
std::string htmlLinks(const std::string& html, const std::string& base) {
    std::string out;
    std::vector<std::string> seen;
    size_t pos = 0;
    while ((pos = html.find('<', pos)) != std::string::npos) {
        const std::string name = tagName(html, pos);
        const size_t close = html.find('>', pos);
        if (close == std::string::npos) break;
        if (name == "a") {
            bool found = false;
            const std::string href = attribute(html.substr(pos, close - pos + 1), "href", found);
            if (found && !href.empty() && href[0] != '#') {
                std::string link = base.empty() ? trim(href) : resolveUrl(base, href);
                const size_t hash = link.find('#');
                if (hash != std::string::npos) link.erase(hash);
                const std::string scheme = lower(link.substr(0, 8));
                if ((scheme.compare(0, 7, "http://") == 0 || scheme.compare(0, 8, "https://") == 0)) {
                    bool duplicate = false;
                    for (const auto& item : seen) {
                        if (item == link) {
                            duplicate = true;
                            break;
                        }
                    }
                    if (!duplicate) {
                        seen.push_back(link);
                        out += link + "\n";
                    }
                }
            }
        }
        pos = close + 1;
    }
    return out;
}

} // namespace csec_http

extern "C" {

long long csec_http_request_new(const char* method, const char* url) {
    auto request = std::make_shared<csec_http::Request>();
    request->method = method && *method ? method : "GET";
    for (auto& c : request->method) c = static_cast<char>(std::toupper(static_cast<unsigned char>(c)));
    request->url = url ? url : "";
    return csec_http::requests().add(request);
}

int csec_http_request_header(long long handle, const char* name, const char* value) {
    auto request = csec_http::requests().get(handle);
    if (!request || !name || !*name) return 0;
    for (auto& header : request->headers) {
        if (csec_http::equalsIgnoreCase(header.first, name)) {
            header.second = value ? value : "";
            return 1;
        }
    }
    request->headers.emplace_back(name, value ? value : "");
    return 1;
}

int csec_http_request_body(long long handle, const char* body) {
    auto request = csec_http::requests().get(handle);
    if (!request) return 0;
    request->body = body ? body : "";
    request->hasBody = true;
    return 1;
}

int csec_http_request_timeout(long long handle, long long milliseconds) {
    auto request = csec_http::requests().get(handle);
    if (!request) return 0;
    request->timeoutMs = milliseconds;
    return 1;
}

void csec_http_request_free(long long handle) {
    csec_http::requests().take(handle);
}

// Send the request and wait for the whole response. 0 only for an invalid request handle.
long long csec_http_send(long long handle) {
    auto request = csec_http::requests().get(handle);
    if (!request) {
        csec_http::setError("invalid HTTP request handle");
        return 0;
    }
    auto response = csec_http::start(*request);
    csec_http::waitDone(*response);
    return csec_http::responses().add(response);
}

// Send the request and return once the status and headers have arrived; read the body as it comes.
long long csec_http_open(long long handle) {
    auto request = csec_http::requests().get(handle);
    if (!request) {
        csec_http::setError("invalid HTTP request handle");
        return 0;
    }
    auto response = csec_http::start(*request);
    csec_http::wait(*response, [&] { return response->headersReady; });
    return csec_http::responses().add(response);
}

char* csec_http_last_error(void) {
    std::lock_guard<std::mutex> lock(csec_http::errorMutex());
    return csec_http::owned(csec_http::lastError());
}

int csec_http_status(long long handle) {
    auto response = csec_http::responses().get(handle);
    if (!response) return 0;
    std::lock_guard<std::mutex> lock(response->mutex);
    return response->status;
}

char* csec_http_error(long long handle) {
    auto response = csec_http::responses().get(handle);
    if (!response) return csec_http::owned("invalid HTTP response handle");
    std::lock_guard<std::mutex> lock(response->mutex);
    return csec_http::owned(response->error);
}

char* csec_http_headers(long long handle) {
    auto response = csec_http::responses().get(handle);
    if (!response) return csec_http::owned("");
    std::lock_guard<std::mutex> lock(response->mutex);
    return csec_http::owned(response->headers);
}

// Value of a response header (case-insensitive name); repeated headers are joined with ", ".
char* csec_http_header(long long handle, const char* name) {
    auto response = csec_http::responses().get(handle);
    if (!response || !name) return csec_http::owned("");
    std::string headers;
    {
        std::lock_guard<std::mutex> lock(response->mutex);
        headers = response->headers;
    }
    std::string value;
    size_t pos = 0;
    while (pos < headers.size()) {
        size_t end = headers.find('\n', pos);
        if (end == std::string::npos) end = headers.size();
        const std::string line = headers.substr(pos, end - pos);
        const size_t colon = line.find(':');
        if (colon != std::string::npos && csec_http::equalsIgnoreCase(csec_http::trim(line.substr(0, colon)), name)) {
            if (!value.empty()) value += ", ";
            value += csec_http::trim(line.substr(colon + 1));
        }
        pos = end + 1;
    }
    return csec_http::owned(value);
}

// The (rest of the) body, after waiting for the response to complete.
char* csec_http_body(long long handle) {
    auto response = csec_http::responses().get(handle);
    if (!response) return csec_http::owned("");
    csec_http::waitDone(*response);
    std::lock_guard<std::mutex> lock(response->mutex);
    return csec_http::owned(response->data);
}

long long csec_http_body_size(long long handle) {
    auto response = csec_http::responses().get(handle);
    if (!response) return 0;
    csec_http::waitDone(*response);
    std::lock_guard<std::mutex> lock(response->mutex);
    return static_cast<long long>(response->data.size());
}

// Total body bytes received so far (also while streaming).
long long csec_http_received(long long handle) {
    auto response = csec_http::responses().get(handle);
    if (!response) return 0;
    std::lock_guard<std::mutex> lock(response->mutex);
    return response->received;
}

int csec_http_done(long long handle) {
    auto response = csec_http::responses().get(handle);
    if (!response) return 1;
    std::lock_guard<std::mutex> lock(response->mutex);
    return response->done ? 1 : 0;
}

// Write the (rest of the) body to a file in binary mode; returns the byte count or -1.
long long csec_http_save(long long handle, const char* path) {
    auto response = csec_http::responses().get(handle);
    if (!response || !path) return -1;
    csec_http::waitDone(*response);
    std::FILE* file = std::fopen(path, "wb");
    if (!file) return -1;
    std::lock_guard<std::mutex> lock(response->mutex);
    const size_t written = std::fwrite(response->data.data(), 1, response->data.size(), file);
    std::fclose(file);
    return written == response->data.size() ? static_cast<long long>(written) : -1;
}

int csec_http_next_line(long long handle) {
    auto response = csec_http::responses().get(handle);
    return response && csec_http::nextLine(*response) ? 1 : 0;
}

char* csec_http_line(long long handle) {
    auto response = csec_http::responses().get(handle);
    return csec_http::owned(response ? response->line : std::string());
}

int csec_http_next_event(long long handle) {
    auto response = csec_http::responses().get(handle);
    return response && csec_http::nextEvent(*response) ? 1 : 0;
}

char* csec_http_event_data(long long handle) {
    auto response = csec_http::responses().get(handle);
    return csec_http::owned(response ? response->eventData : std::string());
}

char* csec_http_event_name(long long handle) {
    auto response = csec_http::responses().get(handle);
    return csec_http::owned(response ? response->eventName : std::string());
}

char* csec_http_event_id(long long handle) {
    auto response = csec_http::responses().get(handle);
    return csec_http::owned(response ? response->eventId : std::string());
}

// Release the response; a transfer still in progress is abandoned.
void csec_http_close(long long handle) {
    auto response = csec_http::responses().take(handle);
    if (response) response->cancelled.store(true);
}

char* csec_url_encode(const char* text) {
    return csec_http::owned(csec_http::urlEncode(text ? text : ""));
}

char* csec_url_decode(const char* text) {
    return csec_http::owned(csec_http::urlDecode(text ? text : ""));
}

char* csec_url_resolve(const char* base, const char* ref) {
    return csec_http::owned(csec_http::resolveUrl(base ? base : "", ref ? ref : ""));
}

char* csec_html_to_text(const char* html) {
    return csec_http::owned(csec_http::htmlToText(html ? html : ""));
}

char* csec_html_title(const char* html) {
    return csec_http::owned(csec_http::htmlTitle(html ? html : ""));
}

char* csec_html_links(const char* html, const char* base) {
    return csec_http::owned(csec_http::htmlLinks(html ? html : "", base ? base : ""));
}

} // extern "C"
