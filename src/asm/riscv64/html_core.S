.text

.macro ident_byte reg, yes, no
    li t6, '0'
    bltu \reg, t6, \no
    li t6, '9'
    bleu \reg, t6, \yes
    li t6, 'A'
    bltu \reg, t6, \no
    li t6, 'Z'
    bleu \reg, t6, \yes
    li t6, 'a'
    bltu \reg, t6, \no
    li t6, 'z'
    bleu \reg, t6, \yes
\no:
    li t6, '-'
    beq \reg, t6, \yes
    li t6, '_'
    beq \reg, t6, \yes
    li t6, '/'
    beq \reg, t6, \yes
    li t6, ':'
    beq \reg, t6, \yes
    li t6, '+'
    beq \reg, t6, \yes
.endm

.global rbtl_asm_search_non_ident
.type rbtl_asm_search_non_ident, @function
rbtl_asm_search_non_ident:
    li t0, 0
.Lsearch_non_ident_loop:
    bgeu t0, a1, .Lsearch_non_ident_none
    add t1, a0, t0
    lbu t2, 0(t1)
    ident_byte t2, .Lsearch_non_ident_next, .Lsearch_non_ident_symbols
    mv a0, t0
    ret
.Lsearch_non_ident_next:
    addi t0, t0, 1
    j .Lsearch_non_ident_loop
.Lsearch_non_ident_none:
    mv a0, a1
    ret
.size rbtl_asm_search_non_ident, .-rbtl_asm_search_non_ident

.global rbtl_asm_selector_kind
.type rbtl_asm_selector_kind, @function
rbtl_asm_selector_kind:
    beqz a1, .Lselector_kind_none
    li t0, 0
    li t1, 0
.Lselector_kind_skip:
    bgeu t0, a1, .Lselector_kind_none
    add t2, a0, t0
    lbu t3, 0(t2)
    li t4, ' '
    bne t3, t4, .Lselector_kind_loop
    addi t0, t0, 1
    j .Lselector_kind_skip
.Lselector_kind_loop:
    bgeu t0, a1, .Lselector_kind_done
    add t2, a0, t0
    lbu t3, 0(t2)
    li t4, '#'
    beq t3, t4, .Lselector_kind_hash
    li t4, '.'
    beq t3, t4, .Lselector_kind_dot
    li t4, ' '
    beq t3, t4, .Lselector_kind_none
    li t4, '>'
    beq t3, t4, .Lselector_kind_none
    li t4, ','
    beq t3, t4, .Lselector_kind_none
    addi t0, t0, 1
    j .Lselector_kind_loop
.Lselector_kind_hash:
    ori t1, t1, 1
    addi t0, t0, 1
    j .Lselector_kind_loop
.Lselector_kind_dot:
    ori t1, t1, 2
    addi t0, t0, 1
    j .Lselector_kind_loop
.Lselector_kind_done:
    addi a0, t1, 1
    ret
.Lselector_kind_none:
    li a0, 0
    ret
.size rbtl_asm_selector_kind, .-rbtl_asm_selector_kind

.global rbtl_asm_matches_case_insensitive
.type rbtl_asm_matches_case_insensitive, @function
rbtl_asm_matches_case_insensitive:
    li t0, 0
.Lcase_loop:
    bgeu t0, a2, .Lcase_yes
    add t1, a0, t0
    lbu t2, 0(t1)
    li t3, 'A'
    bltu t2, t3, .Lcase_compare
    li t3, 'Z'
    bgtu t2, t3, .Lcase_compare
    addi t2, t2, 32
.Lcase_compare:
    add t1, a1, t0
    lbu t3, 0(t1)
    bne t2, t3, .Lcase_no
    addi t0, t0, 1
    j .Lcase_loop
.Lcase_yes:
    li a0, 1
    ret
.Lcase_no:
    li a0, 0
    ret
.size rbtl_asm_matches_case_insensitive, .-rbtl_asm_matches_case_insensitive

.global rbtl_asm_count_while2
.type rbtl_asm_count_while2, @function
rbtl_asm_count_while2:
    li t0, 0
.Lcount_while2_loop:
    bgeu t0, a1, .Lcount_while2_ret
    add t1, a0, t0
    lbu t2, 0(t1)
    beq t2, a2, .Lcount_while2_next
    beq t2, a3, .Lcount_while2_next
    mv a0, t0
    ret
.Lcount_while2_next:
    addi t0, t0, 1
    j .Lcount_while2_loop
.Lcount_while2_ret:
    mv a0, t0
    ret
.size rbtl_asm_count_while2, .-rbtl_asm_count_while2

.global rbtl_asm_is_void_tag
.type rbtl_asm_is_void_tag, @function
rbtl_asm_is_void_tag:
    li t0, 2
    beq a1, t0, .Lvoid_len2
    li t0, 3
    beq a1, t0, .Lvoid_len3
    li t0, 4
    beq a1, t0, .Lvoid_len4
    li t0, 5
    beq a1, t0, .Lvoid_len5
    li t0, 6
    beq a1, t0, .Lvoid_len6
    li t0, 7
    beq a1, t0, .Lvoid_len7
    li a0, 0
    ret
.Lvoid_len2:
    lbu t0, 0(a0)
    lbu t1, 1(a0)
    li t2, 'b'
    beq t0, t2, .Lvoid_br
    li t2, 'h'
    bne t0, t2, .Lvoid_no
.Lvoid_br:
    li t2, 'r'
    sub t3, t1, t2
    seqz a0, t3
    ret
.Lvoid_len3:
    lbu t0, 0(a0)
    li t1, 'c'
    beq t0, t1, .Lvoid_col
    li t1, 'i'
    bne t0, t1, .Lvoid_no
    lbu t0, 1(a0)
    li t1, 'm'
    bne t0, t1, .Lvoid_no
    lbu t0, 2(a0)
    li t1, 'g'
    sub t2, t0, t1
    seqz a0, t2
    ret
.Lvoid_col:
    lbu t0, 1(a0)
    li t1, 'o'
    bne t0, t1, .Lvoid_no
    lbu t0, 2(a0)
    li t1, 'l'
    sub t2, t0, t1
    seqz a0, t2
    ret
.Lvoid_len4:
    lwu t0, 0(a0)
    li t1, 0x61657261
    beq t0, t1, .Lvoid_yes
    li t1, 0x65736162
    beq t0, t1, .Lvoid_yes
    li t1, 0x6b6e696c
    beq t0, t1, .Lvoid_yes
    li t1, 0x6174656d
    beq t0, t1, .Lvoid_yes
    li t1, 0x00726277
    sub t2, t0, t1
    seqz a0, t2
    ret
.Lvoid_len5:
    lwu t0, 0(a0)
    lbu t2, 4(a0)
    li t1, 0x65626d65
    bne t0, t1, .Lvoid_input
    li t1, 'd'
    sub t3, t2, t1
    seqz a0, t3
    ret
.Lvoid_input:
    li t1, 0x75706e69
    bne t0, t1, .Lvoid_param
    li t1, 't'
    sub t3, t2, t1
    seqz a0, t3
    ret
.Lvoid_param:
    li t1, 0x61726170
    bne t0, t1, .Lvoid_track
    li t1, 'm'
    sub t3, t2, t1
    seqz a0, t3
    ret
.Lvoid_track:
    li t1, 0x63617274
    bne t0, t1, .Lvoid_no
    li t1, 'k'
    sub t3, t2, t1
    seqz a0, t3
    ret
.Lvoid_len6:
    lwu t0, 0(a0)
    li t1, 0x72756f73
    bne t0, t1, .Lvoid_no
    lbu t0, 4(a0)
    li t1, 'c'
    bne t0, t1, .Lvoid_no
    lbu t0, 5(a0)
    li t1, 'e'
    sub t2, t0, t1
    seqz a0, t2
    ret
.Lvoid_len7:
    lwu t0, 0(a0)
    li t1, 0x6d6d6f63
    beq t0, t1, .Lvoid_command
    li t1, 0x6779656b
    beq t0, t1, .Lvoid_keygen
    j .Lvoid_no
.Lvoid_command:
    lbu t0, 4(a0)
    li t1, 'a'
    bne t0, t1, .Lvoid_no
    lbu t0, 5(a0)
    li t1, 'n'
    bne t0, t1, .Lvoid_no
    lbu t0, 6(a0)
    li t1, 'd'
    sub t2, t0, t1
    seqz a0, t2
    ret
.Lvoid_keygen:
    lbu t0, 4(a0)
    li t1, 'e'
    bne t0, t1, .Lvoid_no
    lbu t0, 5(a0)
    li t1, 'n'
    sub t2, t0, t1
    seqz a0, t2
    ret
.Lvoid_yes:
    li a0, 1
    ret
.Lvoid_no:
    li a0, 0
    ret
.size rbtl_asm_is_void_tag, .-rbtl_asm_is_void_tag

.global rbtl_asm_bytes_eq
.type rbtl_asm_bytes_eq, @function
rbtl_asm_bytes_eq:
    li t0, 0
.Lbytes_eq_loop:
    bgeu t0, a2, .Lbytes_eq_yes
    add t1, a0, t0
    add t2, a1, t0
    lbu t3, 0(t1)
    lbu t4, 0(t2)
    bne t3, t4, .Lbytes_eq_no
    addi t0, t0, 1
    j .Lbytes_eq_loop
.Lbytes_eq_yes:
    li a0, 1
    ret
.Lbytes_eq_no:
    li a0, 0
    ret
.size rbtl_asm_bytes_eq, .-rbtl_asm_bytes_eq

.global rbtl_asm_contains_ascii_whitespace_token
.type rbtl_asm_contains_ascii_whitespace_token, @function
rbtl_asm_contains_ascii_whitespace_token:
    beqz a3, .Ltoken_no
    li t0, 0
.Ltoken_skip:
    bgeu t0, a1, .Ltoken_no
    add t1, a0, t0
    lbu t2, 0(t1)
    li t3, ' '
    beq t2, t3, .Ltoken_skip_one
    li t3, 9
    bltu t2, t3, .Ltoken_start
    li t3, 13
    bleu t2, t3, .Ltoken_skip_one
    j .Ltoken_start
.Ltoken_skip_one:
    addi t0, t0, 1
    j .Ltoken_skip
.Ltoken_start:
    mv t4, t0
.Ltoken_scan:
    bgeu t0, a1, .Ltoken_check
    add t1, a0, t0
    lbu t2, 0(t1)
    li t3, ' '
    beq t2, t3, .Ltoken_check
    li t3, 9
    bltu t2, t3, .Ltoken_scan_one
    li t3, 13
    bleu t2, t3, .Ltoken_check
.Ltoken_scan_one:
    addi t0, t0, 1
    j .Ltoken_scan
.Ltoken_check:
    sub t5, t0, t4
    bne t5, a3, .Ltoken_after
    li t5, 0
.Ltoken_cmp:
    bgeu t5, a3, .Ltoken_yes
    add t1, t4, t5
    add t1, a0, t1
    add t2, a2, t5
    lbu t3, 0(t1)
    lbu t6, 0(t2)
    bne t3, t6, .Ltoken_after
    addi t5, t5, 1
    j .Ltoken_cmp
.Ltoken_after:
    bgeu t0, a1, .Ltoken_no
    addi t0, t0, 1
    j .Ltoken_skip
.Ltoken_yes:
    li a0, 1
    ret
.Ltoken_no:
    li a0, 0
    ret
.size rbtl_asm_contains_ascii_whitespace_token, .-rbtl_asm_contains_ascii_whitespace_token

.global rbtl_asm_count_spaces
.type rbtl_asm_count_spaces, @function
rbtl_asm_count_spaces:
    li t0, 0
.Lcount_spaces_loop:
    bgeu t0, a1, .Lcount_spaces_ret
    add t1, a0, t0
    lbu t2, 0(t1)
    li t3, ' '
    bne t2, t3, .Lcount_spaces_ret
    addi t0, t0, 1
    j .Lcount_spaces_loop
.Lcount_spaces_ret:
    mv a0, t0
    ret
.size rbtl_asm_count_spaces, .-rbtl_asm_count_spaces

.global rbtl_asm_starts_with
.type rbtl_asm_starts_with, @function
rbtl_asm_starts_with:
    bgtu a3, a1, .Lstarts_no
    li t0, 0
.Lstarts_loop:
    bgeu t0, a3, .Lstarts_yes
    add t1, a0, t0
    add t2, a2, t0
    lbu t3, 0(t1)
    lbu t4, 0(t2)
    bne t3, t4, .Lstarts_no
    addi t0, t0, 1
    j .Lstarts_loop
.Lstarts_yes:
    li a0, 1
    ret
.Lstarts_no:
    li a0, 0
    ret
.size rbtl_asm_starts_with, .-rbtl_asm_starts_with

.global rbtl_asm_ends_with
.type rbtl_asm_ends_with, @function
rbtl_asm_ends_with:
    bgtu a3, a1, .Lends_no
    sub t0, a1, a3
    li t1, 0
.Lends_loop:
    bgeu t1, a3, .Lends_yes
    add t2, t0, t1
    add t2, a0, t2
    add t3, a2, t1
    lbu t4, 0(t2)
    lbu t5, 0(t3)
    bne t4, t5, .Lends_no
    addi t1, t1, 1
    j .Lends_loop
.Lends_yes:
    li a0, 1
    ret
.Lends_no:
    li a0, 0
    ret
.size rbtl_asm_ends_with, .-rbtl_asm_ends_with

.global rbtl_asm_contains_bytes
.type rbtl_asm_contains_bytes, @function
rbtl_asm_contains_bytes:
    beqz a3, .Lcontains_yes
    bgtu a3, a1, .Lcontains_no
    sub t0, a1, a3
    li t1, 0
.Lcontains_outer:
    bgtu t1, t0, .Lcontains_no
    li t2, 0
.Lcontains_inner:
    bgeu t2, a3, .Lcontains_yes
    add t3, t1, t2
    add t3, a0, t3
    add t4, a2, t2
    lbu t5, 0(t3)
    lbu t6, 0(t4)
    bne t5, t6, .Lcontains_next
    addi t2, t2, 1
    j .Lcontains_inner
.Lcontains_next:
    addi t1, t1, 1
    j .Lcontains_outer
.Lcontains_yes:
    li a0, 1
    ret
.Lcontains_no:
    li a0, 0
    ret
.size rbtl_asm_contains_bytes, .-rbtl_asm_contains_bytes

.global rbtl_asm_count_ident
.type rbtl_asm_count_ident, @function
rbtl_asm_count_ident:
    li t0, 0
.Lcount_ident_loop:
    bgeu t0, a1, .Lcount_ident_ret
    add t1, a0, t0
    lbu t2, 0(t1)
    ident_byte t2, .Lcount_ident_next, .Lcount_ident_symbols
    mv a0, t0
    ret
.Lcount_ident_next:
    addi t0, t0, 1
    j .Lcount_ident_loop
.Lcount_ident_ret:
    mv a0, t0
    ret
.size rbtl_asm_count_ident, .-rbtl_asm_count_ident

.global rbtl_asm_is_quote
.type rbtl_asm_is_quote, @function
rbtl_asm_is_quote:
    li t0, '"'
    beq a0, t0, .Lis_quote_yes
    li t0, 39
    sub t1, a0, t0
    seqz a0, t1
    ret
.Lis_quote_yes:
    li a0, 1
    ret
.size rbtl_asm_is_quote, .-rbtl_asm_is_quote

.global rbtl_asm_find_comment_end
.type rbtl_asm_find_comment_end, @function
rbtl_asm_find_comment_end:
    li t0, 0
.Lcomment_loop:
    addi t1, t0, 2
    bgeu t1, a1, .Lcomment_none
    add t2, a0, t0
    lbu t3, 0(t2)
    li t4, '-'
    bne t3, t4, .Lcomment_next
    lbu t3, 1(t2)
    bne t3, t4, .Lcomment_next
    lbu t3, 2(t2)
    li t4, '>'
    bne t3, t4, .Lcomment_next
    addi a0, t0, 3
    ret
.Lcomment_next:
    addi t0, t0, 1
    j .Lcomment_loop
.Lcomment_none:
    addi a0, a1, 1
    ret
.size rbtl_asm_find_comment_end, .-rbtl_asm_find_comment_end

.global rbtl_asm_len_fits_u32
.type rbtl_asm_len_fits_u32, @function
rbtl_asm_len_fits_u32:
    srli t0, a0, 32
    seqz a0, t0
    ret
.size rbtl_asm_len_fits_u32, .-rbtl_asm_len_fits_u32

.global rbtl_asm_selector_token_kind
.type rbtl_asm_selector_token_kind, @function
rbtl_asm_selector_token_kind:
    li t0, '#'
    beq a0, t0, .Lselector_token_id
    li t0, '.'
    beq a0, t0, .Lselector_token_class
    li t0, '*'
    beq a0, t0, .Lselector_token_all
    li t0, '['
    beq a0, t0, .Lselector_token_attr
    mv t2, a0
    ident_byte t2, .Lselector_token_tag, .Lselector_token_symbols
    li a0, 0
    ret
.Lselector_token_id:
    li a0, 1
    ret
.Lselector_token_class:
    li a0, 2
    ret
.Lselector_token_all:
    li a0, 3
    ret
.Lselector_token_attr:
    li a0, 4
    ret
.Lselector_token_tag:
    li a0, 5
    ret
.size rbtl_asm_selector_token_kind, .-rbtl_asm_selector_token_kind

.global rbtl_asm_selector_attr_op_kind
.type rbtl_asm_selector_attr_op_kind, @function
rbtl_asm_selector_attr_op_kind:
    li t0, ']'
    beq a0, t0, .Lattr_close
    li t0, '='
    beq a0, t0, .Lattr_equal
    li t0, '~'
    beq a0, t0, .Lattr_tilde
    li t0, '^'
    beq a0, t0, .Lattr_caret
    li t0, '$'
    beq a0, t0, .Lattr_dollar
    li t0, '*'
    beq a0, t0, .Lattr_star
    li a0, 0
    ret
.Lattr_close:
    li a0, 1
    ret
.Lattr_equal:
    li a0, 2
    ret
.Lattr_tilde:
    li a0, 3
    ret
.Lattr_caret:
    li a0, 4
    ret
.Lattr_dollar:
    li a0, 5
    ret
.Lattr_star:
    li a0, 6
    ret
.size rbtl_asm_selector_attr_op_kind, .-rbtl_asm_selector_attr_op_kind

.global rbtl_asm_selector_combinator_kind
.type rbtl_asm_selector_combinator_kind, @function
rbtl_asm_selector_combinator_kind:
    li t0, ','
    beq a0, t0, .Lcomb_or
    li t0, '>'
    beq a0, t0, .Lcomb_parent
    bnez a1, .Lcomb_desc
    li a0, 4
    ret
.Lcomb_or:
    li a0, 1
    ret
.Lcomb_parent:
    li a0, 2
    ret
.Lcomb_desc:
    li a0, 3
    ret
.size rbtl_asm_selector_combinator_kind, .-rbtl_asm_selector_combinator_kind

.global rbtl_asm_usize_is_zero
.type rbtl_asm_usize_is_zero, @function
rbtl_asm_usize_is_zero:
    seqz a0, a0
    ret
.size rbtl_asm_usize_is_zero, .-rbtl_asm_usize_is_zero

.global rbtl_asm_usize_lt
.type rbtl_asm_usize_lt, @function
rbtl_asm_usize_lt:
    sltu a0, a0, a1
    ret
.size rbtl_asm_usize_lt, .-rbtl_asm_usize_lt

.global rbtl_asm_usize_ge
.type rbtl_asm_usize_ge, @function
rbtl_asm_usize_ge:
    sltu a0, a0, a1
    xori a0, a0, 1
    ret
.size rbtl_asm_usize_ge, .-rbtl_asm_usize_ge

.global rbtl_asm_usize_min
.type rbtl_asm_usize_min, @function
rbtl_asm_usize_min:
    bleu a0, a1, .Lmin_ret
    mv a0, a1
.Lmin_ret:
    ret
.size rbtl_asm_usize_min, .-rbtl_asm_usize_min

.global rbtl_asm_usize_add
.type rbtl_asm_usize_add, @function
rbtl_asm_usize_add:
    add a0, a0, a1
    ret
.size rbtl_asm_usize_add, .-rbtl_asm_usize_add

.global rbtl_asm_usize_sub_one
.type rbtl_asm_usize_sub_one, @function
rbtl_asm_usize_sub_one:
    addi a0, a0, -1
    ret
.size rbtl_asm_usize_sub_one, .-rbtl_asm_usize_sub_one

.global rbtl_asm_scan_html_event
.type rbtl_asm_scan_html_event, @function
rbtl_asm_scan_html_event:
    bgeu a2, a1, .Lscan_event_none
    sd a2, 0(a3)
    sd zero, 0(a4)
    add t0, a0, a2
    lbu t1, 0(t0)
    li t2, '<'
    bne t1, t2, .Lscan_event_text
    li a0, 2
    ret
.Lscan_event_text:
    mv t0, a2
.Lscan_event_text_loop:
    bgeu t0, a1, .Lscan_event_text_emit
    add t1, a0, t0
    lbu t2, 0(t1)
    li t3, '<'
    beq t2, t3, .Lscan_event_text_emit
    addi t0, t0, 1
    j .Lscan_event_text_loop
.Lscan_event_text_emit:
    sub t1, t0, a2
    sd t1, 0(a4)
    li a0, 1
    ret
.Lscan_event_none:
    li a0, 0
    ret
.size rbtl_asm_scan_html_event, .-rbtl_asm_scan_html_event

.global rbtl_asm_next_ascii_token
.type rbtl_asm_next_ascii_token, @function
rbtl_asm_next_ascii_token:
    mv t0, a2
.Lnext_token_skip:
    bgeu t0, a1, .Lnext_token_none
    add t1, a0, t0
    lbu t2, 0(t1)
    li t3, ' '
    beq t2, t3, .Lnext_token_skip_one
    li t3, 9
    bltu t2, t3, .Lnext_token_start
    li t3, 13
    bleu t2, t3, .Lnext_token_skip_one
    j .Lnext_token_start
.Lnext_token_skip_one:
    addi t0, t0, 1
    j .Lnext_token_skip
.Lnext_token_start:
    mv t4, t0
.Lnext_token_scan:
    bgeu t0, a1, .Lnext_token_emit
    add t1, a0, t0
    lbu t2, 0(t1)
    li t3, ' '
    beq t2, t3, .Lnext_token_emit
    li t3, 9
    bltu t2, t3, .Lnext_token_scan_one
    li t3, 13
    bleu t2, t3, .Lnext_token_emit
.Lnext_token_scan_one:
    addi t0, t0, 1
    j .Lnext_token_scan
.Lnext_token_emit:
    sd t4, 0(a3)
    sub t1, t0, t4
    sd t1, 0(a4)
    mv a0, t0
    ret
.Lnext_token_none:
    addi a0, a1, 1
    ret
.size rbtl_asm_next_ascii_token, .-rbtl_asm_next_ascii_token

.global rbtl_asm_parse_attr
.type rbtl_asm_parse_attr, @function
rbtl_asm_parse_attr:
    tail rbtl_rust_asm_parse_attr
.size rbtl_asm_parse_attr, .-rbtl_asm_parse_attr

.global rbtl_asm_parse_document
.type rbtl_asm_parse_document, @function
rbtl_asm_parse_document:
    tail rbtl_rust_asm_parse_document
.size rbtl_asm_parse_document, .-rbtl_asm_parse_document

.global rbtl_asm_simple_selector_kind
.type rbtl_asm_simple_selector_kind, @function
rbtl_asm_simple_selector_kind:
    beqz a1, .Lsimple_none
    sd zero, 0(a2)
    li t0, 1
    bne a1, t0, .Lsimple_not_all
    lbu t1, 0(a0)
    li t2, '*'
    bne t1, t2, .Lsimple_not_all
    li a0, 1
    ret
.Lsimple_not_all:
    lbu t1, 0(a0)
    li t2, '#'
    beq t1, t2, .Lsimple_leading_id
    li t2, '.'
    beq t1, t2, .Lsimple_leading_class
    li t0, 0
.Lsimple_tag_scan:
    bgeu t0, a1, .Lsimple_tag_only
    add t2, a0, t0
    lbu t3, 0(t2)
    ident_byte t3, .Lsimple_tag_next, .Lsimple_tag_symbols
    j .Lsimple_tag_done
.Lsimple_tag_next:
    addi t0, t0, 1
    j .Lsimple_tag_scan
.Lsimple_tag_only:
    beqz t0, .Lsimple_none
    sd t0, 0(a2)
    li a0, 2
    ret
.Lsimple_tag_done:
    beqz t0, .Lsimple_none
    mv t4, t0
    addi t0, t0, 1
    bgeu t0, a1, .Lsimple_none
    add t2, a0, t4
    lbu t3, 0(t2)
    li t2, '#'
    beq t3, t2, .Lsimple_tag_id_rest
    li t2, '.'
    beq t3, t2, .Lsimple_tag_class_rest
    j .Lsimple_none
.Lsimple_leading_id:
    li t0, 1
    li t4, 3
    j .Lsimple_rest
.Lsimple_leading_class:
    li t0, 1
    li t4, 4
    j .Lsimple_rest
.Lsimple_tag_id_rest:
    sd t4, 0(a2)
    li t4, 5
    j .Lsimple_rest
.Lsimple_tag_class_rest:
    sd t4, 0(a2)
    li t4, 6
.Lsimple_rest:
    bgeu t0, a1, .Lsimple_none
.Lsimple_rest_loop:
    bgeu t0, a1, .Lsimple_emit_rest
    add t2, a0, t0
    lbu t3, 0(t2)
    ident_byte t3, .Lsimple_rest_next, .Lsimple_rest_symbols
    j .Lsimple_none
.Lsimple_rest_next:
    addi t0, t0, 1
    j .Lsimple_rest_loop
.Lsimple_emit_rest:
    mv a0, t4
    ret
.Lsimple_none:
    li a0, 0
    ret
.size rbtl_asm_simple_selector_kind, .-rbtl_asm_simple_selector_kind

.section .note.GNU-stack,"",@progbits
