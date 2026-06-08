OPTION CASEMAP:NONE

EXTERN rbtl_rust_msvc_parse_attr:PROC
EXTERN rbtl_rust_msvc_parse_document:PROC

.code

rbtl_is_ident_byte PROC
    cmp cl, '0'
    jb ident_symbols
    cmp cl, '9'
    jbe ident_yes
    cmp cl, 'A'
    jb ident_symbols
    cmp cl, 'Z'
    jbe ident_yes
    cmp cl, 'a'
    jb ident_symbols
    cmp cl, 'z'
    jbe ident_yes
ident_symbols:
    cmp cl, '-'
    je ident_yes
    cmp cl, '_'
    je ident_yes
    cmp cl, '/'
    je ident_yes
    cmp cl, ':'
    je ident_yes
    cmp cl, '+'
    je ident_yes
    xor eax, eax
    ret
ident_yes:
    mov eax, 1
    ret
rbtl_is_ident_byte ENDP

PUBLIC rbtl_asm_search_non_ident
rbtl_asm_search_non_ident PROC
    xor rax, rax
scan_non_ident_loop:
    cmp rax, rdx
    jae scan_non_ident_none
    mov r10b, BYTE PTR [rcx + rax]
    cmp r10b, '0'
    jb scan_non_ident_symbols
    cmp r10b, '9'
    jbe scan_non_ident_next
    cmp r10b, 'A'
    jb scan_non_ident_symbols
    cmp r10b, 'Z'
    jbe scan_non_ident_next
    cmp r10b, 'a'
    jb scan_non_ident_symbols
    cmp r10b, 'z'
    jbe scan_non_ident_next
scan_non_ident_symbols:
    cmp r10b, '-'
    je scan_non_ident_next
    cmp r10b, '_'
    je scan_non_ident_next
    cmp r10b, '/'
    je scan_non_ident_next
    cmp r10b, ':'
    je scan_non_ident_next
    cmp r10b, '+'
    je scan_non_ident_next
    ret
scan_non_ident_next:
    inc rax
    jmp scan_non_ident_loop
scan_non_ident_none:
    mov rax, rdx
    ret
rbtl_asm_search_non_ident ENDP

PUBLIC rbtl_asm_selector_kind
rbtl_asm_selector_kind PROC
    test rdx, rdx
    je selector_kind_none
    xor rax, rax
    xor r8d, r8d
selector_kind_skip:
    cmp rax, rdx
    jae selector_kind_none
    cmp BYTE PTR [rcx + rax], ' '
    jne selector_kind_loop
    inc rax
    jmp selector_kind_skip
selector_kind_loop:
    cmp rax, rdx
    jae selector_kind_done
    mov r9b, BYTE PTR [rcx + rax]
    cmp r9b, '#'
    je selector_kind_hash
    cmp r9b, '.'
    je selector_kind_dot
    cmp r9b, ' '
    je selector_kind_none
    cmp r9b, '>'
    je selector_kind_none
    cmp r9b, ','
    je selector_kind_none
    inc rax
    jmp selector_kind_loop
selector_kind_hash:
    or r8d, 1
    inc rax
    jmp selector_kind_loop
selector_kind_dot:
    or r8d, 2
    inc rax
    jmp selector_kind_loop
selector_kind_done:
    mov eax, r8d
    inc eax
    ret
selector_kind_none:
    xor eax, eax
    ret
rbtl_asm_selector_kind ENDP

PUBLIC rbtl_asm_matches_case_insensitive
rbtl_asm_matches_case_insensitive PROC
    xor rax, rax
case_loop:
    cmp rax, r8
    jae case_yes
    mov r9b, BYTE PTR [rcx + rax]
    cmp r9b, 'A'
    jb case_compare
    cmp r9b, 'Z'
    ja case_compare
    add r9b, 32
case_compare:
    cmp r9b, BYTE PTR [rdx + rax]
    jne case_no
    inc rax
    jmp case_loop
case_yes:
    mov eax, 1
    ret
case_no:
    xor eax, eax
    ret
rbtl_asm_matches_case_insensitive ENDP

PUBLIC rbtl_asm_count_while2
rbtl_asm_count_while2 PROC
    xor rax, rax
count_while2_loop:
    cmp rax, rdx
    jae count_while2_ret
    mov r10b, BYTE PTR [rcx + rax]
    cmp r10b, r8b
    je count_while2_next
    cmp r10b, r9b
    je count_while2_next
    ret
count_while2_next:
    inc rax
    jmp count_while2_loop
count_while2_ret:
    ret
rbtl_asm_count_while2 ENDP

PUBLIC rbtl_asm_is_void_tag
rbtl_asm_is_void_tag PROC
    cmp rdx, 2
    je void_len2
    cmp rdx, 3
    je void_len3
    cmp rdx, 4
    je void_len4
    cmp rdx, 5
    je void_len5
    cmp rdx, 6
    je void_len6
    cmp rdx, 7
    je void_len7
    xor eax, eax
    ret
void_len2:
    cmp WORD PTR [rcx], 'rb'
    je void_yes
    cmp WORD PTR [rcx], 'rh'
    je void_yes
    xor eax, eax
    ret
void_len3:
    cmp BYTE PTR [rcx], 'c'
    je void_col
    cmp BYTE PTR [rcx], 'i'
    jne void_no
    cmp BYTE PTR [rcx + 1], 'm'
    jne void_no
    cmp BYTE PTR [rcx + 2], 'g'
    je void_yes
    xor eax, eax
    ret
void_col:
    cmp BYTE PTR [rcx + 1], 'o'
    jne void_no
    cmp BYTE PTR [rcx + 2], 'l'
    je void_yes
    jmp void_no
void_len4:
    cmp DWORD PTR [rcx], 'aera'
    je void_yes
    cmp DWORD PTR [rcx], 'esab'
    je void_yes
    cmp DWORD PTR [rcx], 'knil'
    je void_yes
    cmp DWORD PTR [rcx], 'atem'
    je void_yes
    cmp DWORD PTR [rcx], 00726277h
    je void_yes
    xor eax, eax
    ret
void_len5:
    cmp DWORD PTR [rcx], 'ebme'
    jne void_check_input
    cmp BYTE PTR [rcx + 4], 'd'
    je void_yes
void_check_input:
    cmp DWORD PTR [rcx], 'upni'
    jne void_check_param
    cmp BYTE PTR [rcx + 4], 't'
    je void_yes
void_check_param:
    cmp DWORD PTR [rcx], 'arap'
    jne void_check_track
    cmp BYTE PTR [rcx + 4], 'm'
    je void_yes
void_check_track:
    cmp DWORD PTR [rcx], 'cart'
    jne void_no
    cmp BYTE PTR [rcx + 4], 'k'
    je void_yes
    jmp void_no
void_len6:
    cmp DWORD PTR [rcx], 'ruos'
    jne void_no
    cmp WORD PTR [rcx + 4], 'ec'
    je void_yes
    jmp void_no
void_len7:
    cmp DWORD PTR [rcx], 06D6D6F63h
    je void_command_tail
    cmp DWORD PTR [rcx], 06779656Bh
    je void_keygen_tail
    jmp void_no
void_command_tail:
    cmp WORD PTR [rcx + 4], 'na'
    jne void_no
    cmp BYTE PTR [rcx + 6], 'd'
    je void_yes
    jmp void_no
void_keygen_tail:
    cmp BYTE PTR [rcx + 4], 'e'
    jne void_no
    cmp BYTE PTR [rcx + 5], 'n'
    je void_yes
    jmp void_no
void_yes:
    mov eax, 1
    ret
void_no:
    xor eax, eax
    ret
rbtl_asm_is_void_tag ENDP

PUBLIC rbtl_asm_bytes_eq
rbtl_asm_bytes_eq PROC
    xor rax, rax
bytes_eq_loop:
    cmp rax, r8
    jae bytes_eq_yes
    mov r9b, BYTE PTR [rcx + rax]
    cmp r9b, BYTE PTR [rdx + rax]
    jne bytes_eq_no
    inc rax
    jmp bytes_eq_loop
bytes_eq_yes:
    mov eax, 1
    ret
bytes_eq_no:
    xor eax, eax
    ret
rbtl_asm_bytes_eq ENDP

PUBLIC rbtl_asm_contains_ascii_whitespace_token
rbtl_asm_contains_ascii_whitespace_token PROC
    push r12
    test r9, r9
    je token_no
    xor rax, rax
token_skip:
    cmp rax, rdx
    jae token_no
    mov r10b, BYTE PTR [rcx + rax]
    cmp r10b, ' '
    je token_skip_one
    cmp r10b, 9
    jb token_start
    cmp r10b, 13
    jbe token_skip_one
    jmp token_start
token_skip_one:
    inc rax
    jmp token_skip
token_start:
    mov r11, rax
token_scan:
    cmp rax, rdx
    jae token_check
    mov r10b, BYTE PTR [rcx + rax]
    cmp r10b, ' '
    je token_check
    cmp r10b, 9
    jb token_scan_one
    cmp r10b, 13
    jbe token_check
token_scan_one:
    inc rax
    jmp token_scan
token_check:
    mov r10, rax
    sub r10, r11
    cmp r10, r9
    jne token_after
    xor r10, r10
token_cmp:
    cmp r10, r9
    jae token_yes
    lea r12, [r11 + r10]
    mov r12b, BYTE PTR [rcx + r12]
    cmp r12b, BYTE PTR [r8 + r10]
    jne token_after
    inc r10
    jmp token_cmp
token_after:
    cmp rax, rdx
    jae token_no
    inc rax
    jmp token_skip
token_yes:
    mov eax, 1
    pop r12
    ret
token_no:
    xor eax, eax
    pop r12
    ret
rbtl_asm_contains_ascii_whitespace_token ENDP

PUBLIC rbtl_asm_count_spaces
rbtl_asm_count_spaces PROC
    xor rax, rax
count_spaces_loop:
    cmp rax, rdx
    jae count_spaces_ret
    cmp BYTE PTR [rcx + rax], ' '
    jne count_spaces_ret
    inc rax
    jmp count_spaces_loop
count_spaces_ret:
    ret
rbtl_asm_count_spaces ENDP

PUBLIC rbtl_asm_starts_with
rbtl_asm_starts_with PROC
    cmp r9, rdx
    ja starts_no
    xor rax, rax
starts_loop:
    cmp rax, r9
    jae starts_yes
    mov r10b, BYTE PTR [rcx + rax]
    cmp r10b, BYTE PTR [r8 + rax]
    jne starts_no
    inc rax
    jmp starts_loop
starts_yes:
    mov eax, 1
    ret
starts_no:
    xor eax, eax
    ret
rbtl_asm_starts_with ENDP

PUBLIC rbtl_asm_ends_with
rbtl_asm_ends_with PROC
    cmp r9, rdx
    ja ends_no
    mov r10, rdx
    sub r10, r9
    xor rax, rax
ends_loop:
    cmp rax, r9
    jae ends_yes
    lea r11, [r10 + rax]
    mov r11b, BYTE PTR [rcx + r11]
    cmp r11b, BYTE PTR [r8 + rax]
    jne ends_no
    inc rax
    jmp ends_loop
ends_yes:
    mov eax, 1
    ret
ends_no:
    xor eax, eax
    ret
rbtl_asm_ends_with ENDP

PUBLIC rbtl_asm_contains_bytes
rbtl_asm_contains_bytes PROC
    test r9, r9
    je contains_yes
    cmp r9, rdx
    ja contains_no
    mov r10, rdx
    sub r10, r9
    xor rax, rax
contains_outer:
    cmp rax, r10
    ja contains_no
    xor r11, r11
contains_inner:
    cmp r11, r9
    jae contains_yes
    lea rdx, [rax + r11]
    mov dl, BYTE PTR [rcx + rdx]
    cmp dl, BYTE PTR [r8 + r11]
    jne contains_next
    inc r11
    jmp contains_inner
contains_next:
    inc rax
    jmp contains_outer
contains_yes:
    mov eax, 1
    ret
contains_no:
    xor eax, eax
    ret
rbtl_asm_contains_bytes ENDP

PUBLIC rbtl_asm_count_ident
rbtl_asm_count_ident PROC
    xor rax, rax
count_ident_loop:
    cmp rax, rdx
    jae count_ident_ret
    mov r10b, BYTE PTR [rcx + rax]
    cmp r10b, '0'
    jb count_ident_symbols
    cmp r10b, '9'
    jbe count_ident_next
    cmp r10b, 'A'
    jb count_ident_symbols
    cmp r10b, 'Z'
    jbe count_ident_next
    cmp r10b, 'a'
    jb count_ident_symbols
    cmp r10b, 'z'
    jbe count_ident_next
count_ident_symbols:
    cmp r10b, '-'
    je count_ident_next
    cmp r10b, '_'
    je count_ident_next
    cmp r10b, '/'
    je count_ident_next
    cmp r10b, ':'
    je count_ident_next
    cmp r10b, '+'
    je count_ident_next
    ret
count_ident_next:
    inc rax
    jmp count_ident_loop
count_ident_ret:
    ret
rbtl_asm_count_ident ENDP

PUBLIC rbtl_asm_is_quote
rbtl_asm_is_quote PROC
    xor eax, eax
    cmp cl, '"'
    je quote_yes
    cmp cl, 39
    je quote_yes
    ret
quote_yes:
    mov eax, 1
    ret
rbtl_asm_is_quote ENDP

PUBLIC rbtl_asm_find_comment_end
rbtl_asm_find_comment_end PROC
    xor rax, rax
comment_loop:
    lea r8, [rax + 2]
    cmp r8, rdx
    jae comment_none
    cmp BYTE PTR [rcx + rax], '-'
    jne comment_next
    cmp BYTE PTR [rcx + rax + 1], '-'
    jne comment_next
    cmp BYTE PTR [rcx + rax + 2], '>'
    jne comment_next
    add rax, 3
    ret
comment_next:
    inc rax
    jmp comment_loop
comment_none:
    lea rax, [rdx + 1]
    ret
rbtl_asm_find_comment_end ENDP

PUBLIC rbtl_asm_len_fits_u32
rbtl_asm_len_fits_u32 PROC
    xor eax, eax
    cmp rcx, 0FFFFFFFFh
    setbe al
    ret
rbtl_asm_len_fits_u32 ENDP

PUBLIC rbtl_asm_selector_token_kind
rbtl_asm_selector_token_kind PROC
    cmp cl, '#'
    je selector_token_id
    cmp cl, '.'
    je selector_token_class
    cmp cl, '*'
    je selector_token_all
    cmp cl, '['
    je selector_token_attr
    mov r10b, cl
    cmp r10b, '0'
    jb selector_token_symbols
    cmp r10b, '9'
    jbe selector_token_tag
    cmp r10b, 'A'
    jb selector_token_symbols
    cmp r10b, 'Z'
    jbe selector_token_tag
    cmp r10b, 'a'
    jb selector_token_symbols
    cmp r10b, 'z'
    jbe selector_token_tag
selector_token_symbols:
    cmp r10b, '-'
    je selector_token_tag
    cmp r10b, '_'
    je selector_token_tag
    cmp r10b, '/'
    je selector_token_tag
    cmp r10b, ':'
    je selector_token_tag
    cmp r10b, '+'
    je selector_token_tag
    xor eax, eax
    ret
selector_token_id:
    mov eax, 1
    ret
selector_token_class:
    mov eax, 2
    ret
selector_token_all:
    mov eax, 3
    ret
selector_token_attr:
    mov eax, 4
    ret
selector_token_tag:
    mov eax, 5
    ret
rbtl_asm_selector_token_kind ENDP

PUBLIC rbtl_asm_selector_attr_op_kind
rbtl_asm_selector_attr_op_kind PROC
    cmp cl, ']'
    je attr_close
    cmp cl, '='
    je attr_equal
    cmp cl, '~'
    je attr_tilde
    cmp cl, '^'
    je attr_caret
    cmp cl, '$'
    je attr_dollar
    cmp cl, '*'
    je attr_star
    xor eax, eax
    ret
attr_close:
    mov eax, 1
    ret
attr_equal:
    mov eax, 2
    ret
attr_tilde:
    mov eax, 3
    ret
attr_caret:
    mov eax, 4
    ret
attr_dollar:
    mov eax, 5
    ret
attr_star:
    mov eax, 6
    ret
rbtl_asm_selector_attr_op_kind ENDP

PUBLIC rbtl_asm_selector_combinator_kind
rbtl_asm_selector_combinator_kind PROC
    cmp cl, ','
    je comb_or
    cmp cl, '>'
    je comb_parent
    test edx, edx
    jne comb_desc
    mov eax, 4
    ret
comb_or:
    mov eax, 1
    ret
comb_parent:
    mov eax, 2
    ret
comb_desc:
    mov eax, 3
    ret
rbtl_asm_selector_combinator_kind ENDP

PUBLIC rbtl_asm_usize_is_zero
rbtl_asm_usize_is_zero PROC
    xor eax, eax
    test rcx, rcx
    sete al
    ret
rbtl_asm_usize_is_zero ENDP

PUBLIC rbtl_asm_usize_lt
rbtl_asm_usize_lt PROC
    xor eax, eax
    cmp rcx, rdx
    setb al
    ret
rbtl_asm_usize_lt ENDP

PUBLIC rbtl_asm_usize_ge
rbtl_asm_usize_ge PROC
    xor eax, eax
    cmp rcx, rdx
    setae al
    ret
rbtl_asm_usize_ge ENDP

PUBLIC rbtl_asm_usize_min
rbtl_asm_usize_min PROC
    mov rax, rcx
    cmp rcx, rdx
    cmova rax, rdx
    ret
rbtl_asm_usize_min ENDP

PUBLIC rbtl_asm_usize_add
rbtl_asm_usize_add PROC
    lea rax, [rcx + rdx]
    ret
rbtl_asm_usize_add ENDP

PUBLIC rbtl_asm_usize_sub_one
rbtl_asm_usize_sub_one PROC
    lea rax, [rcx - 1]
    ret
rbtl_asm_usize_sub_one ENDP

PUBLIC rbtl_asm_scan_html_event
rbtl_asm_scan_html_event PROC
    xor eax, eax
    mov r10, QWORD PTR [rsp + 40]
    cmp r8, rdx
    jae scan_event_ret
    mov QWORD PTR [r9], r8
    mov QWORD PTR [r10], 0
    cmp BYTE PTR [rcx + r8], '<'
    jne scan_event_text
    mov eax, 2
    ret
scan_event_text:
    mov r11, r8
scan_event_text_loop:
    cmp r11, rdx
    jae scan_event_text_emit
    cmp BYTE PTR [rcx + r11], '<'
    je scan_event_text_emit
    inc r11
    jmp scan_event_text_loop
scan_event_text_emit:
    mov rax, r11
    sub rax, r8
    mov QWORD PTR [r10], rax
    mov eax, 1
scan_event_ret:
    ret
rbtl_asm_scan_html_event ENDP

PUBLIC rbtl_asm_next_ascii_token
rbtl_asm_next_ascii_token PROC
    mov rax, r8
    mov r10, QWORD PTR [rsp + 40]
next_token_skip:
    cmp rax, rdx
    jae next_token_none
    mov r11b, BYTE PTR [rcx + rax]
    cmp r11b, ' '
    je next_token_skip_one
    cmp r11b, 9
    jb next_token_start
    cmp r11b, 13
    jbe next_token_skip_one
    jmp next_token_start
next_token_skip_one:
    inc rax
    jmp next_token_skip
next_token_start:
    mov r8, rax
next_token_scan:
    cmp rax, rdx
    jae next_token_emit
    mov r11b, BYTE PTR [rcx + rax]
    cmp r11b, ' '
    je next_token_emit
    cmp r11b, 9
    jb next_token_scan_one
    cmp r11b, 13
    jbe next_token_emit
next_token_scan_one:
    inc rax
    jmp next_token_scan
next_token_emit:
    mov QWORD PTR [r9], r8
    mov r11, rax
    sub r11, r8
    mov QWORD PTR [r10], r11
    ret
next_token_none:
    lea rax, [rdx + 1]
    ret
rbtl_asm_next_ascii_token ENDP

PUBLIC rbtl_asm_parse_attr
rbtl_asm_parse_attr PROC
    jmp rbtl_rust_msvc_parse_attr
rbtl_asm_parse_attr ENDP

PUBLIC rbtl_asm_parse_document
rbtl_asm_parse_document PROC
    jmp rbtl_rust_msvc_parse_document
rbtl_asm_parse_document ENDP

PUBLIC rbtl_asm_simple_selector_kind
rbtl_asm_simple_selector_kind PROC
    test rdx, rdx
    je simple_none
    mov QWORD PTR [r8], 0
    cmp rdx, 1
    jne simple_not_all
    cmp BYTE PTR [rcx], '*'
    jne simple_not_all
    mov eax, 1
    ret
simple_not_all:
    mov r9b, BYTE PTR [rcx]
    cmp r9b, '#'
    je simple_leading_id
    cmp r9b, '.'
    je simple_leading_class
    xor rax, rax
simple_tag_scan:
    cmp rax, rdx
    jae simple_tag_only
    mov r10b, BYTE PTR [rcx + rax]
    cmp r10b, '0'
    jb simple_tag_symbols
    cmp r10b, '9'
    jbe simple_tag_next
    cmp r10b, 'A'
    jb simple_tag_symbols
    cmp r10b, 'Z'
    jbe simple_tag_next
    cmp r10b, 'a'
    jb simple_tag_symbols
    cmp r10b, 'z'
    jbe simple_tag_next
simple_tag_symbols:
    cmp r10b, '-'
    je simple_tag_next
    cmp r10b, '_'
    je simple_tag_next
    cmp r10b, '/'
    je simple_tag_next
    cmp r10b, ':'
    je simple_tag_next
    cmp r10b, '+'
    je simple_tag_next
    jmp simple_tag_done
simple_tag_next:
    inc rax
    jmp simple_tag_scan
simple_tag_only:
    test rax, rax
    je simple_none
    mov QWORD PTR [r8], rax
    mov eax, 2
    ret
simple_tag_done:
    test rax, rax
    je simple_none
    mov r11, rax
    inc rax
    cmp rax, rdx
    jae simple_none
    mov r9b, BYTE PTR [rcx + r11]
    cmp r9b, '#'
    je simple_tag_id_rest
    cmp r9b, '.'
    je simple_tag_class_rest
    jmp simple_none
simple_leading_id:
    mov rax, 1
    mov r11d, 3
    jmp simple_rest
simple_leading_class:
    mov rax, 1
    mov r11d, 4
    jmp simple_rest
simple_tag_id_rest:
    mov QWORD PTR [r8], r11
    mov r11d, 5
    jmp simple_rest
simple_tag_class_rest:
    mov QWORD PTR [r8], r11
    mov r11d, 6
simple_rest:
    cmp rax, rdx
    jae simple_none
simple_rest_loop:
    cmp rax, rdx
    jae simple_emit_rest
    mov r10b, BYTE PTR [rcx + rax]
    cmp r10b, '0'
    jb simple_rest_symbols
    cmp r10b, '9'
    jbe simple_rest_next
    cmp r10b, 'A'
    jb simple_rest_symbols
    cmp r10b, 'Z'
    jbe simple_rest_next
    cmp r10b, 'a'
    jb simple_rest_symbols
    cmp r10b, 'z'
    jbe simple_rest_next
simple_rest_symbols:
    cmp r10b, '-'
    je simple_rest_next
    cmp r10b, '_'
    je simple_rest_next
    cmp r10b, '/'
    je simple_rest_next
    cmp r10b, ':'
    je simple_rest_next
    cmp r10b, '+'
    je simple_rest_next
    jmp simple_none
simple_rest_next:
    inc rax
    jmp simple_rest_loop
simple_emit_rest:
    mov eax, r11d
    ret
simple_none:
    xor eax, eax
    ret
rbtl_asm_simple_selector_kind ENDP

END
