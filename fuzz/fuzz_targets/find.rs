#![no_main]
use libfuzzer_sys::fuzz_target;
extern crate asm_tl;

fuzz_target!(|data: (&[u8], u8)| {
    let (haystack, needle) = data;
    asm_tl::simd::find(haystack, needle);
});
