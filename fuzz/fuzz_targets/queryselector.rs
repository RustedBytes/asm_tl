#![no_main]
use libfuzzer_sys::fuzz_target;
extern crate asm_tl;

const HTML: &str = r#"
<!DOCTYPE html>
<div>
    <p id="greeting">Hello World</p>
    <img id="img" src="image.png" />
</div>
"#;

fuzz_target!(|data: &str| {
    let dom = asm_tl::parse(HTML, asm_tl::ParserOptions::default());
    let iter = dom.query_selector(data);
    for _ in iter {
        // do nothing
    }
});
