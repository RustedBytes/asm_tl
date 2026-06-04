use core::fmt;
#[cfg(feature = "std")]
use std::error::Error;

/// An error that occurred during parsing
#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord)]
pub enum ParseError {
    /// The input string length was too large to fit in a `u32`
    InvalidLength,
    /// The configured node capacity was exceeded
    NodeCapacityExceeded,
    /// The configured stack capacity was exceeded
    StackCapacityExceeded,
    /// The configured root-node capacity was exceeded
    RootCapacityExceeded,
    /// The configured attribute capacity was exceeded
    AttributeCapacityExceeded,
    /// The configured child capacity was exceeded
    ChildCapacityExceeded,
    /// The configured ID index capacity was exceeded
    IdCapacityExceeded,
    /// The configured class index capacity was exceeded
    ClassCapacityExceeded,
    /// The configured query selector capacity was exceeded
    SelectorCapacityExceeded,
    /// The input uses syntax outside of the current assembly parser milestone
    UnsupportedAssemblySyntax,
}

impl fmt::Display for ParseError {
    fn fmt(&self, f: &mut fmt::Formatter) -> Result<(), fmt::Error> {
        match self {
            ParseError::InvalidLength => {
                write!(f, "The input string length is too large to fit in a `u32`")
            }
            ParseError::NodeCapacityExceeded => {
                write!(f, "The configured node capacity was exceeded")
            }
            ParseError::StackCapacityExceeded => {
                write!(f, "The configured stack capacity was exceeded")
            }
            ParseError::RootCapacityExceeded => {
                write!(f, "The configured root-node capacity was exceeded")
            }
            ParseError::AttributeCapacityExceeded => {
                write!(f, "The configured attribute capacity was exceeded")
            }
            ParseError::ChildCapacityExceeded => {
                write!(f, "The configured child capacity was exceeded")
            }
            ParseError::IdCapacityExceeded => {
                write!(f, "The configured ID index capacity was exceeded")
            }
            ParseError::ClassCapacityExceeded => {
                write!(f, "The configured class index capacity was exceeded")
            }
            ParseError::SelectorCapacityExceeded => {
                write!(f, "The configured query selector capacity was exceeded")
            }
            ParseError::UnsupportedAssemblySyntax => {
                write!(
                    f,
                    "The input uses syntax outside of the current assembly parser milestone"
                )
            }
        }
    }
}

#[cfg(feature = "std")]
impl Error for ParseError {}

/// An error that occurred during a call to `Bytes::set`
#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord)]
pub enum SetBytesError {
    /// The length of the given data would overflow a `u32`
    LengthOverflow,
}

impl fmt::Display for SetBytesError {
    fn fmt(&self, f: &mut fmt::Formatter) -> Result<(), fmt::Error> {
        match self {
            SetBytesError::LengthOverflow => {
                write!(f, "The string length is too large to fit in a `u32`")
            }
        }
    }
}

#[cfg(feature = "std")]
impl Error for SetBytesError {}
