# `rustedbytes-tl`

[![Crates.io Version](https://img.shields.io/crates/v/rustedbytes-tl)](https://crates.io/crates/rustedbytes-tl)

tl is a fast HTML parser written in pure Rust.

By default this crate builds without `std` or `alloc`. Enable `std` for the
allocating convenience API:

```toml
rustedbytes-tl = { version = "0.1", features = ["std"] }
```

For the nightly portable SIMD path, enable `portable-simd` and build with
nightly:

```sh
cargo +nightly build --features portable-simd
```

## Provenance

This crate is a fork of [`astral-tl`](https://github.com/astral-sh/astral-tl), modified to
add no-std, zero-copy parsing and other improvements.

## License

This project is licensed under the MIT license.
