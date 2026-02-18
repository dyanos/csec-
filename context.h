#pragma once

#include <string>
#include <vector>
#include <memory>

// NamespaceSymbol을 이용해야할 듯
#include "symbol.h"

// Singleton class to manage the context of the application
class Context {
public:
	// Static method to get the instance of the Context
	static Context& getInstance() {
		static Context instance; // Guaranteed to be destroyed
		return instance;          // Instantiated on first use
	}
	// Delete copy constructor and assignment operator to prevent copying
	Context() {
		init();
	}

	Context(const Context& ref) = delete;
	Context& operator=(const Context& ref) = delete;
	~Context() {}

private:
	std::unique_ptr<NamespaceSymbol> rootSymbol; // root symbol을 포인터로 관리
	std::vector<NamespaceSymbol*> m_path; // non-owning namespace path

public:
	// Public methods to manage the context
	void init() {
		rootSymbol = std::make_unique<NamespaceSymbol>("");
		m_path.clear();
		m_path.push_back(rootSymbol.get());
		// Initialization code here
		//m_path.push_back(this->rootSymbol); // Add the root namespace
	}

	void cleanup() {
		// Cleanup code here
		m_path.clear();
	}

	void pushNamespace(NamespaceSymbol& ns) {
		m_path.push_back(&ns);
	}

	void popNamespace() {
		if (!m_path.empty()) {
			m_path.pop_back();
		}
	}

	NamespaceSymbol* getRootNamespace() {
		return rootSymbol.get(); // Return the root namespace
	}

	const std::vector<NamespaceSymbol*>& getNamespaces() const {
		return m_path; // Return the current namespaces
	}

	std::vector<NamespaceSymbol*> getNamespacesReverse() const {
		return std::vector<NamespaceSymbol*>(m_path.rbegin(), m_path.rend()); // Return the current namespaces in reverse order
	}

    NamespaceSymbol* getCurrentNamespace() {
		return m_path.back(); // Return the current namespace
    }

    NamespaceSymbol* getCurrentNamespaceReverse() {
		return m_path.front(); // Return the current namespace in reverse order
    }
};