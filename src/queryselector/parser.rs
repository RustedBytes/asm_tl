#[cfg(not(feature = "std"))]
use crate::ParseError;
use crate::{asm_core, stream::Stream};

use super::Selector;

/// A query selector parser
pub struct Parser<'a> {
    stream: Stream<'a, u8>,
}

impl<'a> Parser<'a> {
    /// Creates a new query selector parser
    pub fn new(input: &'a [u8]) -> Self {
        Self {
            stream: Stream::new(input),
        }
    }

    fn skip_whitespaces(&mut self) -> bool {
        let skipped = asm_core::count_spaces(&self.stream.data()[self.stream.idx..]);
        self.stream.idx += skipped;
        skipped != 0
    }

    fn read_identifier(&mut self) -> &'a [u8] {
        let start = self.stream.idx;
        let len = asm_core::count_ident(&self.stream.data()[start..]);
        self.stream.advance_by(len);

        self.stream.slice(start, self.stream.idx)
    }

    #[cfg(feature = "std")]
    fn parse_combinator(&mut self, left: Selector<'a>) -> Option<Selector<'a>> {
        let has_whitespaces = self.skip_whitespaces();

        let tok = if let Some(tok) = self.stream.current_cpy() {
            tok
        } else {
            return Some(left);
        };

        let combinator = match asm_core::selector_combinator_kind(tok, has_whitespaces) {
            1 => {
                self.stream.advance();
                let right = self.selector()?;
                Selector::Or(Box::new(left), Box::new(right))
            }
            2 => {
                self.stream.advance();
                let right = self.selector()?;
                Selector::Parent(Box::new(left), Box::new(right))
            }
            3 => {
                let right = self.selector()?;
                Selector::Descendant(Box::new(left), Box::new(right))
            }
            4 => {
                let right = self.selector()?;
                Selector::And(Box::new(left), Box::new(right))
            }
            _ => unreachable!(),
        };

        Some(combinator)
    }

    #[cfg(not(feature = "std"))]
    fn parse_combinator<const MAX_SELECTOR_NODES: usize>(
        &mut self,
        left: Selector<'a, MAX_SELECTOR_NODES>,
    ) -> Result<Selector<'a, MAX_SELECTOR_NODES>, ParseError> {
        let has_whitespaces = self.skip_whitespaces();
        if self.stream.current_cpy().is_none() {
            return Ok(left);
        }
        let tok = self.stream.current_cpy().unwrap();
        let combinator = asm_core::selector_combinator_kind(tok, has_whitespaces);
        if combinator == 1 || combinator == 2 || combinator == 3 {
            return Err(ParseError::SelectorCapacityExceeded);
        }
        Err(ParseError::SelectorCapacityExceeded)
    }

    fn parse_attribute<const MAX_SELECTOR_NODES: usize>(
        &mut self,
    ) -> Option<Selector<'a, MAX_SELECTOR_NODES>> {
        let attribute = self.read_identifier();
        let Some(op) = self
            .stream
            .current_cpy()
            .map(asm_core::selector_attr_op_kind)
        else {
            return None;
        };
        let ty = match op {
            1 => {
                self.stream.advance();
                Selector::Attribute(attribute)
            }
            2 => {
                self.stream.advance();
                let quote = self.stream.current_cpy().filter(|&c| asm_core::is_quote(c));
                if quote.is_some() {
                    self.stream.advance();
                }
                let value = self.read_identifier();
                if let Some(quote) = quote {
                    // Only require the given quote if the value starts with a quote
                    self.stream.expect_and_skip(quote)?;
                }
                self.stream.expect_and_skip(b']')?;
                Selector::AttributeValue(attribute, value)
            }
            c @ (3 | 4 | 5 | 6) => {
                self.stream.advance();
                self.stream.expect_and_skip(b'=')?;
                let quote = self.stream.current_cpy().filter(|&c| asm_core::is_quote(c));
                if quote.is_some() {
                    self.stream.advance();
                }
                let value = self.read_identifier();
                if let Some(quote) = quote {
                    // Only require the given quote if the value starts with a quote
                    self.stream.expect_and_skip(quote)?;
                }
                self.stream.expect_and_skip(b']')?;
                match c {
                    3 => Selector::AttributeValueWhitespacedContains(attribute, value),
                    4 => Selector::AttributeValueStartsWith(attribute, value),
                    5 => Selector::AttributeValueEndsWith(attribute, value),
                    6 => Selector::AttributeValueSubstring(attribute, value),
                    _ => unreachable!(),
                }
            }
            _ => return None,
        };
        Some(ty)
    }

    /// Parses a full selector
    #[cfg(feature = "std")]
    pub fn selector(&mut self) -> Option<Selector<'a>> {
        self.skip_whitespaces();
        let tok = self.stream.current_cpy()?;

        let left = match asm_core::selector_token_kind(tok) {
            1 => {
                self.stream.advance();
                let id = self.read_identifier();
                Selector::Id(id)
            }
            2 => {
                self.stream.advance();
                let class = self.read_identifier();
                Selector::Class(class)
            }
            3 => {
                self.stream.advance();
                Selector::All
            }
            4 => {
                self.stream.advance();
                self.parse_attribute::<0>()?
            }
            5 => {
                let tag = self.read_identifier();
                Selector::Tag(tag)
            }
            _ => return None,
        };

        self.parse_combinator(left)
    }

    /// Parses a full selector without allocation.
    #[cfg(not(feature = "std"))]
    pub fn selector<const MAX_SELECTOR_NODES: usize>(
        &mut self,
    ) -> Result<Selector<'a, MAX_SELECTOR_NODES>, ParseError> {
        self.skip_whitespaces();
        let tok = self
            .stream
            .current_cpy()
            .ok_or(ParseError::SelectorCapacityExceeded)?;

        let left = match asm_core::selector_token_kind(tok) {
            1 => {
                self.stream.advance();
                let id = self.read_identifier();
                Selector::Id(id)
            }
            2 => {
                self.stream.advance();
                let class = self.read_identifier();
                Selector::Class(class)
            }
            3 => {
                self.stream.advance();
                Selector::All
            }
            4 => {
                self.stream.advance();
                self.parse_attribute::<MAX_SELECTOR_NODES>()
                    .ok_or(ParseError::SelectorCapacityExceeded)?
            }
            5 => {
                let tag = self.read_identifier();
                Selector::Tag(tag)
            }
            _ => return Err(ParseError::SelectorCapacityExceeded),
        };

        self.parse_combinator(left)
    }
}
