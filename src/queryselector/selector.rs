use crate::{Node, asm_core};

/// A single query selector node
#[derive(Debug, Clone)]
pub enum Selector<'a, const MAX_SELECTOR_NODES: usize = 0> {
    /// Tag selector: foo
    Tag(&'a [u8]),
    /// ID selector: #foo
    Id(&'a [u8]),
    /// Class selector: .foo
    Class(&'a [u8]),
    /// All selector: *
    All,
    /// And combinator: .foo.bar
    And(
        Box<Selector<'a, MAX_SELECTOR_NODES>>,
        Box<Selector<'a, MAX_SELECTOR_NODES>>,
    ),
    /// Or combinator: .foo, .bar
    Or(
        Box<Selector<'a, MAX_SELECTOR_NODES>>,
        Box<Selector<'a, MAX_SELECTOR_NODES>>,
    ),
    /// Descendant combinator: .foo .bar
    Descendant(
        Box<Selector<'a, MAX_SELECTOR_NODES>>,
        Box<Selector<'a, MAX_SELECTOR_NODES>>,
    ),
    /// Parent combinator: .foo > .bar
    Parent(
        Box<Selector<'a, MAX_SELECTOR_NODES>>,
        Box<Selector<'a, MAX_SELECTOR_NODES>>,
    ),
    /// Attribute: \[foo\]
    Attribute(&'a [u8]),
    /// Attribute with value: [foo=bar]
    AttributeValue(&'a [u8], &'a [u8]),
    /// Attribute with whitespace-separated list of values that contains a value: [foo~=bar]
    AttributeValueWhitespacedContains(&'a [u8], &'a [u8]),
    /// Attribute with value that starts with: [foo^=bar]
    AttributeValueStartsWith(&'a [u8], &'a [u8]),
    /// Attribute with value that ends with: [foo$=bar]
    AttributeValueEndsWith(&'a [u8], &'a [u8]),
    /// Attribute with value that contains: [foo*=bar]
    AttributeValueSubstring(&'a [u8], &'a [u8]),
}

impl<'a, const MAX_SELECTOR_NODES: usize> Selector<'a, MAX_SELECTOR_NODES> {
    /// Checks if the given node matches this selector
    pub fn matches<'b>(&self, node: &Node<'b>) -> bool {
        match self {
            Self::Tag(tag) => node
                .as_tag()
                .is_some_and(|t| asm_core::bytes_eq(t._name.as_bytes(), tag)),
            Self::Id(id) => node.as_tag().is_some_and(|t| {
                t._attributes
                    .id
                    .as_ref()
                    .is_some_and(|attr| asm_core::bytes_eq(attr.as_bytes(), id))
            }),
            Self::Class(class) => node
                .as_tag()
                .is_some_and(|t| t._attributes.is_class_member(*class)),
            Self::And(a, b) => a.matches(node) && b.matches(node),
            Self::Or(a, b) => a.matches(node) || b.matches(node),
            Self::All => true,
            Self::Attribute(attribute) => node
                .as_tag()
                .is_some_and(|t| t._attributes.get(*attribute).is_some()),
            Self::AttributeValue(attribute, value) => {
                check_attribute(node, attribute, value, asm_core::bytes_eq)
            }
            Self::AttributeValueEndsWith(attribute, value) => {
                check_attribute(node, attribute, value, asm_core::ends_with)
            }
            Self::AttributeValueStartsWith(attribute, value) => {
                check_attribute(node, attribute, value, asm_core::starts_with)
            }
            Self::AttributeValueSubstring(attribute, value) => {
                check_attribute(node, attribute, value, asm_core::contains_bytes)
            }
            Self::AttributeValueWhitespacedContains(attribute, value) => check_attribute(
                node,
                attribute,
                value,
                asm_core::contains_ascii_whitespace_token,
            ),
            _ => false,
        }
    }
}

fn check_attribute<F>(node: &Node, attribute: &[u8], value: &[u8], callback: F) -> bool
where
    F: Fn(&[u8], &[u8]) -> bool,
{
    node.as_tag().is_some_and(|t| {
        t._attributes
            .get(attribute)
            .flatten()
            .is_some_and(|attr| callback(attr.as_bytes(), value))
    })
}
