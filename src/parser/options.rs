use crate::asm_core;

mod flags {
    pub const TRACK_IDS: u8 = 1 << 0;
    pub const TRACK_CLASSES: u8 = 1 << 1;
}

/// Options for the HTML Parser
///
/// This allows users of this library to configure the parser.
/// The default options (`ParserOptions::default()`) are optimized for raw parsing.
/// If you need to do HTML tag lookups by ID or class names, you can enable tracking.
/// This will cache HTML nodes as they appear in the source code on the fly.
#[derive(Debug, Copy, Clone, PartialEq, Default)]
pub struct ParserOptions {
    flags: u8,
}

impl ParserOptions {
    /// Creates a new [ParserOptions] with no flags set
    pub fn new() -> Self {
        Self::default()
    }

    /// Creates a [ParserOptions] from a bitset
    pub fn from_raw_checked(flags: u8) -> Option<Self> {
        asm_core::parser_flags_valid(flags).then_some(Self { flags })
    }

    /// Returns the raw flags of this bitset
    pub fn to_raw(&self) -> u8 {
        self.flags
    }

    fn set_flag(&mut self, flag: u8) {
        self.flags = asm_core::parser_set_flag(self.flags, flag);
    }

    /// Enables tracking of HTML Tag IDs and stores them in a lookup table.
    ///
    /// This makes `get_element_by_id()` lookups ~O(1)
    pub fn track_ids(mut self) -> Self {
        self.set_flag(flags::TRACK_IDS);
        self
    }

    /// Enables tracking of HTML Tag classes and stores them in a lookup table.
    ///
    /// This makes `get_elements_by_class_name()` lookups ~O(1)
    pub fn track_classes(mut self) -> Self {
        self.set_flag(flags::TRACK_CLASSES);
        self
    }

    /// Returns whether the parser is tracking HTML Tag IDs.
    #[inline]
    pub fn is_tracking_ids(&self) -> bool {
        asm_core::parser_is_tracking_ids(self.flags)
    }

    /// Returns whether the parser is tracking HTML Tag classes.
    #[inline]
    pub fn is_tracking_classes(&self) -> bool {
        asm_core::parser_is_tracking_classes(self.flags)
    }

    /// Returns whether the parser is tracking HTML Tag IDs or classes (previously enabled by a call to `track_ids()` or `track_classes()`).
    #[inline]
    pub fn is_tracking(&self) -> bool {
        asm_core::parser_is_tracking(self.flags)
    }
}
