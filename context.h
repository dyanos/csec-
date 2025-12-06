#pragma once

#include <string>
#include <vector>

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

	Context(const Context& ref) {}
	Context& operator=(const Context& ref) {};
	~Context() {}

private:
	// 현재 symbol이 어떤 namespace에 속하는지를 담습니다.
	// namespace는 multi-stage로 되어 있기 때문에 vector로 관리합니다.
	NamespaceSymbol rootSymbol; // root symbol
	std::vector<Symbol*> m_path; // 현재 작업중인 namespace 경로

public:
	// Public methods to manage the context
	void init() {
		// root symbol을 만들고 m_path에 넣어줍니다.
		this->rootSymbol = NamespaceSymbol("");
		this->m_path.push_back(&this->rootSymbol);
		// Initialization code here
		//m_path.push_back(this->rootSymbol); // Add the root namespace
	}

	void cleanup() {
		// Cleanup code here
		m_path.clear();
	}

	void pushNamespace(Symbol& ns) {
		m_path.push_back(&ns);
	}

	void popNamespace() {
		if (!m_path.empty()) {
			m_path.pop_back();
		}
	}

	Symbol* getRootNamespace() {
		return &this->rootSymbol; // Return the root namespace
	}

	const std::vector<Symbol*>& getNamespaces() const {
		return this->m_path; // Return the current namespaces
	}

	const std::vector<Symbol*>& getNamespacesReverse() const {
		return std::vector<Symbol*>(m_path.rbegin(), m_path.rend()); // Return the current namespaces in reverse order
	}

    Symbol* getCurrentNamespace() {
		return m_path.back(); // Return the current namespace
    }

    Symbol* getCurrentNamespaceReverse() {
		return m_path.front(); // Return the current namespace in reverse order
    }
};