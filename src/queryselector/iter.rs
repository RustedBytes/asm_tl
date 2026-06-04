use core::marker::PhantomData;

use crate::{NodeHandle, Parser};

use super::{Selector, iterable::QueryIterable};

/// A query selector iterator that yields matching HTML nodes
pub struct QuerySelectorIterator<
    'a,
    'b,
    Q: QueryIterable<'a, MAX_NODES, MAX_STACK, MAX_ROOTS, MAX_IDS, MAX_CLASSES, MAX_SELECTOR_NODES>,
    const MAX_NODES: usize = 0,
    const MAX_STACK: usize = 0,
    const MAX_ROOTS: usize = 0,
    const MAX_IDS: usize = 0,
    const MAX_CLASSES: usize = 0,
    const MAX_SELECTOR_NODES: usize = 0,
> {
    selector: Selector<'b, MAX_SELECTOR_NODES>,
    collection: &'b Q,
    parser:
        &'b Parser<'a, MAX_NODES, MAX_STACK, MAX_ROOTS, MAX_IDS, MAX_CLASSES, MAX_SELECTOR_NODES>,
    index: usize,
    len: usize,
    _a: PhantomData<&'a ()>,
}

impl<
    'a,
    'b,
    Q: QueryIterable<'a, MAX_NODES, MAX_STACK, MAX_ROOTS, MAX_IDS, MAX_CLASSES, MAX_SELECTOR_NODES>,
    const MAX_NODES: usize,
    const MAX_STACK: usize,
    const MAX_ROOTS: usize,
    const MAX_IDS: usize,
    const MAX_CLASSES: usize,
    const MAX_SELECTOR_NODES: usize,
> Clone
    for QuerySelectorIterator<
        'a,
        'b,
        Q,
        MAX_NODES,
        MAX_STACK,
        MAX_ROOTS,
        MAX_IDS,
        MAX_CLASSES,
        MAX_SELECTOR_NODES,
    >
{
    fn clone(&self) -> Self {
        Self {
            selector: self.selector.clone(),
            collection: self.collection,
            parser: self.parser,
            index: self.index,
            len: self.len,
            _a: PhantomData,
        }
    }
}

impl<
    'a,
    'b,
    Q: QueryIterable<'a, MAX_NODES, MAX_STACK, MAX_ROOTS, MAX_IDS, MAX_CLASSES, MAX_SELECTOR_NODES>,
    const MAX_NODES: usize,
    const MAX_STACK: usize,
    const MAX_ROOTS: usize,
    const MAX_IDS: usize,
    const MAX_CLASSES: usize,
    const MAX_SELECTOR_NODES: usize,
>
    QuerySelectorIterator<
        'a,
        'b,
        Q,
        MAX_NODES,
        MAX_STACK,
        MAX_ROOTS,
        MAX_IDS,
        MAX_CLASSES,
        MAX_SELECTOR_NODES,
    >
{
    /// Creates a new query selector iterator
    pub fn new(
        selector: Selector<'b, MAX_SELECTOR_NODES>,
        parser: &'b Parser<
            'a,
            MAX_NODES,
            MAX_STACK,
            MAX_ROOTS,
            MAX_IDS,
            MAX_CLASSES,
            MAX_SELECTOR_NODES,
        >,
        collection: &'b Q,
    ) -> Self {
        Self {
            selector,
            collection,
            index: 0,
            len: collection.len(parser),
            parser,
            _a: PhantomData,
        }
    }
}

impl<
    'a,
    'b,
    Q: QueryIterable<'a, MAX_NODES, MAX_STACK, MAX_ROOTS, MAX_IDS, MAX_CLASSES, MAX_SELECTOR_NODES>,
    const MAX_NODES: usize,
    const MAX_STACK: usize,
    const MAX_ROOTS: usize,
    const MAX_IDS: usize,
    const MAX_CLASSES: usize,
    const MAX_SELECTOR_NODES: usize,
> Iterator
    for QuerySelectorIterator<
        'a,
        'b,
        Q,
        MAX_NODES,
        MAX_STACK,
        MAX_ROOTS,
        MAX_IDS,
        MAX_CLASSES,
        MAX_SELECTOR_NODES,
    >
{
    type Item = NodeHandle;

    fn next(&mut self) -> Option<Self::Item> {
        while self.index < self.len {
            let node = self.collection.get(self.parser, self.index);
            self.index += 1;
            if let Some((node, id)) = node {
                let matches = self.selector.matches(node);

                if matches {
                    return Some(id);
                }
            }
        }

        None
    }
}
