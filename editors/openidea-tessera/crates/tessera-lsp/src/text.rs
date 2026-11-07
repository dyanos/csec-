//! Byte offsets ↔ LSP positions (UTF-16 code units, the LSP default).

use lsp_types::{Position, Range};

pub struct LineIndex {
    starts: Vec<usize>,
}

impl LineIndex {
    pub fn new(text: &str) -> Self {
        let mut starts = vec![0];
        starts.extend(text.match_indices('\n').map(|(i, _)| i + 1));
        LineIndex { starts }
    }

    pub fn line_count(&self) -> usize {
        self.starts.len()
    }

    /// Byte range of line `line` (without the newline).
    pub fn line_range(&self, text: &str, line: usize) -> std::ops::Range<usize> {
        let start = self.starts.get(line).copied().unwrap_or(text.len());
        let mut end = self.starts.get(line + 1).map_or(text.len(), |s| s - 1);
        if end > start && text.as_bytes().get(end - 1) == Some(&b'\r') {
            end -= 1;
        }
        start..end.max(start)
    }

    pub fn position(&self, text: &str, offset: usize) -> Position {
        let offset = offset.min(text.len());
        let line = self.starts.partition_point(|&s| s <= offset) - 1;
        let start = self.starts[line];
        let mut col = 0u32;
        let mut i = start;
        for c in text[start..].chars() {
            if i >= offset {
                break;
            }
            i += c.len_utf8();
            col += c.len_utf16() as u32;
        }
        Position::new(line as u32, col)
    }

    pub fn range(&self, text: &str, r: std::ops::Range<usize>) -> Range {
        Range::new(self.position(text, r.start), self.position(text, r.end))
    }

    pub fn offset(&self, text: &str, pos: Position) -> usize {
        let Some(&start) = self.starts.get(pos.line as usize) else { return text.len() };
        let line_end = self.starts.get(pos.line as usize + 1).map_or(text.len(), |s| s - 1);
        let mut col = 0u32;
        let mut i = start;
        for c in text[start..line_end].chars() {
            if col >= pos.character {
                break;
            }
            col += c.len_utf16() as u32;
            i += c.len_utf8();
        }
        i
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn utf16_round_trip() {
        let t = "ab\nπ𝄞x\r\nz";
        let li = LineIndex::new(t);
        let x = t.find('x').unwrap();
        assert_eq!(li.position(t, x), Position::new(1, 3));
        assert_eq!(li.offset(t, Position::new(1, 3)), x);
        assert_eq!(li.line_range(t, 1), 3..x + 1);
        assert_eq!(li.offset(t, Position::new(2, 0)), t.find('z').unwrap());
        assert_eq!(li.offset(t, Position::new(9, 0)), t.len());
    }
}
