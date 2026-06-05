use super::{
    constants,
    handle::NodeHandle,
    tag::{Attributes, HTMLTag, Node},
};
use crate::InnerNodeHandle;
use crate::asm_core;
use crate::inline::hashmap::InlineHashMap;
use crate::{ParseError, bytes::Bytes, inline::vec::InlineVec, simd};
use crate::{ParserOptions, stream::Stream};

#[cfg(feature = "std")]
type StorageVec<T, const N: usize> = std::vec::Vec<T>;
#[cfg(not(feature = "std"))]
type StorageVec<T, const N: usize> = InlineVec<T, N>;

#[cfg(feature = "std")]
type StorageMap<K, V, const N: usize> = InlineHashMap<K, V, N>;
#[cfg(not(feature = "std"))]
type StorageMap<K, V, const N: usize> = InlineHashMap<K, V, N>;

#[cfg(feature = "std")]
fn new_vec_with_capacity<T, const N: usize>(capacity: usize) -> StorageVec<T, N> {
    std::vec::Vec::with_capacity(capacity)
}

#[cfg(not(feature = "std"))]
fn new_vec_with_capacity<T, const N: usize>(_capacity: usize) -> StorageVec<T, N> {
    InlineVec::new()
}

#[cfg(feature = "std")]
fn new_map<K, V, const N: usize>() -> StorageMap<K, V, N>
where
    K: core::hash::Hash + Eq,
{
    InlineHashMap::new()
}

#[cfg(not(feature = "std"))]
fn new_map<K, V, const N: usize>() -> StorageMap<K, V, N>
where
    K: core::hash::Hash + Eq,
{
    InlineHashMap::new()
}

#[cfg(feature = "std")]
fn push_vec<T, const N: usize>(
    vec: &mut StorageVec<T, N>,
    value: T,
    _err: ParseError,
) -> Result<(), ParseError> {
    vec.push(value);
    Ok(())
}

#[cfg(not(feature = "std"))]
fn push_vec<T, const N: usize>(
    vec: &mut StorageVec<T, N>,
    value: T,
    err: ParseError,
) -> Result<(), ParseError> {
    vec.push(value).map_err(|_| err)
}

#[inline]
fn push_class_handle<const N: usize>(
    vec: &mut ClassVec<N>,
    value: NodeHandle,
    err: ParseError,
) -> Result<(), ParseError> {
    vec.push_handle(value).map_err(|_| err)
}

fn insert_bytes_map<'a, V, const N: usize>(
    map: &mut StorageMap<Bytes<'a>, V, N>,
    key: Bytes<'a>,
    value: V,
    err: ParseError,
) -> Result<Option<V>, ParseError> {
    if let Some(slot) = map.get_bytes_mut(&key) {
        let old = core::mem::replace(slot, value);
        Ok(Some(old))
    } else {
        map.insert(key, value).map_err(|_| err)?;
        Ok(None)
    }
}

/// A list of HTML nodes
pub type Tree<'a, const MAX_NODES: usize = 0> = StorageVec<Node<'a>, MAX_NODES>;

/// Inline class vector
pub type ClassVec<const MAX_NODES: usize = 0> = InlineVec<NodeHandle, MAX_NODES>;

/// HTML Version (<!DOCTYPE>)
#[derive(Debug, Copy, Clone, PartialEq)]
#[repr(C)]
pub enum HTMLVersion {
    /// HTML Version 5
    HTML5,
    /// Strict HTML 4.01
    StrictHTML401,
    /// Transitional HTML 4.01
    TransitionalHTML401,
    /// Frameset HTML 4.01:
    FramesetHTML401,
}
/// The main HTML parser
///
/// Users of this library are not supposed to directly construct this struct.
/// Instead, users must call `tl::parse()` and use the returned `VDom`.
#[derive(Debug)]
pub struct Parser<
    'a,
    const MAX_NODES: usize = 0,
    const MAX_STACK: usize = 0,
    const MAX_ROOTS: usize = 0,
    const MAX_IDS: usize = 0,
    const MAX_CLASSES: usize = 0,
    const MAX_SELECTOR_NODES: usize = 0,
> {
    /// The inner stream that is used to iterate through the HTML source
    pub(crate) stream: Stream<'a, u8>,
    pub(crate) stack: StorageVec<NodeHandle, MAX_STACK>,
    /// Specified options for this HTML parser
    pub(crate) options: ParserOptions,
    /// A global collection of all HTML tags that appear in the source code
    ///
    /// HTML Nodes contain indicies into this vector
    pub(crate) tags: Tree<'a, MAX_NODES>,
    /// The topmost HTML nodes
    pub(crate) ast: StorageVec<NodeHandle, MAX_ROOTS>,
    /// A HashMap that maps Tag ID to a Node ID
    pub(crate) ids: StorageMap<Bytes<'a>, NodeHandle, MAX_IDS>,
    /// A HashMap that maps Tag Class to a Node ID
    pub(crate) classes: StorageMap<Bytes<'a>, ClassVec<MAX_NODES>, MAX_CLASSES>,
    /// The current HTML version, if set
    pub(crate) version: Option<HTMLVersion>,
}

impl<
    'a,
    const MAX_NODES: usize,
    const MAX_STACK: usize,
    const MAX_ROOTS: usize,
    const MAX_IDS: usize,
    const MAX_CLASSES: usize,
    const MAX_SELECTOR_NODES: usize,
> Parser<'a, MAX_NODES, MAX_STACK, MAX_ROOTS, MAX_IDS, MAX_CLASSES, MAX_SELECTOR_NODES>
{
    pub(crate) fn new(input: &'a str, options: ParserOptions) -> Self {
        let node_capacity = (input.len() / 48).clamp(8, 256);
        Parser {
            stack: new_vec_with_capacity::<NodeHandle, MAX_STACK>(16),
            options,
            tags: new_vec_with_capacity::<Node<'a>, MAX_NODES>(node_capacity),
            stream: Stream::new(input.as_bytes()),
            ast: new_vec_with_capacity::<NodeHandle, MAX_ROOTS>(8),
            ids: new_map::<Bytes<'a>, NodeHandle, MAX_IDS>(),
            classes: new_map::<Bytes<'a>, ClassVec<MAX_NODES>, MAX_CLASSES>(),
            version: None,
        }
    }

    #[inline(always)]
    fn register_tag(&mut self, node: Node<'a>) -> Result<NodeHandle, ParseError> {
        push_vec::<Node<'a>, MAX_NODES>(&mut self.tags, node, ParseError::NodeCapacityExceeded)?;
        Ok(NodeHandle::new((self.tags.len() - 1) as u32))
    }

    #[inline(always)]
    fn skip_whitespaces(&mut self) {
        let start = self.stream.idx;
        let skipped = asm_core::count_while2(&self.stream.data()[start..], [b' ', b'\n']);
        self.stream.idx += skipped;
    }

    fn read_to(&mut self, needle: u8) -> &'a [u8] {
        let start = self.stream.idx;
        let bytes = &self.stream.data()[start..];

        let end = simd::find(bytes, needle).unwrap_or_else(|| self.stream.len() - start);

        self.stream.idx += end;
        self.stream.slice(start, start + end)
    }

    fn read_ident(&mut self) -> Option<&'a [u8]> {
        let start = self.stream.idx;
        let bytes = &self.stream.data()[start..];

        // If we do not find any characters that are not identifiers
        // then we are probably at the end of the stream
        let end = simd::search_non_ident(bytes).unwrap_or_else(|| self.stream.len() - start);

        // If we don't find any identifier characters, return `None`.
        if end == 0 {
            return None;
        }

        self.stream.idx += end;
        Some(self.stream.slice(start, start + end))
    }

    fn skip_comment_with_start(&mut self, start: usize) -> &'a [u8] {
        let offset = asm_core::find_comment_end(&self.stream.data()[self.stream.idx..]);
        if let Some(offset) = offset {
            self.stream.advance_by(offset);
            return self.stream.slice(start, self.stream.idx);
        }

        &[]
    }

    fn parse_attribute(&mut self) -> Option<(&'a [u8], Option<&'a [u8]>)> {
        let attr = asm_core::parse_attr(self.stream.data(), self.stream.idx)?;
        self.stream.idx = attr.next_idx;

        let name = self
            .stream
            .slice(attr.name_start, attr.name_start + attr.name_len);

        let value = (attr.has_value != 0)
            .then(|| self.stream.slice(attr.value_start, attr.value_start + attr.value_len));

        Some((name, value))
    }

    fn parse_attributes(&mut self) -> Result<Option<Attributes<'a>>, ParseError> {
        let mut attributes = Attributes::new();

        loop {
            self.skip_whitespaces();

            let cur = match self.stream.current_cpy() {
                Some(cur) => cur,
                None => return Ok(None),
            };

            if simd::is_closing(cur) {
                break;
            }

            if let Some((key, value)) = self.parse_attribute() {
                let has_value = value.is_some();
                let value: Option<Bytes<'a>> = value.map(Into::into);

                match asm_core::attr_key_kind(key) {
                    1 => attributes.id = value,
                    2 => attributes.class = value,
                    _ => {
                        attributes
                            .raw
                            .insert(key.into(), value)
                            .map_err(|_| ParseError::AttributeCapacityExceeded)?;
                    }
                }

                // Only advance past the delimiter if we read a value.
                let Some(cur) = self.stream.current_cpy() else {
                    return Ok(None);
                };
                if has_value && !simd::is_closing(cur) {
                    self.stream.advance();
                }
            } else {
                // No valid attribute found; skip this character.
                self.stream.advance();
            }
        }

        Ok(Some(attributes))
    }

    #[inline]
    fn add_to_parent(&mut self, handle: NodeHandle) -> Result<(), ParseError> {
        if let Some(last) = self.stack.last() {
            let last = self
                .tags
                .get_mut(last.get_inner() as usize)
                .unwrap()
                .as_tag_mut()
                .unwrap();

            last._children
                .push_handle(handle)
                .map_err(|_| ParseError::ChildCapacityExceeded)?;
        } else {
            push_vec::<NodeHandle, MAX_ROOTS>(
                &mut self.ast,
                handle,
                ParseError::RootCapacityExceeded,
            )?;
        }
        Ok(())
    }

    fn read_end(&mut self) -> Result<(), ParseError> {
        self.stream.advance();

        let closing_tag_name = self.read_to(b'>');

        if asm_core::byte_at_eq(self.stream.data(), self.stream.idx, b'>') {
            self.stream.advance();
        }

        let closing_tag_matches_parent = self
            .stack
            .last()
            .and_then(|last_handle| last_handle.get(self))
            .and_then(|last_item| last_item.as_tag())
            .is_some_and(|last_tag| {
                asm_core::bytes_eq(last_tag.name().as_bytes(), closing_tag_name)
            });

        if !closing_tag_matches_parent {
            return Ok(());
        }

        if let Some(handle) = self.stack.pop() {
            let tag = self
                .tags
                .get_mut(handle.get_inner() as usize)
                .unwrap()
                .as_tag_mut()
                .unwrap();

            let ptr = self.stream.data().as_ptr() as usize;
            let offset = tag._raw.as_ptr() as usize;
            let offset = offset - ptr;

            tag._raw = self.stream.slice(offset, self.stream.idx).into();

            let (track_classes, track_ids) = (
                self.options.is_tracking_classes(),
                self.options.is_tracking_ids(),
            );

            if let (true, Some(bytes)) = (track_classes, &tag._attributes.class) {
                if let Some(class_bytes) = bytes.as_bytes_borrowed() {
                    let mut idx = 0;
                    while let Some((start, len, next)) = asm_core::next_ascii_token(class_bytes, idx)
                    {
                        let key = Bytes::from(&class_bytes[start..start + len]);
                        if let Some(handles) = self.classes.get_bytes_mut(&key) {
                            push_class_handle::<MAX_NODES>(
                                handles,
                                handle,
                                ParseError::ClassCapacityExceeded,
                            )?;
                        } else {
                            let mut handles = ClassVec::<MAX_NODES>::new();
                            push_class_handle::<MAX_NODES>(
                                &mut handles,
                                handle,
                                ParseError::ClassCapacityExceeded,
                            )?;
                            insert_bytes_map::<ClassVec<MAX_NODES>, MAX_CLASSES>(
                                &mut self.classes,
                                key,
                                handles,
                                ParseError::ClassCapacityExceeded,
                            )?;
                        }
                        idx = next;
                    }
                }
            }

            if let (true, Some(bytes)) = (track_ids, &tag._attributes.id) {
                insert_bytes_map::<NodeHandle, MAX_IDS>(
                    &mut self.ids,
                    bytes.clone(),
                    handle,
                    ParseError::IdCapacityExceeded,
                )?;
            }
        }
        Ok(())
    }

    #[cold]
    #[inline(never)]
    fn read_markdown(&mut self) -> Result<Option<()>, ParseError> {
        let start = self.stream.idx - 1; // position of the < which is needed when registering the comment

        self.stream.advance(); // skip !

        let is_comment = self
            .stream
            .slice_len(self.stream.idx, 2)
            .eq(constants::COMMENT);

        if is_comment {
            let comment = self.skip_comment_with_start(start);
            let comment = self.register_tag(Node::Comment(comment.into()))?;
            self.add_to_parent(comment)?;
        } else {
            let Some(tag) = self.read_ident() else {
                return Err(ParseError::UnsupportedAssemblySyntax);
            };

            self.skip_whitespaces();

            if simd::matches_case_insensitive(tag, *b"doctype") {
                let Some(doctype) = self.read_ident() else {
                    return Ok(None);
                };

                let html5 = simd::matches_case_insensitive(doctype, *b"html");

                if html5 {
                    self.version = Some(HTMLVersion::HTML5);
                }

                self.skip_whitespaces();
                self.stream.advance(); // skip >
            } else {
                return Err(ParseError::UnsupportedAssemblySyntax);
            }
        }

        Ok(Some(()))
    }

    fn parse_tag(&mut self) -> Result<Option<()>, ParseError> {
        let start = self.stream.idx;

        self.stream.advance();
        self.skip_whitespaces();
        let Some(cur) = self.stream.current_cpy() else {
            return Ok(None);
        };

        match cur {
            b'/' => self.read_end()?,
            b'!' => {
                self.read_markdown()?;
            }
            _ => {
                let Some(name) = self.read_ident() else {
                    return Ok(None);
                };
                self.skip_whitespaces();

                let Some(attr) = self.parse_attributes()? else {
                    return Ok(None);
                };

                let is_self_closing =
                    asm_core::byte_at_eq(self.stream.data(), self.stream.idx, b'/');
                if is_self_closing {
                    self.stream.advance();
                }

                if !asm_core::byte_at_eq(self.stream.data(), self.stream.idx, b'>') {
                    return Ok(None);
                }
                self.stream.advance();

                let this = self.register_tag(Node::Tag(HTMLTag::new(
                    name.into(),
                    attr,
                    InlineVec::new(),
                    self.stream.slice(start, self.stream.idx).into(),
                )))?;

                self.add_to_parent(this)?;

                // some tags are self closing, so even though there might not be a /,
                // we don't always want to push them to the stack
                // e.g. <br><p>Hello</p>
                // <p> should not be a subtag of <br>
                if !is_self_closing && !asm_core::is_void_tag(name) {
                    push_vec::<NodeHandle, MAX_STACK>(
                        &mut self.stack,
                        this,
                        ParseError::StackCapacityExceeded,
                    )?;
                }
            }
        };

        Ok(Some(()))
    }

    pub(crate) fn parse_single(&mut self) -> Result<Option<()>, ParseError> {
        loop {
            match asm_core::scan_html_event(self.stream.data(), self.stream.idx) {
                (0, _, _) => return Ok(None),
                (1, start, len) => {
                    self.stream.idx = start + len;
                    let raw = Node::Raw(self.stream.slice(start, start + len).into());
                    let handle = self.register_tag(raw)?;
                    self.add_to_parent(handle)?;
                }
                _ => {
                    self.parse_tag()?;
                }
            }
        }
    }

    /// Resolves an internal Node ID obtained from a NodeHandle to a Node
    #[inline]
    pub fn resolve_node_id(&self, id: InnerNodeHandle) -> Option<&Node<'a>> {
        self.tags.get(id as usize)
    }

    /// Resolves an internal Node ID obtained from a NodeHandle to a Node
    #[inline]
    pub fn resolve_node_id_mut(&mut self, id: InnerNodeHandle) -> Option<&mut Node<'a>> {
        self.tags.get_mut(id as usize)
    }

    pub(crate) fn parse(&mut self) -> Result<(), ParseError> {
        if !asm_core::len_fits_u32(self.stream.len()) {
            return Err(ParseError::InvalidLength);
        }

        while !self.stream.is_eof() {
            self.parse_single()?;
        }

        Ok(())
    }
}
