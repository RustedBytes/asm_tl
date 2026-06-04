.intel_syntax noprefix

.text

.globl rbtl_asm_find
.type rbtl_asm_find, @function
rbtl_asm_find:
    xor rax, rax
.Lfind_loop:
    cmp rax, rsi
    jae .Lfind_none
    cmp byte ptr [rdi + rax], dl
    je .Lfind_ret
    inc rax
    jmp .Lfind_loop
.Lfind_none:
    mov rax, rsi
.Lfind_ret:
    ret
.size rbtl_asm_find, .-rbtl_asm_find

.globl rbtl_asm_find3
.type rbtl_asm_find3, @function
rbtl_asm_find3:
    xor rax, rax
.Lfind3_loop:
    cmp rax, rsi
    jae .Lfind3_none
    mov r9b, byte ptr [rdi + rax]
    cmp r9b, dl
    je .Lfind3_ret
    cmp r9b, cl
    je .Lfind3_ret
    cmp r9b, r8b
    je .Lfind3_ret
    inc rax
    jmp .Lfind3_loop
.Lfind3_none:
    mov rax, rsi
.Lfind3_ret:
    ret
.size rbtl_asm_find3, .-rbtl_asm_find3

.globl rbtl_asm_search_non_ident
.type rbtl_asm_search_non_ident, @function
rbtl_asm_search_non_ident:
    xor rax, rax
.Lident_loop:
    cmp rax, rsi
    jae .Lident_none
    mov dl, byte ptr [rdi + rax]

    cmp dl, '0'
    jb .Lident_symbols
    cmp dl, '9'
    jbe .Lident_next

    cmp dl, 'A'
    jb .Lident_symbols
    cmp dl, 'Z'
    jbe .Lident_next

    cmp dl, 'a'
    jb .Lident_symbols
    cmp dl, 'z'
    jbe .Lident_next

.Lident_symbols:
    cmp dl, '-'
    je .Lident_next
    cmp dl, '_'
    je .Lident_next
    cmp dl, '/'
    je .Lident_next
    cmp dl, ':'
    je .Lident_next
    cmp dl, '+'
    je .Lident_next
    ret

.Lident_next:
    inc rax
    jmp .Lident_loop
.Lident_none:
    mov rax, rsi
    ret
.size rbtl_asm_search_non_ident, .-rbtl_asm_search_non_ident

.globl rbtl_asm_validate_subset
.type rbtl_asm_validate_subset, @function
rbtl_asm_validate_subset:
    xor rax, rax
.Lvalidate_loop:
    cmp rax, rsi
    jae .Lvalidate_ok
    cmp byte ptr [rdi + rax], '<'
    jne .Lvalidate_next
    lea rdx, [rax + 1]
    cmp rdx, rsi
    jae .Lvalidate_next
    cmp byte ptr [rdi + rdx], '!'
    je .Lvalidate_bang
.Lvalidate_next:
    inc rax
    jmp .Lvalidate_loop
.Lvalidate_bang:
    lea rdx, [rax + 2]
    cmp rdx, rsi
    jae .Lvalidate_unsupported

    # Allow comments: <!-- ... -->
    lea r8, [rax + 3]
    cmp r8, rsi
    jae .Lvalidate_doctype
    cmp byte ptr [rdi + rdx], '-'
    jne .Lvalidate_doctype
    cmp byte ptr [rdi + rdx + 1], '-'
    je .Lvalidate_next

.Lvalidate_doctype:
    # Allow <!doctype ...> case-insensitively.
    lea r8, [rax + 9]
    cmp r8, rsi
    ja .Lvalidate_unsupported

    mov r9b, byte ptr [rdi + rdx]
    or r9b, 32
    cmp r9b, 'd'
    jne .Lvalidate_unsupported
    mov r9b, byte ptr [rdi + rdx + 1]
    or r9b, 32
    cmp r9b, 'o'
    jne .Lvalidate_unsupported
    mov r9b, byte ptr [rdi + rdx + 2]
    or r9b, 32
    cmp r9b, 'c'
    jne .Lvalidate_unsupported
    mov r9b, byte ptr [rdi + rdx + 3]
    or r9b, 32
    cmp r9b, 't'
    jne .Lvalidate_unsupported
    mov r9b, byte ptr [rdi + rdx + 4]
    or r9b, 32
    cmp r9b, 'y'
    jne .Lvalidate_unsupported
    mov r9b, byte ptr [rdi + rdx + 5]
    or r9b, 32
    cmp r9b, 'p'
    jne .Lvalidate_unsupported
    mov r9b, byte ptr [rdi + rdx + 6]
    or r9b, 32
    cmp r9b, 'e'
    jne .Lvalidate_unsupported
    jmp .Lvalidate_next
.Lvalidate_unsupported:
    mov eax, 1
    ret
.Lvalidate_ok:
    xor eax, eax
    ret
.size rbtl_asm_validate_subset, .-rbtl_asm_validate_subset

.globl rbtl_asm_selector_kind
.type rbtl_asm_selector_kind, @function
rbtl_asm_selector_kind:
    test rsi, rsi
    je .Lselector_none
    xor rax, rax
    xor r8d, r8d
.Lselector_skip_leading:
    cmp rax, rsi
    jae .Lselector_none
    cmp byte ptr [rdi + rax], ' '
    jne .Lselector_loop
    inc rax
    jmp .Lselector_skip_leading
.Lselector_loop:
    cmp rax, rsi
    jae .Lselector_done
    mov dl, byte ptr [rdi + rax]
    cmp dl, '#'
    je .Lselector_hash
    cmp dl, '.'
    je .Lselector_dot
    cmp dl, ' '
    je .Lselector_none
    cmp dl, '>'
    je .Lselector_none
    cmp dl, ','
    je .Lselector_none
    inc rax
    jmp .Lselector_loop
.Lselector_hash:
    or r8d, 1
    inc rax
    jmp .Lselector_loop
.Lselector_dot:
    or r8d, 2
    inc rax
    jmp .Lselector_loop
.Lselector_done:
    mov eax, r8d
    inc eax
    ret
.Lselector_none:
    xor eax, eax
    ret
.size rbtl_asm_selector_kind, .-rbtl_asm_selector_kind

.globl rbtl_asm_matches_case_insensitive
.type rbtl_asm_matches_case_insensitive, @function
rbtl_asm_matches_case_insensitive:
    xor rax, rax
.Lcase_loop:
    cmp rax, rdx
    jae .Lcase_yes
    mov r8b, byte ptr [rdi + rax]
    cmp r8b, 'A'
    jb .Lcase_compare
    cmp r8b, 'Z'
    ja .Lcase_compare
    add r8b, 32
.Lcase_compare:
    cmp r8b, byte ptr [rsi + rax]
    jne .Lcase_no
    inc rax
    jmp .Lcase_loop
.Lcase_yes:
    mov eax, 1
    ret
.Lcase_no:
    xor eax, eax
    ret
.size rbtl_asm_matches_case_insensitive, .-rbtl_asm_matches_case_insensitive

.globl rbtl_asm_is_closing
.type rbtl_asm_is_closing, @function
rbtl_asm_is_closing:
    xor eax, eax
    cmp dil, '/'
    je .Lis_closing_yes
    cmp dil, '>'
    je .Lis_closing_yes
    ret
.Lis_closing_yes:
    mov eax, 1
    ret
.size rbtl_asm_is_closing, .-rbtl_asm_is_closing

.globl rbtl_asm_count_while2
.type rbtl_asm_count_while2, @function
rbtl_asm_count_while2:
    xor rax, rax
.Lcount_while2_loop:
    cmp rax, rsi
    jae .Lcount_while2_ret
    mov r9b, byte ptr [rdi + rax]
    cmp r9b, dl
    je .Lcount_while2_next
    cmp r9b, cl
    je .Lcount_while2_next
    ret
.Lcount_while2_next:
    inc rax
    jmp .Lcount_while2_loop
.Lcount_while2_ret:
    ret
.size rbtl_asm_count_while2, .-rbtl_asm_count_while2

.globl rbtl_asm_bytes_eq
.type rbtl_asm_bytes_eq, @function
rbtl_asm_bytes_eq:
    xor rax, rax
.Lbytes_eq_loop:
    cmp rax, rdx
    jae .Lbytes_eq_yes
    mov r8b, byte ptr [rdi + rax]
    cmp r8b, byte ptr [rsi + rax]
    jne .Lbytes_eq_no
    inc rax
    jmp .Lbytes_eq_loop
.Lbytes_eq_yes:
    mov eax, 1
    ret
.Lbytes_eq_no:
    xor eax, eax
    ret
.size rbtl_asm_bytes_eq, .-rbtl_asm_bytes_eq

.globl rbtl_asm_is_void_tag
.type rbtl_asm_is_void_tag, @function
rbtl_asm_is_void_tag:
    cmp rsi, 2
    je .Lvoid_len2
    cmp rsi, 3
    je .Lvoid_len3
    cmp rsi, 4
    je .Lvoid_len4
    cmp rsi, 5
    je .Lvoid_len5
    cmp rsi, 6
    je .Lvoid_len6
    cmp rsi, 7
    je .Lvoid_len7
    xor eax, eax
    ret
.Lvoid_len2:
    cmp byte ptr [rdi], 'b'
    je .Lvoid_br
    cmp byte ptr [rdi], 'h'
    je .Lvoid_hr
    xor eax, eax
    ret
.Lvoid_br:
    cmp byte ptr [rdi + 1], 'r'
    sete al
    movzx eax, al
    ret
.Lvoid_hr:
    cmp byte ptr [rdi + 1], 'r'
    sete al
    movzx eax, al
    ret
.Lvoid_len3:
    cmp byte ptr [rdi], 'c'
    je .Lvoid_col
    cmp byte ptr [rdi], 'i'
    je .Lvoid_img
    xor eax, eax
    ret
.Lvoid_col:
    cmp byte ptr [rdi + 1], 'o'
    jne .Lvoid_no
    cmp byte ptr [rdi + 2], 'l'
    sete al
    movzx eax, al
    ret
.Lvoid_img:
    cmp byte ptr [rdi + 1], 'm'
    jne .Lvoid_no
    cmp byte ptr [rdi + 2], 'g'
    sete al
    movzx eax, al
    ret
.Lvoid_len4:
    cmp byte ptr [rdi], 'a'
    je .Lvoid_area
    cmp byte ptr [rdi], 'b'
    je .Lvoid_base
    cmp byte ptr [rdi], 'l'
    je .Lvoid_link
    cmp byte ptr [rdi], 'm'
    je .Lvoid_meta
    cmp byte ptr [rdi], 'w'
    je .Lvoid_wbr
    xor eax, eax
    ret
.Lvoid_area:
    cmp byte ptr [rdi + 1], 'r'
    jne .Lvoid_no
    cmp byte ptr [rdi + 2], 'e'
    jne .Lvoid_no
    cmp byte ptr [rdi + 3], 'a'
    sete al
    movzx eax, al
    ret
.Lvoid_base:
    cmp byte ptr [rdi + 1], 'a'
    jne .Lvoid_no
    cmp byte ptr [rdi + 2], 's'
    jne .Lvoid_no
    cmp byte ptr [rdi + 3], 'e'
    sete al
    movzx eax, al
    ret
.Lvoid_link:
    cmp byte ptr [rdi + 1], 'i'
    jne .Lvoid_no
    cmp byte ptr [rdi + 2], 'n'
    jne .Lvoid_no
    cmp byte ptr [rdi + 3], 'k'
    sete al
    movzx eax, al
    ret
.Lvoid_meta:
    cmp byte ptr [rdi + 1], 'e'
    jne .Lvoid_no
    cmp byte ptr [rdi + 2], 't'
    jne .Lvoid_no
    cmp byte ptr [rdi + 3], 'a'
    sete al
    movzx eax, al
    ret
.Lvoid_wbr:
    cmp byte ptr [rdi + 1], 'b'
    jne .Lvoid_no
    cmp byte ptr [rdi + 2], 'r'
    sete al
    movzx eax, al
    ret
.Lvoid_len5:
    cmp byte ptr [rdi], 'e'
    je .Lvoid_embed
    cmp byte ptr [rdi], 'i'
    je .Lvoid_input
    cmp byte ptr [rdi], 'p'
    je .Lvoid_param
    cmp byte ptr [rdi], 't'
    je .Lvoid_track
    xor eax, eax
    ret
.Lvoid_embed:
    cmp byte ptr [rdi + 1], 'm'
    jne .Lvoid_no
    cmp byte ptr [rdi + 2], 'b'
    jne .Lvoid_no
    cmp byte ptr [rdi + 3], 'e'
    jne .Lvoid_no
    cmp byte ptr [rdi + 4], 'd'
    sete al
    movzx eax, al
    ret
.Lvoid_input:
    cmp byte ptr [rdi + 1], 'n'
    jne .Lvoid_no
    cmp byte ptr [rdi + 2], 'p'
    jne .Lvoid_no
    cmp byte ptr [rdi + 3], 'u'
    jne .Lvoid_no
    cmp byte ptr [rdi + 4], 't'
    sete al
    movzx eax, al
    ret
.Lvoid_param:
    cmp byte ptr [rdi + 1], 'a'
    jne .Lvoid_no
    cmp byte ptr [rdi + 2], 'r'
    jne .Lvoid_no
    cmp byte ptr [rdi + 3], 'a'
    jne .Lvoid_no
    cmp byte ptr [rdi + 4], 'm'
    sete al
    movzx eax, al
    ret
.Lvoid_track:
    cmp byte ptr [rdi + 1], 'r'
    jne .Lvoid_no
    cmp byte ptr [rdi + 2], 'a'
    jne .Lvoid_no
    cmp byte ptr [rdi + 3], 'c'
    jne .Lvoid_no
    cmp byte ptr [rdi + 4], 'k'
    sete al
    movzx eax, al
    ret
.Lvoid_len6:
    cmp byte ptr [rdi], 's'
    jne .Lvoid_no
    cmp byte ptr [rdi + 1], 'o'
    jne .Lvoid_no
    cmp byte ptr [rdi + 2], 'u'
    jne .Lvoid_no
    cmp byte ptr [rdi + 3], 'r'
    jne .Lvoid_no
    cmp byte ptr [rdi + 4], 'c'
    jne .Lvoid_no
    cmp byte ptr [rdi + 5], 'e'
    sete al
    movzx eax, al
    ret
.Lvoid_len7:
    cmp byte ptr [rdi], 'c'
    je .Lvoid_command
    cmp byte ptr [rdi], 'k'
    jne .Lvoid_no
    cmp byte ptr [rdi + 1], 'e'
    jne .Lvoid_no
    cmp byte ptr [rdi + 2], 'y'
    jne .Lvoid_no
    cmp byte ptr [rdi + 3], 'g'
    jne .Lvoid_no
    cmp byte ptr [rdi + 4], 'e'
    jne .Lvoid_no
    cmp byte ptr [rdi + 5], 'n'
    sete al
    movzx eax, al
    ret
.Lvoid_command:
    cmp byte ptr [rdi + 1], 'o'
    jne .Lvoid_no
    cmp byte ptr [rdi + 2], 'm'
    jne .Lvoid_no
    cmp byte ptr [rdi + 3], 'm'
    jne .Lvoid_no
    cmp byte ptr [rdi + 4], 'a'
    jne .Lvoid_no
    cmp byte ptr [rdi + 5], 'n'
    jne .Lvoid_no
    cmp byte ptr [rdi + 6], 'd'
    sete al
    movzx eax, al
    ret
.Lvoid_no:
    xor eax, eax
    ret
.size rbtl_asm_is_void_tag, .-rbtl_asm_is_void_tag

.globl rbtl_asm_contains_ascii_whitespace_token
.type rbtl_asm_contains_ascii_whitespace_token, @function
rbtl_asm_contains_ascii_whitespace_token:
    test rcx, rcx
    je .Ltoken_no
    xor rax, rax
.Ltoken_skip:
    cmp rax, rsi
    jae .Ltoken_no
    mov r9b, byte ptr [rdi + rax]
    call .Ltoken_is_space
    test r10b, r10b
    je .Ltoken_start
    inc rax
    jmp .Ltoken_skip
.Ltoken_start:
    mov r11, rax
.Ltoken_scan:
    cmp rax, rsi
    jae .Ltoken_check
    mov r9b, byte ptr [rdi + rax]
    call .Ltoken_is_space
    test r10b, r10b
    jne .Ltoken_check
    inc rax
    jmp .Ltoken_scan
.Ltoken_check:
    mov r9, rax
    sub r9, r11
    cmp r9, rcx
    jne .Ltoken_after
    xor r9, r9
.Ltoken_cmp:
    cmp r9, rcx
    jae .Ltoken_yes
    lea r10, [r11 + r9]
    mov r10b, byte ptr [rdi + r10]
    cmp r10b, byte ptr [rdx + r9]
    jne .Ltoken_after
    inc r9
    jmp .Ltoken_cmp
.Ltoken_after:
    cmp rax, rsi
    jae .Ltoken_no
    inc rax
    jmp .Ltoken_skip
.Ltoken_yes:
    mov eax, 1
    ret
.Ltoken_no:
    xor eax, eax
    ret
.Ltoken_is_space:
    xor r10d, r10d
    cmp r9b, ' '
    je .Ltoken_space_yes
    cmp r9b, 9
    jb .Ltoken_space_ret
    cmp r9b, 13
    ja .Ltoken_space_ret
.Ltoken_space_yes:
    mov r10b, 1
.Ltoken_space_ret:
    ret
.size rbtl_asm_contains_ascii_whitespace_token, .-rbtl_asm_contains_ascii_whitespace_token

.globl rbtl_asm_count_spaces
.type rbtl_asm_count_spaces, @function
rbtl_asm_count_spaces:
    xor rax, rax
.Lcount_spaces_loop:
    cmp rax, rsi
    jae .Lcount_spaces_ret
    cmp byte ptr [rdi + rax], ' '
    jne .Lcount_spaces_ret
    inc rax
    jmp .Lcount_spaces_loop
.Lcount_spaces_ret:
    ret
.size rbtl_asm_count_spaces, .-rbtl_asm_count_spaces

.globl rbtl_asm_starts_with
.type rbtl_asm_starts_with, @function
rbtl_asm_starts_with:
    cmp rcx, rsi
    ja .Lstarts_no
    xor rax, rax
.Lstarts_loop:
    cmp rax, rcx
    jae .Lstarts_yes
    mov r8b, byte ptr [rdi + rax]
    cmp r8b, byte ptr [rdx + rax]
    jne .Lstarts_no
    inc rax
    jmp .Lstarts_loop
.Lstarts_yes:
    mov eax, 1
    ret
.Lstarts_no:
    xor eax, eax
    ret
.size rbtl_asm_starts_with, .-rbtl_asm_starts_with

.globl rbtl_asm_ends_with
.type rbtl_asm_ends_with, @function
rbtl_asm_ends_with:
    cmp rcx, rsi
    ja .Lends_no
    mov r8, rsi
    sub r8, rcx
    xor rax, rax
.Lends_loop:
    cmp rax, rcx
    jae .Lends_yes
    lea r9, [r8 + rax]
    mov r10b, byte ptr [rdi + r9]
    cmp r10b, byte ptr [rdx + rax]
    jne .Lends_no
    inc rax
    jmp .Lends_loop
.Lends_yes:
    mov eax, 1
    ret
.Lends_no:
    xor eax, eax
    ret
.size rbtl_asm_ends_with, .-rbtl_asm_ends_with

.globl rbtl_asm_contains_bytes
.type rbtl_asm_contains_bytes, @function
rbtl_asm_contains_bytes:
    test rcx, rcx
    je .Lcontains_yes
    cmp rcx, rsi
    ja .Lcontains_no
    mov r8, rsi
    sub r8, rcx
    xor rax, rax
.Lcontains_outer:
    cmp rax, r8
    ja .Lcontains_no
    xor r9, r9
.Lcontains_inner:
    cmp r9, rcx
    jae .Lcontains_yes
    lea r10, [rax + r9]
    mov r11b, byte ptr [rdi + r10]
    cmp r11b, byte ptr [rdx + r9]
    jne .Lcontains_next
    inc r9
    jmp .Lcontains_inner
.Lcontains_next:
    inc rax
    jmp .Lcontains_outer
.Lcontains_yes:
    mov eax, 1
    ret
.Lcontains_no:
    xor eax, eax
    ret
.size rbtl_asm_contains_bytes, .-rbtl_asm_contains_bytes

.globl rbtl_asm_is_ident
.type rbtl_asm_is_ident, @function
rbtl_asm_is_ident:
    mov dl, dil
    cmp dl, '0'
    jb .Lis_ident_symbols
    cmp dl, '9'
    jbe .Lis_ident_yes
    cmp dl, 'A'
    jb .Lis_ident_symbols
    cmp dl, 'Z'
    jbe .Lis_ident_yes
    cmp dl, 'a'
    jb .Lis_ident_symbols
    cmp dl, 'z'
    jbe .Lis_ident_yes
.Lis_ident_symbols:
    cmp dl, '-'
    je .Lis_ident_yes
    cmp dl, '_'
    je .Lis_ident_yes
    cmp dl, '/'
    je .Lis_ident_yes
    cmp dl, ':'
    je .Lis_ident_yes
    cmp dl, '+'
    je .Lis_ident_yes
    xor eax, eax
    ret
.Lis_ident_yes:
    mov eax, 1
    ret
.size rbtl_asm_is_ident, .-rbtl_asm_is_ident

.globl rbtl_asm_count_ident
.type rbtl_asm_count_ident, @function
rbtl_asm_count_ident:
    xor rax, rax
.Lcount_ident_loop:
    cmp rax, rsi
    jae .Lcount_ident_ret
    mov dl, byte ptr [rdi + rax]
    cmp dl, '0'
    jb .Lcount_ident_symbols
    cmp dl, '9'
    jbe .Lcount_ident_next
    cmp dl, 'A'
    jb .Lcount_ident_symbols
    cmp dl, 'Z'
    jbe .Lcount_ident_next
    cmp dl, 'a'
    jb .Lcount_ident_symbols
    cmp dl, 'z'
    jbe .Lcount_ident_next
.Lcount_ident_symbols:
    cmp dl, '-'
    je .Lcount_ident_next
    cmp dl, '_'
    je .Lcount_ident_next
    cmp dl, '/'
    je .Lcount_ident_next
    cmp dl, ':'
    je .Lcount_ident_next
    cmp dl, '+'
    je .Lcount_ident_next
    ret
.Lcount_ident_next:
    inc rax
    jmp .Lcount_ident_loop
.Lcount_ident_ret:
    ret
.size rbtl_asm_count_ident, .-rbtl_asm_count_ident

.globl rbtl_asm_is_quote
.type rbtl_asm_is_quote, @function
rbtl_asm_is_quote:
    xor eax, eax
    cmp dil, '"'
    je .Lis_quote_yes
    cmp dil, 39
    je .Lis_quote_yes
    ret
.Lis_quote_yes:
    mov eax, 1
    ret
.size rbtl_asm_is_quote, .-rbtl_asm_is_quote

.globl rbtl_asm_find_comment_end
.type rbtl_asm_find_comment_end, @function
rbtl_asm_find_comment_end:
    cmp rsi, 3
    jb .Lcomment_none
    xor rax, rax
    mov r8, rsi
    sub r8, 3
.Lcomment_loop:
    cmp rax, r8
    ja .Lcomment_none
    cmp byte ptr [rdi + rax], '-'
    jne .Lcomment_next
    cmp byte ptr [rdi + rax + 1], '-'
    jne .Lcomment_next
    cmp byte ptr [rdi + rax + 2], '>'
    jne .Lcomment_next
    add rax, 3
    ret
.Lcomment_next:
    inc rax
    jmp .Lcomment_loop
.Lcomment_none:
    mov rax, rsi
    inc rax
    ret
.size rbtl_asm_find_comment_end, .-rbtl_asm_find_comment_end

.section .note.GNU-stack,"",@progbits
