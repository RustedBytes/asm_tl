#[cfg(not(feature = "std"))]
use crate::ParseError;
use crate::{stream::Stream, util};

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
        let has_whitespace = self.stream.expect_and_skip_cond(b' ');
        while !self.stream.is_eof() {
            if self.stream.expect_and_skip(b' ').is_none() {
                break;
            }
        }
        has_whitespace
    }

    fn read_identifier(&mut self) -> &'a [u8] {
        let start = self.stream.idx;

        while !self.stream.is_eof() {
            let is_ident = self.stream.current().copied().is_some_and(util::is_ident);
            if !is_ident {
                break;
            } else {
                self.stream.advance();
            }
        }

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

        let combinator = match tok {
            b',' => {
                self.stream.advance();
                let right = self.selector()?;
                Selector::Or(Box::new(left), Box::new(right))
            }
            b'>' => {
                self.stream.advance();
                let right = self.selector()?;
                Selector::Parent(Box::new(left), Box::new(right))
            }
            _ if has_whitespaces => {
                let right = self.selector()?;
                Selector::Descendant(Box::new(left), Box::new(right))
            }
            _ if !has_whitespaces => {
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
        if has_whitespaces || matches!(self.stream.current_cpy(), Some(b',' | b'>')) {
            return Err(ParseError::SelectorCapacityExceeded);
        }
        Err(ParseError::SelectorCapacityExceeded)
    }

    fn parse_attribute<const MAX_SELECTOR_NODES: usize>(
        &mut self,
    ) -> Option<Selector<'a, MAX_SELECTOR_NODES>> {
        let attribute = self.read_identifier();
        let ty = match self.stream.current_cpy() {
            Some(b']') => {
                self.stream.advance();
                Selector::Attribute(attribute)
            }
            Some(b'=') => {
                self.stream.advance();
                let quote = self.stream.expect_oneof_and_skip(b"\"'");
                let value = self.read_identifier();
                if let Some(quote) = quote {
                    // Only require the given quote if the value starts with a quote
                    self.stream.expect_and_skip(quote)?;
                }
                self.stream.expect_and_skip(b']')?;
                Selector::AttributeValue(attribute, value)
            }
            Some(c @ b'~' | c @ b'^' | c @ b'$' | c @ b'*') => {
                self.stream.advance();
                self.stream.expect_and_skip(b'=')?;
                let quote = self.stream.expect_oneof_and_skip(b"\"'");
                let value = self.read_identifier();
                if let Some(quote) = quote {
                    // Only require the given quote if the value starts with a quote
                    self.stream.expect_and_skip(quote)?;
                }
                self.stream.expect_and_skip(b']')?;
                match c {
                    b'~' => Selector::AttributeValueWhitespacedContains(attribute, value),
                    b'^' => Selector::AttributeValueStartsWith(attribute, value),
                    b'$' => Selector::AttributeValueEndsWith(attribute, value),
                    b'*' => Selector::AttributeValueSubstring(attribute, value),
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

        let left = match tok {
            b'#' => {
                self.stream.advance();
                let id = self.read_identifier();
                Selector::Id(id)
            }
            b'.' => {
                self.stream.advance();
                let class = self.read_identifier();
                Selector::Class(class)
            }
            b'*' => {
                self.stream.advance();
                Selector::All
            }
            b'[' => {
                self.stream.advance();
                self.parse_attribute::<0>()?
            }
            _ if util::is_ident(tok) => {
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

        let left = match tok {
            b'#' => {
                self.stream.advance();
                let id = self.read_identifier();
                Selector::Id(id)
            }
            b'.' => {
                self.stream.advance();
                let class = self.read_identifier();
                Selector::Class(class)
            }
            b'*' => {
                self.stream.advance();
                Selector::All
            }
            b'[' => {
                self.stream.advance();
                self.parse_attribute::<MAX_SELECTOR_NODES>()
                    .ok_or(ParseError::SelectorCapacityExceeded)?
            }
            _ if util::is_ident(tok) => {
                let tag = self.read_identifier();
                Selector::Tag(tag)
            }
            _ => return Err(ParseError::SelectorCapacityExceeded),
        };

        self.parse_combinator(left)
    }
}
