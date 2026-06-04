use crate::Bytes;
use crate::InnerNodeHandle;
#[cfg(feature = "std")]
use crate::ParserOptions;
use crate::errors::ParseError;
#[cfg(feature = "std")]
use crate::inline::vec::InlineVecIter;
use crate::parser::HTMLVersion;
use crate::parser::NodeHandle;
use crate::queryselector;
use crate::queryselector::QuerySelectorIterator;
use crate::{Node, Parser};
use core::fmt;
#[cfg(feature = "std")]
use core::marker::PhantomData;

/// VDom represents a [Document Object Model](https://developer.mozilla.org/en/docs/Web/API/Document_Object_Model)
///
/// It is the result of parsing an HTML document.
/// Internally it is only a wrapper around the [`Parser`] struct, in which all of the HTML tags are stored.
/// Many functions of the public API take a reference to a [`Parser`] as a parameter to resolve [`NodeHandle`]s to [`Node`]s.
#[derive(Debug)]
pub struct VDom<
    'a,
    const MAX_NODES: usize = 0,
    const MAX_STACK: usize = 0,
    const MAX_ROOTS: usize = 0,
    const MAX_IDS: usize = 0,
    const MAX_CLASSES: usize = 0,
    const MAX_SELECTOR_NODES: usize = 0,
> {
    /// Internal parser
    parser: Parser<'a, MAX_NODES, MAX_STACK, MAX_ROOTS, MAX_IDS, MAX_CLASSES, MAX_SELECTOR_NODES>,
}

impl<
    'a,
    const MAX_NODES: usize,
    const MAX_STACK: usize,
    const MAX_ROOTS: usize,
    const MAX_IDS: usize,
    const MAX_CLASSES: usize,
    const MAX_SELECTOR_NODES: usize,
> From<Parser<'a, MAX_NODES, MAX_STACK, MAX_ROOTS, MAX_IDS, MAX_CLASSES, MAX_SELECTOR_NODES>>
    for VDom<'a, MAX_NODES, MAX_STACK, MAX_ROOTS, MAX_IDS, MAX_CLASSES, MAX_SELECTOR_NODES>
{
    fn from(
        parser: Parser<
            'a,
            MAX_NODES,
            MAX_STACK,
            MAX_ROOTS,
            MAX_IDS,
            MAX_CLASSES,
            MAX_SELECTOR_NODES,
        >,
    ) -> Self {
        Self { parser }
    }
}

impl<
    'a,
    const MAX_NODES: usize,
    const MAX_STACK: usize,
    const MAX_ROOTS: usize,
    const MAX_IDS: usize,
    const MAX_CLASSES: usize,
    const MAX_SELECTOR_NODES: usize,
> VDom<'a, MAX_NODES, MAX_STACK, MAX_ROOTS, MAX_IDS, MAX_CLASSES, MAX_SELECTOR_NODES>
{
    /// Returns a reference to the underlying parser
    #[inline]
    pub fn parser(
        &self,
    ) -> &Parser<'a, MAX_NODES, MAX_STACK, MAX_ROOTS, MAX_IDS, MAX_CLASSES, MAX_SELECTOR_NODES>
    {
        &self.parser
    }

    /// Returns a mutable reference to the underlying parser
    #[inline]
    pub fn parser_mut(
        &mut self,
    ) -> &mut Parser<'a, MAX_NODES, MAX_STACK, MAX_ROOTS, MAX_IDS, MAX_CLASSES, MAX_SELECTOR_NODES>
    {
        &mut self.parser
    }

    /// Finds an element by its `id` attribute.
    pub fn get_element_by_id<'b, S>(&'b self, id: S) -> Option<NodeHandle>
    where
        S: Into<Bytes<'a>>,
    {
        let bytes: Bytes = id.into();
        let parser = self.parser();

        if parser.options.is_tracking_ids() {
            parser.ids.get(&bytes).copied()
        } else {
            self.nodes()
                .iter()
                .enumerate()
                .find(|(_, node)| {
                    node.as_tag().is_some_and(|tag| {
                        tag._attributes.id.as_ref().is_some_and(|x| x.eq(&bytes))
                    })
                })
                .map(|(id, _)| NodeHandle::new(id as InnerNodeHandle))
        }
    }

    /// Returns a slice of *all* the elements in the HTML document
    ///
    /// The difference between `children()` and `nodes()` is that children only returns the immediate children of the root node,
    /// while `nodes()` returns all nodes, including nested tags.
    ///
    /// # Order
    /// The order of the returned nodes is the same as the order of the nodes in the HTML document.
    pub fn nodes(&self) -> &[Node<'a>] {
        self.parser.tags.as_slice()
    }

    /// Returns a mutable slice of *all* the elements in the HTML document
    ///
    /// The difference between `children()` and `nodes()` is that children only returns the immediate children of the root node,
    /// while `nodes()` returns all nodes, including nested tags.
    pub fn nodes_mut(&mut self) -> &mut [Node<'a>] {
        self.parser.tags.as_mut_slice()
    }

    /// Returns the topmost subnodes ("children") of this DOM
    pub fn children(&self) -> &[NodeHandle] {
        self.parser.ast.as_slice()
    }

    /// Returns a mutable reference to the topmost subnodes ("children") of this DOM
    pub fn children_mut(&mut self) -> &mut [NodeHandle] {
        self.parser.ast.as_mut_slice()
    }

    /// Returns the HTML version.
    /// This is determined by the `<!DOCTYPE>` tag
    pub fn version(&self) -> Option<HTMLVersion> {
        self.parser.version
    }

    /// Writes the contained markup of all root elements without allocating.
    pub fn write_outer_html<W: fmt::Write>(&self, dest: &mut W) -> fmt::Result {
        for handle in self.children() {
            if let Some(node) = handle.get(&self.parser) {
                node.write_outer_html(&self.parser, dest)?;
            }
        }

        Ok(())
    }

    /// Tries to parse the query selector and returns an iterator over matching elements.
    #[cfg(not(feature = "std"))]
    pub fn query_selector<'b>(
        &'b self,
        selector: &'b str,
    ) -> Result<
        QuerySelectorIterator<
            'a,
            'b,
            Self,
            MAX_NODES,
            MAX_STACK,
            MAX_ROOTS,
            MAX_IDS,
            MAX_CLASSES,
            MAX_SELECTOR_NODES,
        >,
        ParseError,
    > {
        let selector = crate::parse_query_selector::<MAX_SELECTOR_NODES>(selector)?;
        Ok(queryselector::QuerySelectorIterator::new(
            selector,
            self.parser(),
            self,
        ))
    }
}

#[cfg(feature = "std")]
impl<
    'a,
    const MAX_NODES: usize,
    const MAX_STACK: usize,
    const MAX_ROOTS: usize,
    const MAX_IDS: usize,
    const MAX_CLASSES: usize,
> VDom<'a, MAX_NODES, MAX_STACK, MAX_ROOTS, MAX_IDS, MAX_CLASSES, 0>
{
    /// Returns a list of elements that match a given class name.
    pub fn get_elements_by_class_name<'b>(
        &'b self,
        id: &'b str,
    ) -> ClassNameIterator<'a, 'b, MAX_NODES> {
        let parser = self.parser();

        if parser.options.is_tracking_classes() {
            parser
                .classes
                .get(&Bytes::from(id.as_bytes()))
                .map(|handles| ClassNameIterator::Tracked(handles.iter()))
                .unwrap_or_else(|| ClassNameIterator::Empty)
        } else {
            ClassNameIterator::Scan {
                member: id,
                iter: self.nodes().iter().enumerate(),
            }
        }
    }

    /// Returns the contained markup of all of the elements in this DOM.
    pub fn outer_html(&self) -> String {
        let mut inner_html = String::with_capacity(self.parser.stream.len());

        for node in self.children() {
            let node = node.get(&self.parser).unwrap();
            let _ = node.write_outer_html(&self.parser, &mut inner_html);
        }

        inner_html
    }

    /// Tries to parse the query selector and returns an iterator over elements that match the given query selector.
    pub fn query_selector<'b>(
        &'b self,
        selector: &'b str,
    ) -> Option<
        QuerySelectorIterator<
            'a,
            'b,
            Self,
            MAX_NODES,
            MAX_STACK,
            MAX_ROOTS,
            MAX_IDS,
            MAX_CLASSES,
            0,
        >,
    > {
        let selector = crate::parse_query_selector(selector)?;
        let iter = queryselector::QuerySelectorIterator::new(selector, self.parser(), self);
        Some(iter)
    }
}

/// Iterator returned by [`VDom::get_elements_by_class_name`].
#[cfg(feature = "std")]
pub enum ClassNameIterator<'a, 'b, const MAX_NODES: usize = 0> {
    /// No matching tracked class exists.
    Empty,
    /// Iterates over a tracked class lookup table.
    Tracked(InlineVecIter<'b, NodeHandle, MAX_NODES>),
    /// Scans every node when class tracking was not enabled.
    Scan {
        member: &'b str,
        iter: core::iter::Enumerate<core::slice::Iter<'b, Node<'a>>>,
    },
}

#[cfg(feature = "std")]
impl<'a, 'b, const MAX_NODES: usize> Iterator for ClassNameIterator<'a, 'b, MAX_NODES> {
    type Item = NodeHandle;

    fn next(&mut self) -> Option<Self::Item> {
        match self {
            Self::Empty => None,
            Self::Tracked(iter) => iter.next().copied(),
            Self::Scan { member, iter } => iter.find_map(|(id, node)| {
                node.as_tag().and_then(|tag| {
                    tag._attributes
                        .is_class_member(*member)
                        .then(|| NodeHandle::new(id as InnerNodeHandle))
                })
            }),
        }
    }
}

/// A RAII guarded version of VDom
///
/// The input string is freed once this struct goes out of scope.
/// The only way to construct this is by calling `parse_owned()`.
#[derive(Debug)]
#[cfg(feature = "std")]
pub struct VDomGuard {
    /// Wrapped VDom instance
    dom: VDom<
        'static,
        { crate::STD_INLINE_CLASS_HANDLES },
        0,
        0,
        { crate::STD_INLINE_IDS },
        { crate::STD_INLINE_CLASSES },
        0,
    >,
    /// The leaked input string that is referenced by self.dom
    _s: RawString,
    /// PhantomData for self.dom
    _phantom: PhantomData<&'static str>,
}

#[cfg(feature = "std")]
unsafe impl Send for VDomGuard {}
#[cfg(feature = "std")]
unsafe impl Sync for VDomGuard {}

#[cfg(feature = "std")]
impl VDomGuard {
    /// Parses the input string
    pub(crate) fn parse(input: String, options: ParserOptions) -> Result<VDomGuard, ParseError> {
        let input = RawString::new(input);

        let ptr = input.as_ptr();

        let input_ref: &'static str = unsafe { &*ptr };

        // Parsing will either:
        // a) succeed, and we return a VDom instance
        //    that, when dropped, will free the input string
        // b) fail, and we return a ParseError
        //    and `RawString`s destructor will run and deallocate the string properly
        let mut parser = Parser::<
            { crate::STD_INLINE_CLASS_HANDLES },
            0,
            0,
            { crate::STD_INLINE_IDS },
            { crate::STD_INLINE_CLASSES },
            0,
        >::new(input_ref, options);
        parser.parse()?;

        Ok(Self {
            _s: input,
            dom: VDom::from(parser),
            _phantom: PhantomData,
        })
    }
}

#[cfg(feature = "std")]
impl VDomGuard {
    /// Returns a reference to the inner DOM.
    ///
    /// The lifetime of the returned `VDom` is bound to self so that elements cannot outlive this `VDomGuard` struct.
    pub fn get_ref<'a>(
        &'a self,
    ) -> &'a VDom<
        'a,
        { crate::STD_INLINE_CLASS_HANDLES },
        0,
        0,
        { crate::STD_INLINE_IDS },
        { crate::STD_INLINE_CLASSES },
        0,
    > {
        &self.dom
    }

    /// Returns a mutable reference to the inner DOM.
    ///
    /// The lifetime of the returned `VDom` is bound to self so that elements cannot outlive this `VDomGuard` struct.
    pub fn get_mut_ref<'a, 'b: 'a>(
        &'b mut self,
    ) -> &'b VDom<
        'a,
        { crate::STD_INLINE_CLASS_HANDLES },
        0,
        0,
        { crate::STD_INLINE_IDS },
        { crate::STD_INLINE_CLASSES },
        0,
    > {
        &mut self.dom
    }
}

#[derive(Debug)]
#[cfg(feature = "std")]
struct RawString(*mut str);

#[cfg(feature = "std")]
impl RawString {
    pub fn new(s: String) -> Self {
        Self(Box::into_raw(s.into_boxed_str()))
    }

    pub fn as_ptr(&self) -> *mut str {
        self.0
    }
}

#[cfg(feature = "std")]
impl Drop for RawString {
    fn drop(&mut self) {
        // SAFETY: the pointer is always valid because `RawString` can only be constructed through `RawString::new()`
        unsafe {
            drop(Box::from_raw(self.0));
        };
    }
}
