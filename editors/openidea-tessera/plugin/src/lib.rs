//! Tessera for OpenIDEA: highlighting, structure view and folding for `.csec`
//! files, exported as the plugin's `syntax-provider`. The lexer and the
//! declaration scanner live in the shared `tessera-syntax` crate (also used
//! by `tessera-lsp`); this file only maps them to the SDK's types. File
//! detection and the language server come from `languages/tessera.toml`.

use openidea_plugin::syntax::{Fold, FoldKind, Highlight, Symbol, SymbolKind, SyntaxProvider, Token};
use openidea_plugin::{Error, Invocation, Plugin, register_plugin};
use std::collections::HashMap;
use tessera_syntax::{Analysis, Class, DeclKind};

#[derive(Default)]
pub struct Tessera;

impl Plugin for Tessera {
    fn run_command(&mut self, id: &str, _ctx: &Invocation, _arg: Option<&str>) -> Result<Option<String>, Error> {
        Err(Error::NotFound(format!("command {id}")))
    }
}

impl SyntaxProvider for Tessera {
    fn highlights(&mut self, _language: &str, text: &str) -> Vec<Token> {
        highlights(text)
    }

    fn outline(&mut self, _language: &str, text: &str) -> Vec<Symbol> {
        outline(text)
    }

    fn folding(&mut self, _language: &str, text: &str) -> Vec<Fold> {
        folding(text)
    }
}

register_plugin!(Tessera, syntax);

fn highlight_kind(c: Class, word: &str) -> Option<Highlight> {
    Some(match c {
        Class::Keyword => Highlight::Keyword,
        Class::Constant if matches!(word, "true" | "false" | "null") => Highlight::Atom,
        Class::Constant => Highlight::Constant,
        Class::String => Highlight::String,
        Class::Escape => Highlight::Escape,
        Class::Interpolation => Highlight::StringSpecial,
        Class::Regex => Highlight::Regexp,
        Class::Number => Highlight::Number,
        Class::Comment => Highlight::Comment,
        Class::DocComment => Highlight::DocComment,
        Class::FunctionDecl => Highlight::Function,
        Class::FunctionCall | Class::MethodCall => Highlight::FunctionCall,
        Class::Type | Class::TypeDecl => Highlight::Type,
        Class::Builtin => Highlight::Builtin,
        Class::Parameter | Class::Variable => Highlight::Variable,
        Class::Property => Highlight::Property,
        Class::SelfRef => Highlight::SelfVariable,
        Class::Attribute => Highlight::Attribute,
        Class::Macro => Highlight::Macro,
        Class::Operator => Highlight::Operator,
        Class::Punctuation => Highlight::Punctuation,
    })
}

pub fn highlights(text: &str) -> Vec<Token> {
    let toks = tessera_syntax::tokenize(text);
    tessera_syntax::highlight(text, &toks)
        .into_iter()
        .filter_map(|(range, c)| highlight_kind(c, &text[range.clone()]).map(|kind| Token { range, kind }))
        .collect()
}

fn symbol_kind(kind: DeclKind, mutable: bool) -> SymbolKind {
    match kind {
        DeclKind::Function | DeclKind::External => SymbolKind::Function,
        DeclKind::Method => SymbolKind::Method,
        DeclKind::Operator => SymbolKind::Operator,
        DeclKind::Class | DeclKind::Object => SymbolKind::Class,
        DeclKind::Struct => SymbolKind::Struct,
        DeclKind::Dsl => SymbolKind::Module,
        DeclKind::Field => SymbolKind::Field,
        DeclKind::Global if mutable => SymbolKind::Variable,
        DeclKind::Global => SymbolKind::Constant,
        DeclKind::TypeParameter => SymbolKind::TypeParameter,
        DeclKind::Local | DeclKind::Parameter | DeclKind::Binder => SymbolKind::Variable,
    }
}

/// Structure view: declarations without locals; `detail` is what follows the
/// name in the header (`(a: Int): Int`).
pub fn outline(text: &str) -> Vec<Symbol> {
    let a = Analysis::new(text);
    let mut out: Vec<Symbol> = Vec::new();
    let mut index_of: HashMap<usize, usize> = HashMap::new();
    for (i, d) in a.decls.iter().enumerate() {
        if !d.kind.in_outline() {
            continue;
        }
        // Nearest ancestor that is itself listed.
        let mut p = d.parent;
        let parent = loop {
            match p {
                Some(j) => match index_of.get(&j) {
                    Some(&k) => break Some(k),
                    None => p = a.decls[j].parent,
                },
                None => break None,
            }
        };
        let detail = d
            .signature
            .find(&d.name)
            .map(|k| d.signature[k + d.name.len()..].trim().to_string())
            .filter(|s| !s.is_empty());
        index_of.insert(i, out.len());
        out.push(Symbol {
            name: d.name.clone(),
            detail,
            kind: symbol_kind(d.kind, d.mutable),
            range: d.range.start.min(d.name_range.start)..d.range.end.max(d.name_range.end),
            name_range: d.name_range.clone(),
            parent,
        });
    }
    out
}

pub fn folding(text: &str) -> Vec<Fold> {
    let toks = tessera_syntax::tokenize(text);
    tessera_syntax::folds(text, &toks)
        .into_iter()
        .map(|f| Fold {
            start_line: f.start_line,
            end_line: f.end_line,
            kind: match f.kind {
                tessera_syntax::FoldKind::Region => FoldKind::Region,
                tessera_syntax::FoldKind::Comment => FoldKind::Comment,
                tessera_syntax::FoldKind::Imports => FoldKind::Imports,
            },
        })
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    const SRC: &str = "import \"lib\";\n// Area.\ndef area(r: Double): Double {\n    return PI * r ** 2;\n}\nclass Point(x: Double, y: Double) {\n    def norm(): Double = sqrt(x * x + y * y);\n}\n";

    #[test]
    fn highlights_are_disjoint_and_typed() {
        let h = highlights(SRC);
        for w in h.windows(2) {
            assert!(w[0].range.end <= w[1].range.start);
        }
        let kind_of = |s: &str| h.iter().find(|t| &SRC[t.range.clone()] == s).map(|t| t.kind);
        assert_eq!(kind_of("def"), Some(Highlight::Keyword));
        assert_eq!(kind_of("area"), Some(Highlight::Function));
        assert_eq!(kind_of("Double"), Some(Highlight::Type));
        assert_eq!(kind_of("// Area."), Some(Highlight::Comment));
        assert_eq!(kind_of("sqrt"), Some(Highlight::Builtin));
    }

    #[test]
    fn outline_nests_members() {
        let o = outline(SRC);
        let names: Vec<_> = o.iter().map(|s| (s.name.as_str(), s.kind, s.parent)).collect();
        assert_eq!(
            names,
            vec![
                ("area", SymbolKind::Function, None),
                ("Point", SymbolKind::Class, None),
                ("x", SymbolKind::Field, Some(1)),
                ("y", SymbolKind::Field, Some(1)),
                ("norm", SymbolKind::Method, Some(1)),
            ]
        );
        assert_eq!(o[0].detail.as_deref(), Some("(r: Double): Double"));
    }

    #[test]
    fn folds_bodies() {
        let f = folding(SRC);
        assert!(f.iter().any(|f| f.start_line == 2 && f.kind == FoldKind::Region));
    }
}
