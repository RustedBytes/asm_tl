#[cfg(not(all(target_arch = "x86_64", target_os = "linux")))]
compile_error!("rustedbytes-tl assembly core currently supports only x86_64 Linux");

unsafe extern "C" {
    fn rbtl_asm_find(ptr: *const u8, len: usize, needle: u8) -> usize;
    fn rbtl_asm_find3(ptr: *const u8, len: usize, n0: u8, n1: u8, n2: u8) -> usize;
    fn rbtl_asm_search_non_ident(ptr: *const u8, len: usize) -> usize;
    fn rbtl_asm_validate_subset(ptr: *const u8, len: usize) -> u32;
    fn rbtl_asm_selector_kind(ptr: *const u8, len: usize) -> u32;
    fn rbtl_asm_matches_case_insensitive(haystack: *const u8, needle: *const u8, len: usize)
    -> u32;
    fn rbtl_asm_is_closing(byte: u8) -> u32;
    fn rbtl_asm_count_while2(ptr: *const u8, len: usize, n0: u8, n1: u8) -> usize;
    fn rbtl_asm_is_void_tag(ptr: *const u8, len: usize) -> u32;
    fn rbtl_asm_bytes_eq(left: *const u8, right: *const u8, len: usize) -> u32;
    fn rbtl_asm_contains_ascii_whitespace_token(
        haystack: *const u8,
        haystack_len: usize,
        needle: *const u8,
        needle_len: usize,
    ) -> u32;
    fn rbtl_asm_count_spaces(ptr: *const u8, len: usize) -> usize;
    fn rbtl_asm_starts_with(
        haystack: *const u8,
        haystack_len: usize,
        needle: *const u8,
        needle_len: usize,
    ) -> u32;
    fn rbtl_asm_ends_with(
        haystack: *const u8,
        haystack_len: usize,
        needle: *const u8,
        needle_len: usize,
    ) -> u32;
    fn rbtl_asm_contains_bytes(
        haystack: *const u8,
        haystack_len: usize,
        needle: *const u8,
        needle_len: usize,
    ) -> u32;
}

#[inline]
pub(crate) fn find(haystack: &[u8], needle: u8) -> Option<usize> {
    let idx = unsafe { rbtl_asm_find(haystack.as_ptr(), haystack.len(), needle) };
    (idx != haystack.len()).then_some(idx)
}

#[inline]
pub(crate) fn find3(haystack: &[u8], needle: [u8; 3]) -> Option<usize> {
    let idx = unsafe {
        rbtl_asm_find3(
            haystack.as_ptr(),
            haystack.len(),
            needle[0],
            needle[1],
            needle[2],
        )
    };
    (idx != haystack.len()).then_some(idx)
}

#[inline]
pub(crate) fn search_non_ident(haystack: &[u8]) -> Option<usize> {
    let idx = unsafe { rbtl_asm_search_non_ident(haystack.as_ptr(), haystack.len()) };
    (idx != haystack.len()).then_some(idx)
}

#[inline]
pub(crate) fn validate_subset(input: &[u8]) -> bool {
    unsafe { rbtl_asm_validate_subset(input.as_ptr(), input.len()) == 0 }
}

#[inline]
pub(crate) fn selector_kind(input: &[u8]) -> u32 {
    unsafe { rbtl_asm_selector_kind(input.as_ptr(), input.len()) }
}

#[inline]
pub(crate) fn matches_case_insensitive(haystack: &[u8], needle: &[u8]) -> bool {
    debug_assert_eq!(haystack.len(), needle.len());
    unsafe {
        rbtl_asm_matches_case_insensitive(haystack.as_ptr(), needle.as_ptr(), haystack.len()) != 0
    }
}

#[inline]
pub(crate) fn is_closing(byte: u8) -> bool {
    unsafe { rbtl_asm_is_closing(byte) != 0 }
}

#[inline]
pub(crate) fn count_while2(haystack: &[u8], needle: [u8; 2]) -> usize {
    unsafe { rbtl_asm_count_while2(haystack.as_ptr(), haystack.len(), needle[0], needle[1]) }
}

#[inline]
pub(crate) fn is_void_tag(tag: &[u8]) -> bool {
    unsafe { rbtl_asm_is_void_tag(tag.as_ptr(), tag.len()) != 0 }
}

#[inline]
pub(crate) fn bytes_eq(left: &[u8], right: &[u8]) -> bool {
    left.len() == right.len()
        && unsafe { rbtl_asm_bytes_eq(left.as_ptr(), right.as_ptr(), left.len()) != 0 }
}

#[inline]
pub(crate) fn contains_ascii_whitespace_token(haystack: &[u8], needle: &[u8]) -> bool {
    unsafe {
        rbtl_asm_contains_ascii_whitespace_token(
            haystack.as_ptr(),
            haystack.len(),
            needle.as_ptr(),
            needle.len(),
        ) != 0
    }
}

#[inline]
pub(crate) fn count_spaces(haystack: &[u8]) -> usize {
    unsafe { rbtl_asm_count_spaces(haystack.as_ptr(), haystack.len()) }
}

#[inline]
pub(crate) fn starts_with(haystack: &[u8], needle: &[u8]) -> bool {
    unsafe {
        rbtl_asm_starts_with(
            haystack.as_ptr(),
            haystack.len(),
            needle.as_ptr(),
            needle.len(),
        ) != 0
    }
}

#[inline]
pub(crate) fn ends_with(haystack: &[u8], needle: &[u8]) -> bool {
    unsafe {
        rbtl_asm_ends_with(
            haystack.as_ptr(),
            haystack.len(),
            needle.as_ptr(),
            needle.len(),
        ) != 0
    }
}

#[inline]
pub(crate) fn contains_bytes(haystack: &[u8], needle: &[u8]) -> bool {
    unsafe {
        rbtl_asm_contains_bytes(
            haystack.as_ptr(),
            haystack.len(),
            needle.as_ptr(),
            needle.len(),
        ) != 0
    }
}
