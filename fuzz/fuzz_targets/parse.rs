#![no_main]
use libfuzzer_sys::fuzz_target;
extern crate asm_tl;

fuzz_target!(|data: &str| {
    let _ = asm_tl::parse(data, asm_tl::ParserOptions::default());
});
