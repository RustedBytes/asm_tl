use core::simd::{Simd, prelude::*};

use super::fallback;

const LANES: usize = 16;

#[inline]
fn chunk(haystack: &[u8], offset: usize) -> Simd<u8, LANES> {
    let mut bytes = [0; LANES];
    bytes.copy_from_slice(&haystack[offset..offset + LANES]);
    Simd::from_array(bytes)
}

/// Searches for the first non-identifier in `haystack`.
#[inline]
pub fn search_non_ident(haystack: &[u8]) -> Option<usize> {
    let len = haystack.len();
    let mut offset = 0;

    while offset + LANES <= len {
        let bytes = chunk(haystack, offset);
        let is_ident = is_ident_chunk(bytes);
        let non_ident = !is_ident;
        let mask = non_ident.to_bitmask();

        if mask != 0 {
            return Some(offset + mask.trailing_zeros() as usize);
        }

        offset += LANES;
    }

    if offset < len {
        fallback::search_non_ident(&haystack[offset..]).map(|idx| offset + idx)
    } else {
        None
    }
}

/// Searches for the first occurrence of any of 3 bytes in `haystack`.
#[inline]
pub fn find3(haystack: &[u8], needle: [u8; 3]) -> Option<usize> {
    let len = haystack.len();
    let mut offset = 0;

    let needle0 = Simd::splat(needle[0]);
    let needle1 = Simd::splat(needle[1]);
    let needle2 = Simd::splat(needle[2]);

    while offset + LANES <= len {
        let bytes = chunk(haystack, offset);
        let matches = bytes.simd_eq(needle0) | bytes.simd_eq(needle1) | bytes.simd_eq(needle2);
        let mask = matches.to_bitmask();

        if mask != 0 {
            return Some(offset + mask.trailing_zeros() as usize);
        }

        offset += LANES;
    }

    haystack[offset..]
        .iter()
        .position(|&byte| byte == needle[0] || byte == needle[1] || byte == needle[2])
        .map(|idx| offset + idx)
}

/// Searches for the first occurrence of `needle` in `haystack`.
#[inline]
pub fn find(haystack: &[u8], needle: u8) -> Option<usize> {
    let len = haystack.len();
    let mut offset = 0;
    let needle_byte = needle;
    let needle = Simd::splat(needle_byte);

    while offset + LANES <= len {
        let bytes = chunk(haystack, offset);
        let matches = bytes.simd_eq(needle);
        let mask = matches.to_bitmask();

        if mask != 0 {
            return Some(offset + mask.trailing_zeros() as usize);
        }

        offset += LANES;
    }

    haystack[offset..]
        .iter()
        .position(|&byte| byte == needle_byte)
        .map(|idx| offset + idx)
}

#[inline]
fn is_ident_chunk(bytes: Simd<u8, LANES>) -> Mask<i8, LANES> {
    let is_digit = bytes.simd_ge(Simd::splat(b'0')) & bytes.simd_le(Simd::splat(b'9'));
    let is_lower = bytes.simd_ge(Simd::splat(b'a')) & bytes.simd_le(Simd::splat(b'z'));
    let is_upper = bytes.simd_ge(Simd::splat(b'A')) & bytes.simd_le(Simd::splat(b'Z'));
    let is_hyphen = bytes.simd_eq(Simd::splat(b'-'));
    let is_underscore = bytes.simd_eq(Simd::splat(b'_'));
    let is_slash = bytes.simd_eq(Simd::splat(b'/'));
    let is_colon = bytes.simd_eq(Simd::splat(b':'));
    let is_plus = bytes.simd_eq(Simd::splat(b'+'));

    is_digit | is_lower | is_upper | is_hyphen | is_underscore | is_slash | is_colon | is_plus
}
