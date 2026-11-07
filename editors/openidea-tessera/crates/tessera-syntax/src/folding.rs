//! Folding ranges: multi-line `{}` / `[]` / `()` groups, block comments,
//! runs of line comments, and runs of `import` lines. Lines are 0-based.

use crate::lexer::{Tok, TokKind};

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum FoldKind {
    Region,
    Comment,
    Imports,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct Fold {
    pub start_line: u32,
    pub end_line: u32,
    pub kind: FoldKind,
}

/// Byte offset → 0-based line, by binary search over line starts.
pub struct Lines {
    starts: Vec<usize>,
}

impl Lines {
    pub fn new(src: &str) -> Self {
        let mut starts = vec![0];
        starts.extend(src.match_indices('\n').map(|(i, _)| i + 1));
        Lines { starts }
    }

    pub fn line_of(&self, offset: usize) -> u32 {
        (self.starts.partition_point(|&s| s <= offset) - 1) as u32
    }

    pub fn line_start(&self, line: u32) -> usize {
        self.starts.get(line as usize).copied().unwrap_or_else(|| *self.starts.last().unwrap())
    }

    pub fn count(&self) -> usize {
        self.starts.len()
    }
}

pub fn folds(src: &str, toks: &[Tok]) -> Vec<Fold> {
    let lines = Lines::new(src);
    let mut out = Vec::new();
    let mut stack: Vec<(&str, u32)> = Vec::new();
    let mut comment_run: Option<(u32, u32)> = None;
    let mut import_run: Option<(u32, u32)> = None;

    let flush = |out: &mut Vec<Fold>, run: &mut Option<(u32, u32)>, kind| {
        if let Some((s, e)) = run.take() {
            if e > s {
                out.push(Fold { start_line: s, end_line: e, kind });
            }
        }
    };

    for (i, t) in toks.iter().enumerate() {
        let line = lines.line_of(t.range.start);
        let end_line = lines.line_of(t.range.end.saturating_sub(1).max(t.range.start));
        match t.kind {
            TokKind::LineComment | TokKind::DocComment if t.text(src).starts_with("//") => {
                // Only whole-line comments join a run.
                let ls = lines.line_start(line);
                let own_line = src[ls..t.range.start].trim().is_empty();
                match comment_run {
                    Some((s, e)) if own_line && e + 1 == line => comment_run = Some((s, line)),
                    _ => {
                        flush(&mut out, &mut comment_run, FoldKind::Comment);
                        if own_line {
                            comment_run = Some((line, line));
                        }
                    }
                }
                continue;
            }
            TokKind::BlockComment | TokKind::DocComment => {
                flush(&mut out, &mut comment_run, FoldKind::Comment);
                if end_line > line {
                    out.push(Fold { start_line: line, end_line, kind: FoldKind::Comment });
                }
                continue;
            }
            _ => flush(&mut out, &mut comment_run, FoldKind::Comment),
        }

        if t.kind == TokKind::Keyword && t.text(src) == "import" {
            match import_run {
                Some((s, e)) if e + 1 >= line => import_run = Some((s, line)),
                _ => {
                    flush(&mut out, &mut import_run, FoldKind::Imports);
                    import_run = Some((line, line));
                }
            }
        } else if import_run.is_some_and(|(_, e)| line > e) {
            flush(&mut out, &mut import_run, FoldKind::Imports);
        }

        if t.kind == TokKind::Op {
            let w = t.text(src);
            match w {
                "{" | "[" | "[@" | "(" => stack.push((w, line)),
                "}" | "]" | ")" => {
                    let open = match w {
                        "}" => "{",
                        "]" => "[",
                        _ => "(",
                    };
                    // Pop to the matching opener (tolerates unbalanced input).
                    if let Some(pos) = stack.iter().rposition(|(o, _)| *o == open || (open == "[" && *o == "[@")) {
                        let (_, start) = stack[pos];
                        stack.truncate(pos);
                        // Keep the closing line visible when it only closes (`}`), like most IDEs.
                        if line > start {
                            let end = if line_has_only_closer(src, &lines, line, i, toks) { line - 1 } else { line };
                            if end > start {
                                out.push(Fold { start_line: start, end_line: end, kind: FoldKind::Region });
                            } else if line > start {
                                out.push(Fold { start_line: start, end_line: line, kind: FoldKind::Region });
                            }
                        }
                    }
                }
                _ => {}
            }
        }
    }
    flush(&mut out, &mut comment_run, FoldKind::Comment);
    flush(&mut out, &mut import_run, FoldKind::Imports);
    out.sort_by_key(|f| (f.start_line, std::cmp::Reverse(f.end_line)));
    out.dedup_by_key(|f| f.start_line);
    out
}

fn line_has_only_closer(src: &str, lines: &Lines, line: u32, _i: usize, _toks: &[Tok]) -> bool {
    let start = lines.line_start(line);
    let end = if (line as usize) + 1 < lines.count() { lines.line_start(line + 1) } else { src.len() };
    let text = src[start..end].trim();
    text.chars().all(|c| matches!(c, '}' | ')' | ']' | ';' | ','))
        || text.starts_with('}') && text.trim_start_matches('}').trim_start().starts_with("else")
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::lexer::tokenize;

    #[test]
    fn braces_comments_imports() {
        let src = "import \"a\";\nimport \"b\";\n// one\n// two\ndef f(): Int {\n    return 1;\n}\n/* x\n y */\n";
        let f = folds(src, &tokenize(src));
        assert!(f.contains(&Fold { start_line: 0, end_line: 1, kind: FoldKind::Imports }));
        assert!(f.contains(&Fold { start_line: 2, end_line: 3, kind: FoldKind::Comment }));
        assert!(f.contains(&Fold { start_line: 4, end_line: 5, kind: FoldKind::Region }));
        assert!(f.contains(&Fold { start_line: 7, end_line: 8, kind: FoldKind::Comment }));
    }

    #[test]
    fn line_lookup() {
        let l = Lines::new("ab\ncd\n");
        assert_eq!(l.line_of(0), 0);
        assert_eq!(l.line_of(2), 0);
        assert_eq!(l.line_of(3), 1);
        assert_eq!(l.line_of(6), 2);
    }
}
