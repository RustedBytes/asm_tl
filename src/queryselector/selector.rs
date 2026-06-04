use crate::Node;

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
    #[cfg(feature = "std")]
    And(
        Box<Selector<'a, MAX_SELECTOR_NODES>>,
        Box<Selector<'a, MAX_SELECTOR_NODES>>,
    ),
    /// Or combinator: .foo, .bar
    #[cfg(feature = "std")]
    Or(
        Box<Selector<'a, MAX_SELECTOR_NODES>>,
        Box<Selector<'a, MAX_SELECTOR_NODES>>,
    ),
    /// Descendant combinator: .foo .bar
    #[cfg(feature = "std")]
    Descendant(
        Box<Selector<'a, MAX_SELECTOR_NODES>>,
        Box<Selector<'a, MAX_SELECTOR_NODES>>,
    ),
    /// Parent combinator: .foo > .bar
    #[cfg(feature = "std")]
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
            Self::Tag(tag) => node.as_tag().is_some_and(|t| t._name.as_bytes().eq(*tag)),
            Self::Id(id) => node
                .as_tag()
                .is_some_and(|t| t._attributes.id == Some((*id).into())),
            Self::Class(class) => node
                .as_tag()
                .is_some_and(|t| t._attributes.is_class_member(*class)),
            #[cfg(feature = "std")]
            Self::And(a, b) => a.matches(node) && b.matches(node),
            #[cfg(feature = "std")]
            Self::Or(a, b) => a.matches(node) || b.matches(node),
            Self::All => true,
            Self::Attribute(attribute) => node
                .as_tag()
                .is_some_and(|t| t._attributes.get(*attribute).is_some()),
            Self::AttributeValue(attribute, value) => {
                check_attribute(node, attribute, value, |attr, value| attr == value)
            }
            Self::AttributeValueEndsWith(attribute, value) => {
                check_attribute(node, attribute, value, |attr, value| attr.ends_with(value))
            }
            Self::AttributeValueStartsWith(attribute, value) => {
                check_attribute(node, attribute, value, |attr, value| {
                    attr.starts_with(value)
                })
            }
            Self::AttributeValueSubstring(attribute, value) => {
                check_attribute(node, attribute, value, |attr, value| attr.contains(value))
            }
            Self::AttributeValueWhitespacedContains(attribute, value) => {
                check_attribute(node, attribute, value, |attr, value| {
                    attr.split_whitespace().any(|x| x == value)
                })
            }
            #[cfg(feature = "std")]
            _ => false,
        }
    }
}

fn check_attribute<F>(node: &Node, attribute: &[u8], value: &[u8], callback: F) -> bool
where
    F: Fn(&str, &str) -> bool,
{
    let Ok(value) = core::str::from_utf8(value) else {
        return false;
    };
    node.as_tag().is_some_and(|t| {
        t._attributes
            .get(attribute)
            .flatten()
            .and_then(|attr| attr.try_as_utf8_str())
            .is_some_and(|attr| callback(attr, value))
    })
}
