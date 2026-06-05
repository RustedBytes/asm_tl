#![allow(dead_code)]

#[cfg(not(all(target_arch = "x86_64", target_os = "linux")))]
compile_error!("rustedbytes-tl assembly core currently supports only x86_64 Linux");

unsafe extern "C" {
    fn rbtl_asm_search_non_ident(ptr: *const u8, len: usize) -> usize;
    fn rbtl_asm_selector_kind(ptr: *const u8, len: usize) -> u32;
    fn rbtl_asm_matches_case_insensitive(haystack: *const u8, needle: *const u8, len: usize)
    -> u32;
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
    fn rbtl_asm_count_ident(ptr: *const u8, len: usize) -> usize;
    fn rbtl_asm_is_quote(byte: u8) -> u32;
    fn rbtl_asm_find_comment_end(ptr: *const u8, len: usize) -> usize;
    fn rbtl_asm_len_fits_u32(len: usize) -> u32;
    fn rbtl_asm_selector_token_kind(byte: u8) -> u32;
    fn rbtl_asm_selector_attr_op_kind(byte: u8) -> u32;
    fn rbtl_asm_selector_combinator_kind(byte: u8, has_whitespace: u32) -> u32;
    fn rbtl_asm_usize_is_zero(value: usize) -> u32;
    fn rbtl_asm_usize_lt(left: usize, right: usize) -> u32;
    fn rbtl_asm_usize_ge(left: usize, right: usize) -> u32;
    fn rbtl_asm_usize_min(left: usize, right: usize) -> usize;
    fn rbtl_asm_usize_add(left: usize, right: usize) -> usize;
    fn rbtl_asm_usize_sub_one(value: usize) -> usize;
    fn rbtl_asm_scan_html_event(
        ptr: *const u8,
        len: usize,
        idx: usize,
        out_start: *mut usize,
        out_len: *mut usize,
    ) -> u32;
    fn rbtl_asm_next_ascii_token(
        ptr: *const u8,
        len: usize,
        idx: usize,
        out_start: *mut usize,
        out_len: *mut usize,
    ) -> usize;
    fn rbtl_asm_parse_attr(
        ptr: *const u8,
        len: usize,
        idx: usize,
        out: *mut AsmAttr,
    ) -> u32;
    #[cfg(feature = "std")]
    fn rbtl_asm_parse_document(
        ptr: *const u8,
        len: usize,
        out: *mut AsmParseOutput,
    ) -> u32;
    #[cfg(feature = "std")]
    fn rbtl_asm_simple_selector_kind(ptr: *const u8, len: usize, out_tag_len: *mut usize) -> u32;
}

#[repr(C)]
#[derive(Default)]
pub(crate) struct AsmAttr {
    pub(crate) name_start: usize,
    pub(crate) name_len: usize,
    pub(crate) value_start: usize,
    pub(crate) value_len: usize,
    pub(crate) next_idx: usize,
    pub(crate) has_value: u32,
}

#[cfg(feature = "std")]
#[repr(C)]
#[derive(Clone, Copy, Default)]
pub(crate) struct AsmNodeRecord {
    pub(crate) kind: u32,
    pub(crate) flags: u32,
    pub(crate) parent: u32,
    pub(crate) attr_start: u32,
    pub(crate) attr_count: u32,
    pub(crate) start: u32,
    pub(crate) len: u32,
    pub(crate) name_start: u32,
    pub(crate) name_len: u32,
}

#[cfg(feature = "std")]
#[repr(C)]
#[derive(Clone, Copy, Default)]
pub(crate) struct AsmAttrRecord {
    pub(crate) name_start: u32,
    pub(crate) name_len: u32,
    pub(crate) value_start: u32,
    pub(crate) value_len: u32,
    pub(crate) has_value: u32,
    pub(crate) key_kind: u32,
}

#[cfg(feature = "std")]
#[repr(C)]
pub(crate) struct AsmParseOutput {
    pub(crate) nodes_ptr: *mut AsmNodeRecord,
    pub(crate) nodes_cap: usize,
    pub(crate) nodes_len: usize,
    pub(crate) attrs_ptr: *mut AsmAttrRecord,
    pub(crate) attrs_cap: usize,
    pub(crate) attrs_len: usize,
    pub(crate) roots_ptr: *mut u32,
    pub(crate) roots_cap: usize,
    pub(crate) roots_len: usize,
    pub(crate) stack_ptr: *mut u32,
    pub(crate) stack_cap: usize,
    pub(crate) stack_len: usize,
    pub(crate) version: u32,
    pub(crate) error: u32,
}

#[cfg(feature = "std")]
impl AsmParseOutput {
    pub(crate) fn from_raw_parts(
        nodes_ptr: *mut AsmNodeRecord,
        nodes_cap: usize,
        attrs_ptr: *mut AsmAttrRecord,
        attrs_cap: usize,
        roots_ptr: *mut u32,
        roots_cap: usize,
        stack_ptr: *mut u32,
        stack_cap: usize,
    ) -> Self {
        Self {
            nodes_ptr,
            nodes_cap,
            nodes_len: 0,
            attrs_ptr,
            attrs_cap,
            attrs_len: 0,
            roots_ptr,
            roots_cap,
            roots_len: 0,
            stack_ptr,
            stack_cap,
            stack_len: 0,
            version: 0,
            error: 0,
        }
    }
}

#[inline]
pub(crate) fn search_non_ident(haystack: &[u8]) -> Option<usize> {
    if haystack.len() < 32 {
        let mut idx = 0;
        while idx < haystack.len() {
            if !is_ident_byte(haystack[idx]) {
                return Some(idx);
            }
            idx += 1;
        }
        return None;
    }

    let idx = unsafe { rbtl_asm_search_non_ident(haystack.as_ptr(), haystack.len()) };
    (idx != haystack.len()).then_some(idx)
}

#[inline]
fn is_ident_byte(byte: u8) -> bool {
    byte.is_ascii_alphanumeric()
        || matches!(byte, b'-' | b'_' | b'/' | b':' | b'+')
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
    byte == b'/' || byte == b'>'
}

#[inline]
pub(crate) fn count_while2(haystack: &[u8], needle: [u8; 2]) -> usize {
    if haystack.len() < 32 {
        let mut idx = 0;
        while idx < haystack.len() {
            let byte = haystack[idx];
            if byte != needle[0] && byte != needle[1] {
                break;
            }
            idx += 1;
        }
        return idx;
    }

    unsafe { rbtl_asm_count_while2(haystack.as_ptr(), haystack.len(), needle[0], needle[1]) }
}

#[inline]
pub(crate) fn is_void_tag(tag: &[u8]) -> bool {
    unsafe { rbtl_asm_is_void_tag(tag.as_ptr(), tag.len()) != 0 }
}

#[inline]
pub(crate) fn bytes_eq(left: &[u8], right: &[u8]) -> bool {
    if left.len() != right.len() {
        return false;
    }

    if left.len() <= 16 {
        let mut idx = 0;
        while idx < left.len() {
            if left[idx] != right[idx] {
                return false;
            }
            idx += 1;
        }
        return true;
    }

    unsafe { rbtl_asm_bytes_eq(left.as_ptr(), right.as_ptr(), left.len()) != 0 }
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

#[inline]
pub(crate) fn count_ident(haystack: &[u8]) -> usize {
    unsafe { rbtl_asm_count_ident(haystack.as_ptr(), haystack.len()) }
}

#[inline]
pub(crate) fn is_quote(byte: u8) -> bool {
    unsafe { rbtl_asm_is_quote(byte) != 0 }
}

#[inline]
pub(crate) fn find_comment_end(haystack: &[u8]) -> Option<usize> {
    let idx = unsafe { rbtl_asm_find_comment_end(haystack.as_ptr(), haystack.len()) };
    (idx <= haystack.len()).then_some(idx)
}

#[inline]
pub(crate) fn attr_key_kind(key: &[u8]) -> u32 {
    match key.len() {
        2 => (key == b"id") as u32,
        5 => {
            if key == b"class" {
                2
            } else {
                0
            }
        }
        _ => 0,
    }
}

#[inline]
pub(crate) fn len_fits_u32(len: usize) -> bool {
    unsafe { rbtl_asm_len_fits_u32(len) != 0 }
}

#[inline]
pub(crate) fn byte_at_eq(haystack: &[u8], idx: usize, byte: u8) -> bool {
    haystack.get(idx).is_some_and(|&current| current == byte)
}

#[inline]
pub(crate) fn selector_token_kind(byte: u8) -> u32 {
    unsafe { rbtl_asm_selector_token_kind(byte) }
}

#[inline]
pub(crate) fn selector_attr_op_kind(byte: u8) -> u32 {
    unsafe { rbtl_asm_selector_attr_op_kind(byte) }
}

#[inline]
pub(crate) fn selector_combinator_kind(byte: u8, has_whitespace: bool) -> u32 {
    unsafe { rbtl_asm_selector_combinator_kind(byte, has_whitespace as u32) }
}

#[inline]
pub(crate) fn usize_is_zero(value: usize) -> bool {
    unsafe { rbtl_asm_usize_is_zero(value) != 0 }
}

#[inline]
pub(crate) fn usize_lt(left: usize, right: usize) -> bool {
    unsafe { rbtl_asm_usize_lt(left, right) != 0 }
}

#[inline]
pub(crate) fn usize_ge(left: usize, right: usize) -> bool {
    unsafe { rbtl_asm_usize_ge(left, right) != 0 }
}

#[inline]
pub(crate) fn usize_min(left: usize, right: usize) -> usize {
    unsafe { rbtl_asm_usize_min(left, right) }
}

#[inline]
pub(crate) fn usize_add(left: usize, right: usize) -> usize {
    unsafe { rbtl_asm_usize_add(left, right) }
}

#[inline]
pub(crate) fn usize_sub_one(value: usize) -> usize {
    unsafe { rbtl_asm_usize_sub_one(value) }
}

#[inline]
pub(crate) fn scan_html_event(haystack: &[u8], idx: usize) -> (u32, usize, usize) {
    let mut start = 0;
    let mut len = 0;
    let kind = unsafe {
        rbtl_asm_scan_html_event(
            haystack.as_ptr(),
            haystack.len(),
            idx,
            &mut start,
            &mut len,
        )
    };
    (kind, start, len)
}

#[inline]
pub(crate) fn next_ascii_token(haystack: &[u8], idx: usize) -> Option<(usize, usize, usize)> {
    let mut start = 0;
    let mut len = 0;
    let next = unsafe {
        rbtl_asm_next_ascii_token(
            haystack.as_ptr(),
            haystack.len(),
            idx,
            &mut start,
            &mut len,
        )
    };

    (next <= haystack.len()).then_some((start, len, next))
}

#[inline]
pub(crate) fn parse_attr(haystack: &[u8], idx: usize) -> Option<AsmAttr> {
    let mut attr = AsmAttr::default();
    let ok = unsafe { rbtl_asm_parse_attr(haystack.as_ptr(), haystack.len(), idx, &mut attr) };
    (ok != 0).then_some(attr)
}

#[cfg(feature = "std")]
#[inline]
pub(crate) fn parse_document(haystack: &[u8], out: &mut AsmParseOutput) -> u32 {
    unsafe { rbtl_asm_parse_document(haystack.as_ptr(), haystack.len(), out) }
}

#[cfg(feature = "std")]
#[inline]
pub(crate) fn simple_selector_kind(input: &[u8]) -> (u32, usize) {
    let mut tag_len = 0;
    let kind =
        unsafe { rbtl_asm_simple_selector_kind(input.as_ptr(), input.len(), &mut tag_len) };
    (kind, tag_len)
}
