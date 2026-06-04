#[cfg(not(all(target_arch = "x86_64", target_os = "linux")))]
compile_error!("rustedbytes-tl assembly core currently supports only x86_64 Linux");

unsafe extern "C" {
    fn rbtl_asm_find(ptr: *const u8, len: usize, needle: u8) -> usize;
    fn rbtl_asm_find3(ptr: *const u8, len: usize, n0: u8, n1: u8, n2: u8) -> usize;
    fn rbtl_asm_search_non_ident(ptr: *const u8, len: usize) -> usize;
    fn rbtl_asm_validate_subset(ptr: *const u8, len: usize) -> u32;
    fn rbtl_asm_selector_kind(ptr: *const u8, len: usize) -> u32;
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
