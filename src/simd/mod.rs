use crate::asm_core;

#[allow(dead_code)]
mod fallback;

#[cfg(feature = "portable-simd")]
mod portable;

/// Checks if the given byte is a "closing" byte (/ or >)
#[inline]
pub fn is_closing(needle: u8) -> bool {
    asm_core::is_closing(needle)
}

/// Searches for the first non-identifier in `haystack`
#[inline]
pub fn search_non_ident(haystack: &[u8]) -> Option<usize> {
    asm_core::search_non_ident(haystack)
}

/// Searches for the first occurrence of any of 3 bytes in `haystack`
#[inline]
pub fn find3(haystack: &[u8], needle: [u8; 3]) -> Option<usize> {
    asm_core::find3(haystack, needle)
}

/// Searches for the first occurence of `needle` in `haystack`
#[inline]
pub fn find(haystack: &[u8], needle: u8) -> Option<usize> {
    asm_core::find(haystack, needle)
}

/// Checks if the ASCII characters in `haystack` match `needle` (case insensitive)
pub fn matches_case_insensitive<const N: usize>(haystack: &[u8], needle: [u8; N]) -> bool {
    if haystack.len() != N {
        return false;
    }

    asm_core::matches_case_insensitive(haystack, &needle)
}
