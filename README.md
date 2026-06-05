# `asm_tl`

[![Crates.io Version](https://img.shields.io/crates/v/asm_tl)](https://crates.io/crates/asm_tl)

`asm_tl` is a blazingly fast HTML parser written in Rust and Assembly. Works only on x86_64.

Add it to your `Cargo.toml`:

```toml
asm_tl = "0.1"
```

## Usage

Use `asm_tl::parse` with the default parser options:

```rust,ignore
let dom = asm_tl::parse("<div id=\"app\">Hello</div>", asm_tl::ParserOptions::default())?;
let parser = dom.parser();
let app = dom.get_element_by_id("app").unwrap().get(parser).unwrap();

assert_eq!(app.inner_text(parser), "Hello");
```

Enable ID or class tracking when you need fast lookup tables:

```rust,ignore
let options = asm_tl::ParserOptions::default()
    .track_ids()
    .track_classes();
```

## Features

- `__INTERNALS_DO_NOT_USE`: exposes internal modules for fuzzing and
  benchmarking.

## Provenance

This crate is a fork of [`astral-tl`](https://github.com/astral-sh/astral-tl),
modified to add zero-copy parsing and other improvements.

## License

This project is licensed under the MIT license.
