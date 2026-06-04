use crate::{HTMLTag, InnerNodeHandle, Node, NodeHandle, Parser, VDom};

mod private {
    pub trait Sealed {}
}

/// Trait for types that a query selector can iterate over
pub trait QueryIterable<
    'a,
    const MAX_NODES: usize = 0,
    const MAX_STACK: usize = 0,
    const MAX_ROOTS: usize = 0,
    const MAX_IDS: usize = 0,
    const MAX_CLASSES: usize = 0,
    const MAX_SELECTOR_NODES: usize = 0,
>: private::Sealed
{
    /// Gets a node at a specific index
    fn get<'b>(
        &'b self,
        parser: &'b Parser<
            'a,
            MAX_NODES,
            MAX_STACK,
            MAX_ROOTS,
            MAX_IDS,
            MAX_CLASSES,
            MAX_SELECTOR_NODES,
        >,
        index: usize,
    ) -> Option<(&'b Node<'a>, NodeHandle)>;
    /// Gets or computes the length (number of nodes)
    fn len(
        &self,
        parser: &Parser<
            'a,
            MAX_NODES,
            MAX_STACK,
            MAX_ROOTS,
            MAX_IDS,
            MAX_CLASSES,
            MAX_SELECTOR_NODES,
        >,
    ) -> usize;
    /// Gets the starting index
    fn start(&self) -> Option<InnerNodeHandle>;
}

impl<
    'a,
    const MAX_NODES: usize,
    const MAX_STACK: usize,
    const MAX_ROOTS: usize,
    const MAX_IDS: usize,
    const MAX_CLASSES: usize,
    const MAX_SELECTOR_NODES: usize,
> private::Sealed
    for VDom<'a, MAX_NODES, MAX_STACK, MAX_ROOTS, MAX_IDS, MAX_CLASSES, MAX_SELECTOR_NODES>
{
}
impl<
    'a,
    const MAX_NODES: usize,
    const MAX_STACK: usize,
    const MAX_ROOTS: usize,
    const MAX_IDS: usize,
    const MAX_CLASSES: usize,
    const MAX_SELECTOR_NODES: usize,
> QueryIterable<'a, MAX_NODES, MAX_STACK, MAX_ROOTS, MAX_IDS, MAX_CLASSES, MAX_SELECTOR_NODES>
    for VDom<'a, MAX_NODES, MAX_STACK, MAX_ROOTS, MAX_IDS, MAX_CLASSES, MAX_SELECTOR_NODES>
{
    #[inline]
    fn get<'b>(
        &'b self,
        parser: &'b Parser<
            'a,
            MAX_NODES,
            MAX_STACK,
            MAX_ROOTS,
            MAX_IDS,
            MAX_CLASSES,
            MAX_SELECTOR_NODES,
        >,
        index: usize,
    ) -> Option<(&'b Node<'a>, NodeHandle)> {
        // In a VDom, the index is equal to the node's id
        // and as such, we can recreate a `NodeHandle` from that ID
        parser
            .tags
            .as_slice()
            .get(index)
            .map(|node| (node, NodeHandle::new(index as u32)))
    }

    #[inline]
    fn len(
        &self,
        _parser: &Parser<
            'a,
            MAX_NODES,
            MAX_STACK,
            MAX_ROOTS,
            MAX_IDS,
            MAX_CLASSES,
            MAX_SELECTOR_NODES,
        >,
    ) -> usize {
        self.parser().tags.len()
    }

    #[inline]
    fn start(&self) -> Option<InnerNodeHandle> {
        // The starting ID is always 0 in a VDom
        Some(0)
    }
}

impl<'a> private::Sealed for HTMLTag<'a> {}
impl<
    'a,
    const MAX_NODES: usize,
    const MAX_STACK: usize,
    const MAX_ROOTS: usize,
    const MAX_IDS: usize,
    const MAX_CLASSES: usize,
    const MAX_SELECTOR_NODES: usize,
> QueryIterable<'a, MAX_NODES, MAX_STACK, MAX_ROOTS, MAX_IDS, MAX_CLASSES, MAX_SELECTOR_NODES>
    for HTMLTag<'a>
{
    #[inline]
    fn get<'b>(
        &'b self,
        parser: &'b Parser<
            'a,
            MAX_NODES,
            MAX_STACK,
            MAX_ROOTS,
            MAX_IDS,
            MAX_CLASSES,
            MAX_SELECTOR_NODES,
        >,
        index: usize,
    ) -> Option<(&'b Node<'a>, NodeHandle)> {
        // Add `index` to the starting ID to get the ID of the node we need
        let index = self.children().start().map(|h| h as usize + index)?;
        let handle = NodeHandle::new(index as u32);
        let node = parser.tags.get(index)?;
        Some((node, handle))
    }

    #[inline]
    fn len(
        &self,
        parser: &Parser<
            'a,
            MAX_NODES,
            MAX_STACK,
            MAX_ROOTS,
            MAX_IDS,
            MAX_CLASSES,
            MAX_SELECTOR_NODES,
        >,
    ) -> usize {
        if let Some((start, end)) = self.children().boundaries(parser) {
            ((end - start) + 1) as usize
        } else {
            0
        }
    }

    #[inline]
    fn start(&self) -> Option<InnerNodeHandle> {
        self.children().start()
    }
}
