.text

.macro ident_byte reg, yes, no
    cmp \reg, #48
    b.lo \no
    cmp \reg, #57
    b.ls \yes
    cmp \reg, #65
    b.lo \no
    cmp \reg, #90
    b.ls \yes
    cmp \reg, #97
    b.lo \no
    cmp \reg, #122
    b.ls \yes
\no:
    cmp \reg, #45
    b.eq \yes
    cmp \reg, #95
    b.eq \yes
    cmp \reg, #47
    b.eq \yes
    cmp \reg, #58
    b.eq \yes
    cmp \reg, #43
    b.eq \yes
.endm

.global rbtl_asm_search_non_ident
.type rbtl_asm_search_non_ident, %function
rbtl_asm_search_non_ident:
    mov x8, #0
.Lsearch_non_ident_loop:
    cmp x8, x1
    b.hs .Lsearch_non_ident_none
    ldrb w9, [x0, x8]
    ident_byte w9, .Lsearch_non_ident_next, .Lsearch_non_ident_symbols
    mov x0, x8
    ret
.Lsearch_non_ident_next:
    add x8, x8, #1
    b .Lsearch_non_ident_loop
.Lsearch_non_ident_none:
    mov x0, x1
    ret
.size rbtl_asm_search_non_ident, .-rbtl_asm_search_non_ident

.global rbtl_asm_selector_kind
.type rbtl_asm_selector_kind, %function
rbtl_asm_selector_kind:
    cbz x1, .Lselector_kind_none
    mov x8, #0
    mov w9, #0
.Lselector_kind_skip:
    cmp x8, x1
    b.hs .Lselector_kind_none
    ldrb w10, [x0, x8]
    cmp w10, #32
    b.ne .Lselector_kind_loop
    add x8, x8, #1
    b .Lselector_kind_skip
.Lselector_kind_loop:
    cmp x8, x1
    b.hs .Lselector_kind_done
    ldrb w10, [x0, x8]
    cmp w10, #35
    b.eq .Lselector_kind_hash
    cmp w10, #46
    b.eq .Lselector_kind_dot
    cmp w10, #32
    b.eq .Lselector_kind_none
    cmp w10, #62
    b.eq .Lselector_kind_none
    cmp w10, #44
    b.eq .Lselector_kind_none
    add x8, x8, #1
    b .Lselector_kind_loop
.Lselector_kind_hash:
    orr w9, w9, #1
    add x8, x8, #1
    b .Lselector_kind_loop
.Lselector_kind_dot:
    orr w9, w9, #2
    add x8, x8, #1
    b .Lselector_kind_loop
.Lselector_kind_done:
    add w0, w9, #1
    ret
.Lselector_kind_none:
    mov w0, #0
    ret
.size rbtl_asm_selector_kind, .-rbtl_asm_selector_kind

.global rbtl_asm_matches_case_insensitive
.type rbtl_asm_matches_case_insensitive, %function
rbtl_asm_matches_case_insensitive:
    mov x8, #0
.Lcase_loop:
    cmp x8, x2
    b.hs .Lcase_yes
    ldrb w9, [x0, x8]
    cmp w9, #65
    b.lo .Lcase_cmp
    cmp w9, #90
    b.hi .Lcase_cmp
    add w9, w9, #32
.Lcase_cmp:
    ldrb w10, [x1, x8]
    cmp w9, w10
    b.ne .Lcase_no
    add x8, x8, #1
    b .Lcase_loop
.Lcase_yes:
    mov w0, #1
    ret
.Lcase_no:
    mov w0, #0
    ret
.size rbtl_asm_matches_case_insensitive, .-rbtl_asm_matches_case_insensitive

.global rbtl_asm_count_while2
.type rbtl_asm_count_while2, %function
rbtl_asm_count_while2:
    mov x8, #0
.Lcount_while2_loop:
    cmp x8, x1
    b.hs .Lcount_while2_ret
    ldrb w9, [x0, x8]
    cmp w9, w2
    b.eq .Lcount_while2_next
    cmp w9, w3
    b.eq .Lcount_while2_next
    mov x0, x8
    ret
.Lcount_while2_next:
    add x8, x8, #1
    b .Lcount_while2_loop
.Lcount_while2_ret:
    mov x0, x8
    ret
.size rbtl_asm_count_while2, .-rbtl_asm_count_while2

.global rbtl_asm_is_void_tag
.type rbtl_asm_is_void_tag, %function
rbtl_asm_is_void_tag:
    cmp x1, #2
    b.eq .Lvoid_len2
    cmp x1, #3
    b.eq .Lvoid_len3
    cmp x1, #4
    b.eq .Lvoid_len4
    cmp x1, #5
    b.eq .Lvoid_len5
    cmp x1, #6
    b.eq .Lvoid_len6
    cmp x1, #7
    b.eq .Lvoid_len7
    mov w0, #0
    ret
.Lvoid_len2:
    ldrb w8, [x0]
    ldrb w9, [x0, #1]
    cmp w8, #98
    b.ne .Lvoid_len2_hr
    cmp w9, #114
    cset w0, eq
    ret
.Lvoid_len2_hr:
    cmp w8, #104
    b.ne .Lvoid_no
    cmp w9, #114
    cset w0, eq
    ret
.Lvoid_len3:
    ldrb w8, [x0]
    cmp w8, #99
    b.eq .Lvoid_col
    cmp w8, #105
    b.ne .Lvoid_no
    ldrb w8, [x0, #1]
    cmp w8, #109
    b.ne .Lvoid_no
    ldrb w8, [x0, #2]
    cmp w8, #103
    cset w0, eq
    ret
.Lvoid_col:
    ldrb w8, [x0, #1]
    cmp w8, #111
    b.ne .Lvoid_no
    ldrb w8, [x0, #2]
    cmp w8, #108
    cset w0, eq
    ret
.Lvoid_len4:
    ldr w8, [x0]
    movz w9, #0x7261
    movk w9, #0x6165, lsl #16
    cmp w8, w9
    b.eq .Lvoid_yes
    movz w9, #0x6162
    movk w9, #0x6573, lsl #16
    cmp w8, w9
    b.eq .Lvoid_yes
    movz w9, #0x696c
    movk w9, #0x6b6e, lsl #16
    cmp w8, w9
    b.eq .Lvoid_yes
    movz w9, #0x656d
    movk w9, #0x6174, lsl #16
    cmp w8, w9
    b.eq .Lvoid_yes
    movz w9, #0x6277
    movk w9, #0x0072, lsl #16
    cmp w8, w9
    cset w0, eq
    ret
.Lvoid_len5:
    ldr w8, [x0]
    ldrb w10, [x0, #4]
    movz w9, #0x6d65
    movk w9, #0x6562, lsl #16
    cmp w8, w9
    b.ne .Lvoid_input
    cmp w10, #100
    cset w0, eq
    ret
.Lvoid_input:
    movz w9, #0x6e69
    movk w9, #0x7570, lsl #16
    cmp w8, w9
    b.ne .Lvoid_param
    cmp w10, #116
    cset w0, eq
    ret
.Lvoid_param:
    movz w9, #0x6170
    movk w9, #0x6172, lsl #16
    cmp w8, w9
    b.ne .Lvoid_track
    cmp w10, #109
    cset w0, eq
    ret
.Lvoid_track:
    movz w9, #0x7274
    movk w9, #0x6361, lsl #16
    cmp w8, w9
    b.ne .Lvoid_no
    cmp w10, #107
    cset w0, eq
    ret
.Lvoid_len6:
    ldr w8, [x0]
    movz w9, #0x6f73
    movk w9, #0x7275, lsl #16
    cmp w8, w9
    b.ne .Lvoid_no
    ldrb w8, [x0, #4]
    cmp w8, #99
    b.ne .Lvoid_no
    ldrb w8, [x0, #5]
    cmp w8, #101
    cset w0, eq
    ret
.Lvoid_len7:
    ldr w8, [x0]
    movz w9, #0x6f63
    movk w9, #0x6d6d, lsl #16
    cmp w8, w9
    b.eq .Lvoid_command
    movz w9, #0x656b
    movk w9, #0x6779, lsl #16
    cmp w8, w9
    b.eq .Lvoid_keygen
    b .Lvoid_no
.Lvoid_command:
    ldrb w8, [x0, #4]
    cmp w8, #97
    b.ne .Lvoid_no
    ldrb w8, [x0, #5]
    cmp w8, #110
    b.ne .Lvoid_no
    ldrb w8, [x0, #6]
    cmp w8, #100
    cset w0, eq
    ret
.Lvoid_keygen:
    ldrb w8, [x0, #4]
    cmp w8, #101
    b.ne .Lvoid_no
    ldrb w8, [x0, #5]
    cmp w8, #110
    cset w0, eq
    ret
.Lvoid_yes:
    mov w0, #1
    ret
.Lvoid_no:
    mov w0, #0
    ret
.size rbtl_asm_is_void_tag, .-rbtl_asm_is_void_tag

.global rbtl_asm_bytes_eq
.type rbtl_asm_bytes_eq, %function
rbtl_asm_bytes_eq:
    mov x8, #0
.Lbytes_eq_loop:
    cmp x8, x2
    b.hs .Lbytes_eq_yes
    ldrb w9, [x0, x8]
    ldrb w10, [x1, x8]
    cmp w9, w10
    b.ne .Lbytes_eq_no
    add x8, x8, #1
    b .Lbytes_eq_loop
.Lbytes_eq_yes:
    mov w0, #1
    ret
.Lbytes_eq_no:
    mov w0, #0
    ret
.size rbtl_asm_bytes_eq, .-rbtl_asm_bytes_eq

.global rbtl_asm_contains_ascii_whitespace_token
.type rbtl_asm_contains_ascii_whitespace_token, %function
rbtl_asm_contains_ascii_whitespace_token:
    cbz x3, .Ltoken_no
    mov x8, #0
.Ltoken_skip:
    cmp x8, x1
    b.hs .Ltoken_no
    ldrb w9, [x0, x8]
    cmp w9, #32
    b.eq .Ltoken_skip_one
    cmp w9, #9
    b.lo .Ltoken_start
    cmp w9, #13
    b.ls .Ltoken_skip_one
    b .Ltoken_start
.Ltoken_skip_one:
    add x8, x8, #1
    b .Ltoken_skip
.Ltoken_start:
    mov x10, x8
.Ltoken_scan:
    cmp x8, x1
    b.hs .Ltoken_check
    ldrb w9, [x0, x8]
    cmp w9, #32
    b.eq .Ltoken_check
    cmp w9, #9
    b.lo .Ltoken_scan_one
    cmp w9, #13
    b.ls .Ltoken_check
.Ltoken_scan_one:
    add x8, x8, #1
    b .Ltoken_scan
.Ltoken_check:
    sub x11, x8, x10
    cmp x11, x3
    b.ne .Ltoken_after
    mov x11, #0
.Ltoken_cmp:
    cmp x11, x3
    b.hs .Ltoken_yes
    add x12, x10, x11
    ldrb w13, [x0, x12]
    ldrb w14, [x2, x11]
    cmp w13, w14
    b.ne .Ltoken_after
    add x11, x11, #1
    b .Ltoken_cmp
.Ltoken_after:
    cmp x8, x1
    b.hs .Ltoken_no
    add x8, x8, #1
    b .Ltoken_skip
.Ltoken_yes:
    mov w0, #1
    ret
.Ltoken_no:
    mov w0, #0
    ret
.size rbtl_asm_contains_ascii_whitespace_token, .-rbtl_asm_contains_ascii_whitespace_token

.global rbtl_asm_count_spaces
.type rbtl_asm_count_spaces, %function
rbtl_asm_count_spaces:
    mov x8, #0
.Lcount_spaces_loop:
    cmp x8, x1
    b.hs .Lcount_spaces_ret
    ldrb w9, [x0, x8]
    cmp w9, #32
    b.ne .Lcount_spaces_ret
    add x8, x8, #1
    b .Lcount_spaces_loop
.Lcount_spaces_ret:
    mov x0, x8
    ret
.size rbtl_asm_count_spaces, .-rbtl_asm_count_spaces

.global rbtl_asm_starts_with
.type rbtl_asm_starts_with, %function
rbtl_asm_starts_with:
    cmp x3, x1
    b.hi .Lstarts_no
    mov x8, #0
.Lstarts_loop:
    cmp x8, x3
    b.hs .Lstarts_yes
    ldrb w9, [x0, x8]
    ldrb w10, [x2, x8]
    cmp w9, w10
    b.ne .Lstarts_no
    add x8, x8, #1
    b .Lstarts_loop
.Lstarts_yes:
    mov w0, #1
    ret
.Lstarts_no:
    mov w0, #0
    ret
.size rbtl_asm_starts_with, .-rbtl_asm_starts_with

.global rbtl_asm_ends_with
.type rbtl_asm_ends_with, %function
rbtl_asm_ends_with:
    cmp x3, x1
    b.hi .Lends_no
    sub x8, x1, x3
    mov x9, #0
.Lends_loop:
    cmp x9, x3
    b.hs .Lends_yes
    add x10, x8, x9
    ldrb w11, [x0, x10]
    ldrb w12, [x2, x9]
    cmp w11, w12
    b.ne .Lends_no
    add x9, x9, #1
    b .Lends_loop
.Lends_yes:
    mov w0, #1
    ret
.Lends_no:
    mov w0, #0
    ret
.size rbtl_asm_ends_with, .-rbtl_asm_ends_with

.global rbtl_asm_contains_bytes
.type rbtl_asm_contains_bytes, %function
rbtl_asm_contains_bytes:
    cbz x3, .Lcontains_yes
    cmp x3, x1
    b.hi .Lcontains_no
    sub x8, x1, x3
    mov x9, #0
.Lcontains_outer:
    cmp x9, x8
    b.hi .Lcontains_no
    mov x10, #0
.Lcontains_inner:
    cmp x10, x3
    b.hs .Lcontains_yes
    add x11, x9, x10
    ldrb w12, [x0, x11]
    ldrb w13, [x2, x10]
    cmp w12, w13
    b.ne .Lcontains_next
    add x10, x10, #1
    b .Lcontains_inner
.Lcontains_next:
    add x9, x9, #1
    b .Lcontains_outer
.Lcontains_yes:
    mov w0, #1
    ret
.Lcontains_no:
    mov w0, #0
    ret
.size rbtl_asm_contains_bytes, .-rbtl_asm_contains_bytes

.global rbtl_asm_count_ident
.type rbtl_asm_count_ident, %function
rbtl_asm_count_ident:
    mov x8, #0
.Lcount_ident_loop:
    cmp x8, x1
    b.hs .Lcount_ident_ret
    ldrb w9, [x0, x8]
    ident_byte w9, .Lcount_ident_next, .Lcount_ident_symbols
    mov x0, x8
    ret
.Lcount_ident_next:
    add x8, x8, #1
    b .Lcount_ident_loop
.Lcount_ident_ret:
    mov x0, x8
    ret
.size rbtl_asm_count_ident, .-rbtl_asm_count_ident

.global rbtl_asm_is_quote
.type rbtl_asm_is_quote, %function
rbtl_asm_is_quote:
    cmp w0, #34
    b.eq .Lis_quote_yes
    cmp w0, #39
    cset w0, eq
    ret
.Lis_quote_yes:
    mov w0, #1
    ret
.size rbtl_asm_is_quote, .-rbtl_asm_is_quote

.global rbtl_asm_find_comment_end
.type rbtl_asm_find_comment_end, %function
rbtl_asm_find_comment_end:
    mov x8, #0
.Lcomment_loop:
    add x9, x8, #2
    cmp x9, x1
    b.hs .Lcomment_none
    ldrb w10, [x0, x8]
    cmp w10, #45
    b.ne .Lcomment_next
    add x11, x8, #1
    ldrb w10, [x0, x11]
    cmp w10, #45
    b.ne .Lcomment_next
    ldrb w10, [x0, x9]
    cmp w10, #62
    b.ne .Lcomment_next
    add x0, x8, #3
    ret
.Lcomment_next:
    add x8, x8, #1
    b .Lcomment_loop
.Lcomment_none:
    add x0, x1, #1
    ret
.size rbtl_asm_find_comment_end, .-rbtl_asm_find_comment_end

.global rbtl_asm_len_fits_u32
.type rbtl_asm_len_fits_u32, %function
rbtl_asm_len_fits_u32:
    lsr x8, x0, #32
    cmp x8, #0
    cset w0, eq
    ret
.size rbtl_asm_len_fits_u32, .-rbtl_asm_len_fits_u32

.global rbtl_asm_selector_token_kind
.type rbtl_asm_selector_token_kind, %function
rbtl_asm_selector_token_kind:
    cmp w0, #35
    b.eq .Lselector_token_id
    cmp w0, #46
    b.eq .Lselector_token_class
    cmp w0, #42
    b.eq .Lselector_token_all
    cmp w0, #91
    b.eq .Lselector_token_attr
    mov w9, w0
    ident_byte w9, .Lselector_token_tag, .Lselector_token_symbols
    mov w0, #0
    ret
.Lselector_token_id:
    mov w0, #1
    ret
.Lselector_token_class:
    mov w0, #2
    ret
.Lselector_token_all:
    mov w0, #3
    ret
.Lselector_token_attr:
    mov w0, #4
    ret
.Lselector_token_tag:
    mov w0, #5
    ret
.size rbtl_asm_selector_token_kind, .-rbtl_asm_selector_token_kind

.global rbtl_asm_selector_attr_op_kind
.type rbtl_asm_selector_attr_op_kind, %function
rbtl_asm_selector_attr_op_kind:
    cmp w0, #93
    b.eq .Lattr_close
    cmp w0, #61
    b.eq .Lattr_equal
    cmp w0, #126
    b.eq .Lattr_tilde
    cmp w0, #94
    b.eq .Lattr_caret
    cmp w0, #36
    b.eq .Lattr_dollar
    cmp w0, #42
    b.eq .Lattr_star
    mov w0, #0
    ret
.Lattr_close:
    mov w0, #1
    ret
.Lattr_equal:
    mov w0, #2
    ret
.Lattr_tilde:
    mov w0, #3
    ret
.Lattr_caret:
    mov w0, #4
    ret
.Lattr_dollar:
    mov w0, #5
    ret
.Lattr_star:
    mov w0, #6
    ret
.size rbtl_asm_selector_attr_op_kind, .-rbtl_asm_selector_attr_op_kind

.global rbtl_asm_selector_combinator_kind
.type rbtl_asm_selector_combinator_kind, %function
rbtl_asm_selector_combinator_kind:
    cmp w0, #44
    b.eq .Lcomb_or
    cmp w0, #62
    b.eq .Lcomb_parent
    cbnz w1, .Lcomb_desc
    mov w0, #4
    ret
.Lcomb_or:
    mov w0, #1
    ret
.Lcomb_parent:
    mov w0, #2
    ret
.Lcomb_desc:
    mov w0, #3
    ret
.size rbtl_asm_selector_combinator_kind, .-rbtl_asm_selector_combinator_kind

.global rbtl_asm_usize_is_zero
.type rbtl_asm_usize_is_zero, %function
rbtl_asm_usize_is_zero:
    cmp x0, #0
    cset w0, eq
    ret
.size rbtl_asm_usize_is_zero, .-rbtl_asm_usize_is_zero

.global rbtl_asm_usize_lt
.type rbtl_asm_usize_lt, %function
rbtl_asm_usize_lt:
    cmp x0, x1
    cset w0, lo
    ret
.size rbtl_asm_usize_lt, .-rbtl_asm_usize_lt

.global rbtl_asm_usize_ge
.type rbtl_asm_usize_ge, %function
rbtl_asm_usize_ge:
    cmp x0, x1
    cset w0, hs
    ret
.size rbtl_asm_usize_ge, .-rbtl_asm_usize_ge

.global rbtl_asm_usize_min
.type rbtl_asm_usize_min, %function
rbtl_asm_usize_min:
    cmp x0, x1
    csel x0, x0, x1, ls
    ret
.size rbtl_asm_usize_min, .-rbtl_asm_usize_min

.global rbtl_asm_usize_add
.type rbtl_asm_usize_add, %function
rbtl_asm_usize_add:
    add x0, x0, x1
    ret
.size rbtl_asm_usize_add, .-rbtl_asm_usize_add

.global rbtl_asm_usize_sub_one
.type rbtl_asm_usize_sub_one, %function
rbtl_asm_usize_sub_one:
    sub x0, x0, #1
    ret
.size rbtl_asm_usize_sub_one, .-rbtl_asm_usize_sub_one

.global rbtl_asm_scan_html_event
.type rbtl_asm_scan_html_event, %function
rbtl_asm_scan_html_event:
    cmp x2, x1
    b.hs .Lscan_event_none
    str x2, [x3]
    str xzr, [x4]
    ldrb w8, [x0, x2]
    cmp w8, #60
    b.ne .Lscan_event_text
    mov w0, #2
    ret
.Lscan_event_text:
    mov x8, x2
.Lscan_event_text_loop:
    cmp x8, x1
    b.hs .Lscan_event_text_emit
    ldrb w9, [x0, x8]
    cmp w9, #60
    b.eq .Lscan_event_text_emit
    add x8, x8, #1
    b .Lscan_event_text_loop
.Lscan_event_text_emit:
    sub x9, x8, x2
    str x9, [x4]
    mov w0, #1
    ret
.Lscan_event_none:
    mov w0, #0
    ret
.size rbtl_asm_scan_html_event, .-rbtl_asm_scan_html_event

.global rbtl_asm_next_ascii_token
.type rbtl_asm_next_ascii_token, %function
rbtl_asm_next_ascii_token:
    mov x8, x2
.Lnext_token_skip:
    cmp x8, x1
    b.hs .Lnext_token_none
    ldrb w9, [x0, x8]
    cmp w9, #32
    b.eq .Lnext_token_skip_one
    cmp w9, #9
    b.lo .Lnext_token_start
    cmp w9, #13
    b.ls .Lnext_token_skip_one
    b .Lnext_token_start
.Lnext_token_skip_one:
    add x8, x8, #1
    b .Lnext_token_skip
.Lnext_token_start:
    mov x9, x8
.Lnext_token_scan:
    cmp x8, x1
    b.hs .Lnext_token_emit
    ldrb w10, [x0, x8]
    cmp w10, #32
    b.eq .Lnext_token_emit
    cmp w10, #9
    b.lo .Lnext_token_scan_one
    cmp w10, #13
    b.ls .Lnext_token_emit
.Lnext_token_scan_one:
    add x8, x8, #1
    b .Lnext_token_scan
.Lnext_token_emit:
    str x9, [x3]
    sub x10, x8, x9
    str x10, [x4]
    mov x0, x8
    ret
.Lnext_token_none:
    add x0, x1, #1
    ret
.size rbtl_asm_next_ascii_token, .-rbtl_asm_next_ascii_token

.global rbtl_asm_parse_attr
.type rbtl_asm_parse_attr, %function
rbtl_asm_parse_attr:
    b rbtl_rust_asm_parse_attr
.size rbtl_asm_parse_attr, .-rbtl_asm_parse_attr

.global rbtl_asm_parse_document
.type rbtl_asm_parse_document, %function
rbtl_asm_parse_document:
    b rbtl_rust_asm_parse_document
.size rbtl_asm_parse_document, .-rbtl_asm_parse_document

.global rbtl_asm_simple_selector_kind
.type rbtl_asm_simple_selector_kind, %function
rbtl_asm_simple_selector_kind:
    cbz x1, .Lsimple_none
    str xzr, [x2]
    cmp x1, #1
    b.ne .Lsimple_not_all
    ldrb w8, [x0]
    cmp w8, #42
    b.ne .Lsimple_not_all
    mov w0, #1
    ret
.Lsimple_not_all:
    ldrb w8, [x0]
    cmp w8, #35
    b.eq .Lsimple_leading_id
    cmp w8, #46
    b.eq .Lsimple_leading_class
    mov x8, #0
.Lsimple_tag_scan:
    cmp x8, x1
    b.hs .Lsimple_tag_only
    ldrb w9, [x0, x8]
    ident_byte w9, .Lsimple_tag_next, .Lsimple_tag_symbols
    b .Lsimple_tag_done
.Lsimple_tag_next:
    add x8, x8, #1
    b .Lsimple_tag_scan
.Lsimple_tag_only:
    cbz x8, .Lsimple_none
    str x8, [x2]
    mov w0, #2
    ret
.Lsimple_tag_done:
    cbz x8, .Lsimple_none
    mov x10, x8
    add x8, x8, #1
    cmp x8, x1
    b.hs .Lsimple_none
    ldrb w9, [x0, x10]
    cmp w9, #35
    b.eq .Lsimple_tag_id_rest
    cmp w9, #46
    b.eq .Lsimple_tag_class_rest
    b .Lsimple_none
.Lsimple_leading_id:
    mov x8, #1
    mov w10, #3
    b .Lsimple_rest
.Lsimple_leading_class:
    mov x8, #1
    mov w10, #4
    b .Lsimple_rest
.Lsimple_tag_id_rest:
    str x10, [x2]
    mov w10, #5
    b .Lsimple_rest
.Lsimple_tag_class_rest:
    str x10, [x2]
    mov w10, #6
.Lsimple_rest:
    cmp x8, x1
    b.hs .Lsimple_none
.Lsimple_rest_loop:
    cmp x8, x1
    b.hs .Lsimple_emit_rest
    ldrb w9, [x0, x8]
    ident_byte w9, .Lsimple_rest_next, .Lsimple_rest_symbols
    b .Lsimple_none
.Lsimple_rest_next:
    add x8, x8, #1
    b .Lsimple_rest_loop
.Lsimple_emit_rest:
    mov w0, w10
    ret
.Lsimple_none:
    mov w0, #0
    ret
.size rbtl_asm_simple_selector_kind, .-rbtl_asm_simple_selector_kind

.section .note.GNU-stack,"",%progbits
