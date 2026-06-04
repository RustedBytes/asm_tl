#![doc = include_str!("../README.md")]
#![deny(missing_docs)]
#![cfg_attr(not(feature = "std"), no_std)]
#![cfg_attr(feature = "portable-simd", feature(portable_simd))]

mod asm_core;
mod bytes;
/// Errors that occur throughout the crate
pub mod errors;
/// Inline data structures
pub mod inline;
mod parser;
/// Query selector API
pub mod queryselector;
mod stream;
#[cfg(all(test, feature = "std"))]
mod tests;
mod util;
mod vdom;

#[doc(hidden)]
#[cfg(feature = "__INTERNALS_DO_NOT_USE")]
pub mod simd;
#[cfg(not(feature = "__INTERNALS_DO_NOT_USE"))]
mod simd;

pub use bytes::Bytes;
pub use errors::ParseError;
pub use parser::*;
use queryselector::Selector;
pub use vdom::VDom;
#[cfg(feature = "std")]
pub use vdom::VDomGuard;

#[cfg(feature = "std")]
const STD_INLINE_CLASS_HANDLES: usize = 32;
#[cfg(feature = "std")]
const STD_INLINE_IDS: usize = 16;
#[cfg(feature = "std")]
const STD_INLINE_CLASSES: usize = 16;

/// Parses the given input string
///
/// This is the "entry point" and function that is called to parse HTML.
/// The input string must be kept alive, and must outlive `VDom`.
/// If you need an "owned" version that takes an input string and can be kept around forever,
/// consider using `parse_owned()`.
///
/// # Errors
/// Throughout the parser it is assumed that spans never overflow a `u32`.
/// To prevent this, this function will return an error if the input string length would overflow a `u32`.
/// If the input string length fits in a `u32`, then it is safe to assume that none of the substrings can overflow a `u32`.
///
/// # Example
/// ```
/// # use tl::*;
/// let dom = parse("<div>Hello, world!</div>", ParserOptions::default()).unwrap();
/// assert_eq!(dom.query_selector("div").unwrap().count(), 1);
/// ```
#[cfg(feature = "std")]
pub fn parse(
    input: &str,
    options: ParserOptions,
) -> Result<
    VDom<'_, STD_INLINE_CLASS_HANDLES, 0, 0, STD_INLINE_IDS, STD_INLINE_CLASSES, 0>,
    ParseError,
> {
    let mut parser =
        Parser::<STD_INLINE_CLASS_HANDLES, 0, 0, STD_INLINE_IDS, STD_INLINE_CLASSES, 0>::new(
            input, options,
        );
    parser.parse()?;
    Ok(VDom::from(parser))
}

/// Parses the given input string using bounded, allocation-free storage.
///
/// Capacity parameters bound the number of parsed nodes, parser stack entries,
/// root nodes, tracked IDs, tracked classes, and query selector nodes.
#[cfg(not(feature = "std"))]
pub fn parse<
    const MAX_NODES: usize,
    const MAX_STACK: usize,
    const MAX_ROOTS: usize,
    const MAX_IDS: usize,
    const MAX_CLASSES: usize,
    const MAX_SELECTOR_NODES: usize,
>(
    input: &str,
    options: ParserOptions,
) -> Result<
    VDom<'_, MAX_NODES, MAX_STACK, MAX_ROOTS, MAX_IDS, MAX_CLASSES, MAX_SELECTOR_NODES>,
    ParseError,
> {
    let mut parser = Parser::new(input, options);
    parser.parse()?;
    Ok(VDom::from(parser))
}

/// Parses a query selector
///
/// # Example
/// ```
/// # use tl::queryselector::selector::Selector;
/// let selector = tl::parse_query_selector("div#test");
///
/// match selector {
///     Some(Selector::And(left, right)) => {
///         assert!(matches!(&*left, Selector::Tag(b"div")));
///         assert!(matches!(&*right, Selector::Id(b"test")));
///     },
///     _ => unreachable!()
/// }
/// ```
#[cfg(feature = "std")]
pub fn parse_query_selector(input: &str) -> Option<Selector<'_>> {
    let bytes = input.as_bytes();
    let (simple_kind, tag_len) = asm_core::simple_selector_kind(bytes);
    match simple_kind {
        1 => return Some(Selector::All),
        2 => return Some(Selector::Tag(bytes)),
        3 => return Some(Selector::Id(&bytes[1..])),
        4 => return Some(Selector::Class(&bytes[1..])),
        5 => {
            return Some(Selector::And(
                Box::new(Selector::Tag(&bytes[..tag_len])),
                Box::new(Selector::Id(&bytes[tag_len + 1..])),
            ));
        }
        6 => {
            return Some(Selector::And(
                Box::new(Selector::Tag(&bytes[..tag_len])),
                Box::new(Selector::Class(&bytes[tag_len + 1..])),
            ));
        }
        _ => {}
    }

    if asm_core::selector_kind(bytes) == 0 {
        return None;
    }

    let selector = queryselector::Parser::new(bytes).selector()?;
    Some(selector)
}

/// Parses a query selector using bounded, allocation-free storage.
#[cfg(not(feature = "std"))]
pub fn parse_query_selector<const MAX_SELECTOR_NODES: usize>(
    input: &str,
) -> Result<Selector<'_, MAX_SELECTOR_NODES>, ParseError> {
    if asm_core::selector_kind(input.as_bytes()) == 0 {
        return Err(ParseError::UnsupportedAssemblySyntax);
    }

    queryselector::Parser::new(input.as_bytes()).selector::<MAX_SELECTOR_NODES>()
}

/// Parses the given input string and returns an owned, RAII guarded DOM
///
/// # Errors
/// See [parse]
///
/// # Safety
/// This uses `unsafe` code to create a self-referential-like struct.
/// The given input string is first leaked and turned into raw pointer, and its lifetime will be promoted to 'static.
/// Once `VDomGuard` goes out of scope, the string will be freed.
/// It should not be possible to cause UB in its current form and might become a safe function in the future.
#[cfg(feature = "std")]
pub unsafe fn parse_owned(input: String, options: ParserOptions) -> Result<VDomGuard, ParseError> {
    VDomGuard::parse(input, options)
}
