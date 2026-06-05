#![doc = include_str!("../README.md")]
#![deny(missing_docs)]

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
#[cfg(test)]
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
pub use vdom::VDomGuard;

const STD_INLINE_CLASS_HANDLES: usize = 32;
const STD_INLINE_IDS: usize = 16;
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
/// # use asm_tl::*;
/// let dom = parse("<div>Hello, world!</div>", ParserOptions::default()).unwrap();
/// assert_eq!(dom.query_selector("div").unwrap().count(), 1);
/// ```
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

/// Parses a query selector
///
/// # Example
/// ```
/// # use asm_tl::queryselector::selector::Selector;
/// let selector = asm_tl::parse_query_selector("div#test");
///
/// match selector {
///     Some(Selector::And(left, right)) => {
///         assert!(matches!(&*left, Selector::Tag(b"div")));
///         assert!(matches!(&*right, Selector::Id(b"test")));
///     },
///     _ => unreachable!()
/// }
/// ```
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
pub unsafe fn parse_owned(input: String, options: ParserOptions) -> Result<VDomGuard, ParseError> {
    VDomGuard::parse(input, options)
}

/// Runs the x86_64 assembly document scanner and returns emitted record counts.
#[doc(hidden)]
pub fn __asm_scan_document_counts(input: &str) -> Result<(usize, usize, usize), ParseError> {
    use core::mem::MaybeUninit;

    const STACK_NODE_CAP: usize = 192;
    const STACK_ATTR_CAP: usize = 128;
    const STACK_STACK_CAP: usize = 64;

    let mut nodes = [const { MaybeUninit::<asm_core::AsmNodeRecord>::uninit() }; STACK_NODE_CAP];
    let mut attrs = [const { MaybeUninit::<asm_core::AsmAttrRecord>::uninit() }; STACK_ATTR_CAP];
    let mut stack = [const { MaybeUninit::<u32>::uninit() }; STACK_STACK_CAP];
    let mut out = asm_core::AsmParseOutput::from_raw_parts(
        asm_core::AsmBuffer::new(nodes.as_mut_ptr().cast(), STACK_NODE_CAP),
        asm_core::AsmBuffer::new(attrs.as_mut_ptr().cast(), STACK_ATTR_CAP),
        asm_core::AsmBuffer::new(core::ptr::null_mut(), 0),
        asm_core::AsmBuffer::new(stack.as_mut_ptr().cast(), STACK_STACK_CAP),
    );

    match asm_core::parse_document(input.as_bytes(), &mut out) {
        0 => Ok((out.nodes_len, out.attrs_len, out.roots_len)),
        1 => Err(ParseError::NodeCapacityExceeded),
        2 => Err(ParseError::AttributeCapacityExceeded),
        3 => Err(ParseError::RootCapacityExceeded),
        4 => Err(ParseError::StackCapacityExceeded),
        _ => Err(ParseError::UnsupportedAssemblySyntax),
    }
}
