#![allow(dead_code)]

#[cfg(not(any(
    all(target_arch = "x86_64", target_os = "linux"),
    all(target_arch = "x86_64", target_os = "windows", target_env = "msvc")
)))]
compile_error!("asm-tl assembly core currently supports only x86_64 Linux and x86_64 Windows MSVC");

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
    fn rbtl_asm_parse_attr(ptr: *const u8, len: usize, idx: usize, out: *mut AsmAttr) -> u32;
    fn rbtl_asm_parse_document(ptr: *const u8, len: usize, out: *mut AsmParseOutput) -> u32;
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

pub(crate) struct AsmBuffer<T> {
    pub(crate) ptr: *mut T,
    pub(crate) cap: usize,
}

impl<T> AsmBuffer<T> {
    pub(crate) fn new(ptr: *mut T, cap: usize) -> Self {
        Self { ptr, cap }
    }
}

impl AsmParseOutput {
    pub(crate) fn from_raw_parts(
        nodes: AsmBuffer<AsmNodeRecord>,
        attrs: AsmBuffer<AsmAttrRecord>,
        roots: AsmBuffer<u32>,
        stack: AsmBuffer<u32>,
    ) -> Self {
        Self {
            nodes_ptr: nodes.ptr,
            nodes_cap: nodes.cap,
            nodes_len: 0,
            attrs_ptr: attrs.ptr,
            attrs_cap: attrs.cap,
            attrs_len: 0,
            roots_ptr: roots.ptr,
            roots_cap: roots.cap,
            roots_len: 0,
            stack_ptr: stack.ptr,
            stack_cap: stack.cap,
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

#[allow(dead_code)]
#[inline]
pub(crate) fn find3(haystack: &[u8], needle: [u8; 3]) -> Option<usize> {
    memchr::memchr3(needle[0], needle[1], needle[2], haystack)
}

#[inline]
pub(crate) fn find(haystack: &[u8], needle: u8) -> Option<usize> {
    memchr::memchr(needle, haystack)
}

#[inline]
pub(crate) fn matches_case_insensitive_exact<const N: usize>(
    haystack: &[u8],
    needle: [u8; N],
) -> bool {
    haystack.len() == N && matches_case_insensitive(haystack, &needle)
}

#[inline]
fn is_ident_byte(byte: u8) -> bool {
    byte.is_ascii_alphanumeric() || matches!(byte, b'-' | b'_' | b'/' | b':' | b'+')
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
        5 if key == b"class" => 2,
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
        rbtl_asm_scan_html_event(haystack.as_ptr(), haystack.len(), idx, &mut start, &mut len)
    };
    (kind, start, len)
}

#[inline]
pub(crate) fn next_ascii_token(haystack: &[u8], idx: usize) -> Option<(usize, usize, usize)> {
    let mut start = 0;
    let mut len = 0;
    let next = unsafe {
        rbtl_asm_next_ascii_token(haystack.as_ptr(), haystack.len(), idx, &mut start, &mut len)
    };

    (next <= haystack.len()).then_some((start, len, next))
}

#[inline]
pub(crate) fn parse_attr(haystack: &[u8], idx: usize) -> Option<AsmAttr> {
    let mut attr = AsmAttr::default();
    let ok = unsafe { rbtl_asm_parse_attr(haystack.as_ptr(), haystack.len(), idx, &mut attr) };
    (ok != 0).then_some(attr)
}

#[inline]
pub(crate) fn parse_document(haystack: &[u8], out: &mut AsmParseOutput) -> u32 {
    unsafe { rbtl_asm_parse_document(haystack.as_ptr(), haystack.len(), out) }
}

#[inline]
pub(crate) fn simple_selector_kind(input: &[u8]) -> (u32, usize) {
    let mut tag_len = 0;
    let kind = unsafe { rbtl_asm_simple_selector_kind(input.as_ptr(), input.len(), &mut tag_len) };
    (kind, tag_len)
}

#[cfg(all(target_arch = "x86_64", target_os = "windows", target_env = "msvc"))]
mod msvc_helpers {
    use super::{AsmAttr, AsmAttrRecord, AsmNodeRecord, AsmParseOutput};

    #[inline]
    fn is_ident(byte: u8) -> bool {
        byte.is_ascii_alphanumeric() || matches!(byte, b'-' | b'_' | b'/' | b':' | b'+')
    }

    #[inline]
    fn is_ws(byte: u8) -> bool {
        byte == b' ' || byte == b'\n'
    }

    #[inline]
    fn is_void_tag_bytes(tag: &[u8]) -> bool {
        matches!(
            tag,
            b"area"
                | b"base"
                | b"br"
                | b"col"
                | b"command"
                | b"embed"
                | b"hr"
                | b"img"
                | b"input"
                | b"keygen"
                | b"link"
                | b"meta"
                | b"param"
                | b"source"
                | b"track"
                | b"wbr"
        )
    }

    #[inline]
    fn eq_ascii_ci(left: &[u8], right: &[u8]) -> bool {
        left.len() == right.len()
            && left
                .iter()
                .zip(right)
                .all(|(&l, &r)| l.to_ascii_lowercase() == r)
    }

    fn parse_attr_at(input: &[u8], mut idx: usize) -> Option<AsmAttr> {
        if idx >= input.len() {
            return None;
        }

        let name_start = idx;
        while idx < input.len() && is_ident(input[idx]) {
            idx += 1;
        }
        if idx == name_start {
            return None;
        }
        let name_len = idx - name_start;

        while idx < input.len() && is_ws(input[idx]) {
            idx += 1;
        }

        if input.get(idx) != Some(&b'=') {
            return Some(AsmAttr {
                name_start,
                name_len,
                value_start: idx,
                value_len: 0,
                next_idx: idx,
                has_value: 0,
            });
        }

        idx += 1;
        while idx < input.len() && is_ws(input[idx]) {
            idx += 1;
        }

        if idx >= input.len() {
            return Some(AsmAttr {
                name_start,
                name_len,
                value_start: idx,
                value_len: 0,
                next_idx: idx,
                has_value: 1,
            });
        }

        let value_start;
        let value_len;
        if matches!(input[idx], b'"' | b'\'') {
            let quote = input[idx];
            idx += 1;
            value_start = idx;
            while idx < input.len() && input[idx] != quote {
                idx += 1;
            }
            value_len = idx - value_start;
        } else {
            value_start = idx;
            while idx < input.len() && !matches!(input[idx], b' ' | b'\n' | b'>') {
                idx += 1;
            }
            value_len = idx - value_start;
        }

        Some(AsmAttr {
            name_start,
            name_len,
            value_start,
            value_len,
            next_idx: idx,
            has_value: 1,
        })
    }

    unsafe fn emit_node(
        out: *mut AsmParseOutput,
        stack: &mut Vec<u32>,
        kind: u32,
        start: usize,
        len: usize,
        name_start: usize,
        name_len: usize,
        attr_start: usize,
        attr_count: usize,
    ) -> Result<u32, u32> {
        let out_ref = unsafe { &mut *out };
        if out_ref.nodes_len >= out_ref.nodes_cap {
            return Err(1);
        }

        let idx = out_ref.nodes_len;
        let parent = stack.last().copied().unwrap_or(u32::MAX);
        let record = AsmNodeRecord {
            kind,
            flags: 0,
            parent,
            attr_start: attr_start as u32,
            attr_count: attr_count as u32,
            start: start as u32,
            len: len as u32,
            name_start: name_start as u32,
            name_len: name_len as u32,
        };
        unsafe {
            out_ref.nodes_ptr.add(idx).write(record);
        }
        out_ref.nodes_len += 1;

        if parent == u32::MAX {
            if !out_ref.roots_ptr.is_null() {
                if out_ref.roots_len >= out_ref.roots_cap {
                    return Err(3);
                }
                unsafe {
                    out_ref.roots_ptr.add(out_ref.roots_len).write(idx as u32);
                }
            }
            out_ref.roots_len += 1;
        } else {
            unsafe {
                let parent_record = &mut *out_ref.nodes_ptr.add(parent as usize);
                parent_record.flags = parent_record.flags.saturating_add(1);
            }
        }

        Ok(idx as u32)
    }

    #[unsafe(no_mangle)]
    pub unsafe extern "C" fn rbtl_rust_msvc_parse_attr(
        ptr: *const u8,
        len: usize,
        idx: usize,
        out: *mut AsmAttr,
    ) -> u32 {
        if out.is_null() {
            return 0;
        }
        let input = unsafe { core::slice::from_raw_parts(ptr, len) };
        let Some(attr) = parse_attr_at(input, idx) else {
            return 0;
        };
        unsafe {
            out.write(attr);
        }
        1
    }

    #[unsafe(no_mangle)]
    pub unsafe extern "C" fn rbtl_rust_msvc_parse_document(
        ptr: *const u8,
        len: usize,
        out: *mut AsmParseOutput,
    ) -> u32 {
        if out.is_null() || len > u32::MAX as usize {
            return 5;
        }

        let input = unsafe { core::slice::from_raw_parts(ptr, len) };
        let out_ref = unsafe { &mut *out };
        out_ref.nodes_len = 0;
        out_ref.attrs_len = 0;
        out_ref.roots_len = 0;
        out_ref.stack_len = 0;
        out_ref.version = 0;
        out_ref.error = 0;

        let mut stack = Vec::<u32>::with_capacity(out_ref.stack_cap);
        let mut idx = 0usize;

        while idx < input.len() {
            if input[idx] != b'<' {
                let start = idx;
                while idx < input.len() && input[idx] != b'<' {
                    idx += 1;
                }
                if idx > start {
                    let status =
                        unsafe { emit_node(out, &mut stack, 1, start, idx - start, 0, 0, 0, 0) };
                    if let Err(status) = status {
                        out_ref.error = status;
                        return status;
                    }
                }
                continue;
            }

            let markup_start = idx;
            if idx + 1 >= input.len() {
                idx += 1;
                let status = unsafe { emit_node(out, &mut stack, 1, markup_start, 1, 0, 0, 0, 0) };
                if let Err(status) = status {
                    out_ref.error = status;
                    return status;
                }
                continue;
            }

            match input[idx + 1] {
                b'/' => {
                    idx += 2;
                    while idx < input.len() && is_ws(input[idx]) {
                        idx += 1;
                    }
                    let name_start = idx;
                    while idx < input.len() && input[idx] != b'>' {
                        idx += 1;
                    }
                    let name_len = idx - name_start;
                    if idx < input.len() && input[idx] == b'>' {
                        idx += 1;
                    }

                    let Some(&open_idx) = stack.last() else {
                        continue;
                    };
                    let open = unsafe { &mut *out_ref.nodes_ptr.add(open_idx as usize) };
                    let open_name = &input[open.name_start as usize
                        ..open.name_start as usize + open.name_len as usize];
                    if open_name == &input[name_start..name_start + name_len] {
                        stack.pop();
                        out_ref.stack_len = stack.len();
                        open.len = (idx - open.start as usize) as u32;
                    }
                }
                b'!' => {
                    if idx + 3 < input.len() && &input[idx + 2..idx + 4] == b"--" {
                        idx += 4;
                        while idx + 2 < input.len() && &input[idx..idx + 3] != b"-->" {
                            idx += 1;
                        }
                        if idx + 2 < input.len() {
                            idx += 3;
                        } else {
                            idx = input.len();
                        }
                        let status = unsafe {
                            emit_node(
                                out,
                                &mut stack,
                                3,
                                markup_start,
                                idx - markup_start,
                                0,
                                0,
                                0,
                                0,
                            )
                        };
                        if let Err(status) = status {
                            out_ref.error = status;
                            return status;
                        }
                    } else {
                        idx += 2;
                        while idx < input.len() && is_ws(input[idx]) {
                            idx += 1;
                        }
                        let word_start = idx;
                        while idx < input.len() && is_ident(input[idx]) {
                            idx += 1;
                        }
                        if !eq_ascii_ci(&input[word_start..idx], b"doctype") {
                            out_ref.error = 5;
                            return 5;
                        }
                        while idx < input.len() && is_ws(input[idx]) {
                            idx += 1;
                        }
                        let value_start = idx;
                        while idx < input.len() && is_ident(input[idx]) {
                            idx += 1;
                        }
                        if eq_ascii_ci(&input[value_start..idx], b"html") {
                            out_ref.version = 1;
                        }
                        while idx < input.len() && input[idx] != b'>' {
                            idx += 1;
                        }
                        if idx < input.len() {
                            idx += 1;
                        }
                    }
                }
                _ => {
                    idx += 1;
                    while idx < input.len() && is_ws(input[idx]) {
                        idx += 1;
                    }
                    let name_start = idx;
                    while idx < input.len() && is_ident(input[idx]) {
                        idx += 1;
                    }
                    let name_len = idx - name_start;
                    if name_len == 0 {
                        break;
                    }

                    let attr_start = out_ref.attrs_len;
                    let mut is_self_closing = false;
                    loop {
                        while idx < input.len() && is_ws(input[idx]) {
                            idx += 1;
                        }
                        if idx >= input.len() {
                            break;
                        }
                        match input[idx] {
                            b'/' => {
                                is_self_closing = true;
                                idx += 1;
                                while idx < input.len() && is_ws(input[idx]) {
                                    idx += 1;
                                }
                            }
                            b'>' => {
                                idx += 1;
                                break;
                            }
                            _ => {
                                let Some(attr) = parse_attr_at(input, idx) else {
                                    idx += 1;
                                    continue;
                                };
                                if out_ref.attrs_len >= out_ref.attrs_cap {
                                    out_ref.error = 2;
                                    return 2;
                                }
                                let key = &input[attr.name_start..attr.name_start + attr.name_len];
                                let key_kind = match key {
                                    b"id" => 1,
                                    b"class" => 2,
                                    _ => 0,
                                };
                                let record = AsmAttrRecord {
                                    name_start: attr.name_start as u32,
                                    name_len: attr.name_len as u32,
                                    value_start: attr.value_start as u32,
                                    value_len: attr.value_len as u32,
                                    has_value: attr.has_value,
                                    key_kind,
                                };
                                unsafe {
                                    out_ref.attrs_ptr.add(out_ref.attrs_len).write(record);
                                }
                                out_ref.attrs_len += 1;

                                idx = attr.next_idx;
                                if attr.has_value != 0
                                    && idx < input.len()
                                    && input[idx] != b'/'
                                    && input[idx] != b'>'
                                {
                                    idx += 1;
                                }
                            }
                        }
                    }

                    let attr_count = out_ref.attrs_len - attr_start;
                    let emitted = unsafe {
                        emit_node(
                            out,
                            &mut stack,
                            2,
                            markup_start,
                            idx - markup_start,
                            name_start,
                            name_len,
                            attr_start,
                            attr_count,
                        )
                    };
                    let node_idx = match emitted {
                        Ok(node_idx) => node_idx,
                        Err(status) => {
                            out_ref.error = status;
                            return status;
                        }
                    };

                    let name = &input[name_start..name_start + name_len];
                    if !is_self_closing && !is_void_tag_bytes(name) {
                        if stack.len() >= out_ref.stack_cap {
                            out_ref.error = 4;
                            return 4;
                        }
                        stack.push(node_idx);
                        out_ref.stack_len = stack.len();
                    }
                }
            }
        }

        0
    }
}
