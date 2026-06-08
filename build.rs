fn main() {
    let arch = std::env::var("CARGO_CFG_TARGET_ARCH").unwrap_or_default();
    let os = std::env::var("CARGO_CFG_TARGET_OS").unwrap_or_default();
    let env = std::env::var("CARGO_CFG_TARGET_ENV").unwrap_or_default();

    if arch == "x86_64" && os == "linux" {
        cc::Build::new()
            .file("src/asm/x86_64/html_core.S")
            .compile("rbtl_html_core");
        println!("cargo:rerun-if-changed=src/asm/x86_64/html_core.S");
    } else if arch == "x86_64" && os == "windows" && env == "msvc" {
        cc::Build::new()
            .file("src/asm/x86_64/html_core_msvc.asm")
            .compile("rbtl_html_core_msvc");
        println!("cargo:rerun-if-changed=src/asm/x86_64/html_core_msvc.asm");
    }
}
