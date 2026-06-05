.intel_syntax noprefix

.text

.globl rbtl_asm_find
.type rbtl_asm_find, @function
rbtl_asm_find:
    xor rax, rax
    movd xmm1, edx
    vpbroadcastb ymm1, xmm1
.Lfind_vector_loop:
    lea r8, [rax + 32]
    cmp r8, rsi
    ja .Lfind_loop
    vmovdqu ymm0, ymmword ptr [rdi + rax]
    vpcmpeqb ymm0, ymm0, ymm1
    vpmovmskb r8d, ymm0
    test r8d, r8d
    jne .Lfind_vector_hit
    add rax, 32
    jmp .Lfind_vector_loop
.Lfind_vector_hit:
    bsf r8d, r8d
    add rax, r8
    vzeroupper
    ret
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
    vzeroupper
    ret
.size rbtl_asm_find, .-rbtl_asm_find

.globl rbtl_asm_find3
.type rbtl_asm_find3, @function
rbtl_asm_find3:
    xor rax, rax
    movd xmm1, edx
    movd xmm2, ecx
    movd xmm3, r8d
    vpbroadcastb ymm1, xmm1
    vpbroadcastb ymm2, xmm2
    vpbroadcastb ymm3, xmm3
.Lfind3_vector_loop:
    lea r9, [rax + 32]
    cmp r9, rsi
    ja .Lfind3_loop
    vmovdqu ymm0, ymmword ptr [rdi + rax]
    vpcmpeqb ymm4, ymm0, ymm1
    vpcmpeqb ymm5, ymm0, ymm2
    vpcmpeqb ymm0, ymm0, ymm3
    vpor ymm4, ymm4, ymm5
    vpor ymm0, ymm0, ymm4
    vpmovmskb r9d, ymm0
    test r9d, r9d
    jne .Lfind3_vector_hit
    add rax, 32
    jmp .Lfind3_vector_loop
.Lfind3_vector_hit:
    bsf r9d, r9d
    add rax, r9
    vzeroupper
    ret
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
    vzeroupper
    ret
.size rbtl_asm_find3, .-rbtl_asm_find3

.globl rbtl_asm_search_non_ident
.type rbtl_asm_search_non_ident, @function
rbtl_asm_search_non_ident:
    xor rax, rax
    mov edx, 0x2f2f2f2f
    movd xmm2, edx
    pshufd xmm2, xmm2, 0
    mov edx, 0x3a3a3a3a
    movd xmm3, edx
    pshufd xmm3, xmm3, 0
    mov edx, 0x40404040
    movd xmm4, edx
    pshufd xmm4, xmm4, 0
    mov edx, 0x5b5b5b5b
    movd xmm5, edx
    pshufd xmm5, xmm5, 0
    mov edx, 0x60606060
    movd xmm6, edx
    pshufd xmm6, xmm6, 0
    mov edx, 0x7b7b7b7b
    movd xmm7, edx
    pshufd xmm7, xmm7, 0
    mov edx, 0x2d2d2d2d
    movd xmm8, edx
    pshufd xmm8, xmm8, 0
    mov edx, 0x5f5f5f5f
    movd xmm9, edx
    pshufd xmm9, xmm9, 0
    mov edx, 0x2b2b2b2b
    movd xmm10, edx
    pshufd xmm10, xmm10, 0
.Lident_vector_loop:
    lea r8, [rax + 16]
    cmp r8, rsi
    ja .Lident_loop
    movdqu xmm1, xmmword ptr [rdi + rax]

    movdqa xmm13, xmm1
    pcmpgtb xmm13, xmm2
    movdqa xmm14, xmm3
    pcmpgtb xmm14, xmm1
    pand xmm13, xmm14

    movdqa xmm14, xmm1
    pcmpgtb xmm14, xmm4
    movdqa xmm15, xmm5
    pcmpgtb xmm15, xmm1
    pand xmm14, xmm15
    por xmm13, xmm14

    movdqa xmm14, xmm1
    pcmpgtb xmm14, xmm6
    movdqa xmm15, xmm7
    pcmpgtb xmm15, xmm1
    pand xmm14, xmm15
    por xmm13, xmm14

    movdqa xmm14, xmm1
    pcmpeqb xmm14, xmm8
    por xmm13, xmm14
    movdqa xmm14, xmm1
    pcmpeqb xmm14, xmm9
    por xmm13, xmm14
    movdqa xmm14, xmm1
    pcmpeqb xmm14, xmm2
    por xmm13, xmm14
    movdqa xmm14, xmm1
    pcmpeqb xmm14, xmm3
    por xmm13, xmm14
    movdqa xmm14, xmm1
    pcmpeqb xmm14, xmm10
    por xmm13, xmm14

    pmovmskb r8d, xmm13
    xor r8d, 0xffff
    and r8d, 0xffff
    jne .Lident_vector_hit
    add rax, 16
    jmp .Lident_vector_loop
.Lident_vector_hit:
    bsf r8d, r8d
    add rax, r8
    ret
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
    mov edx, 0x3c3c3c3c
    movd xmm1, edx
    pshufd xmm1, xmm1, 0
.Lvalidate_vector_loop:
    lea rdx, [rax + 16]
    cmp rdx, rsi
    ja .Lvalidate_loop
    movdqu xmm0, xmmword ptr [rdi + rax]
    pcmpeqb xmm0, xmm1
    pmovmskb edx, xmm0
    test edx, edx
    jne .Lvalidate_vector_hit
    add rax, 16
    jmp .Lvalidate_vector_loop
.Lvalidate_vector_hit:
    bsf edx, edx
    add rax, rdx
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
    jmp .Lvalidate_vector_loop
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
    movd xmm1, edx
    movd xmm2, ecx
    vpbroadcastb ymm1, xmm1
    vpbroadcastb ymm2, xmm2
.Lcount_while2_vector_loop:
    lea r8, [rax + 32]
    cmp r8, rsi
    ja .Lcount_while2_loop
    vmovdqu ymm0, ymmword ptr [rdi + rax]
    vpcmpeqb ymm3, ymm0, ymm1
    vpcmpeqb ymm0, ymm0, ymm2
    vpor ymm0, ymm0, ymm3
    vpmovmskb r8d, ymm0
    cmp r8d, -1
    jne .Lcount_while2_vector_hit
    add rax, 32
    jmp .Lcount_while2_vector_loop
.Lcount_while2_vector_hit:
    not r8d
    bsf r8d, r8d
    add rax, r8
    vzeroupper
    ret
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
    vzeroupper
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

.globl rbtl_asm_parser_flags_valid
.type rbtl_asm_parser_flags_valid, @function
rbtl_asm_parser_flags_valid:
    xor eax, eax
    cmp dil, 3
    seta al
    xor eax, 1
    ret
.size rbtl_asm_parser_flags_valid, .-rbtl_asm_parser_flags_valid

.globl rbtl_asm_parser_set_flag
.type rbtl_asm_parser_set_flag, @function
rbtl_asm_parser_set_flag:
    mov eax, edi
    or al, sil
    ret
.size rbtl_asm_parser_set_flag, .-rbtl_asm_parser_set_flag

.globl rbtl_asm_parser_is_tracking_ids
.type rbtl_asm_parser_is_tracking_ids, @function
rbtl_asm_parser_is_tracking_ids:
    xor eax, eax
    test dil, 1
    setne al
    ret
.size rbtl_asm_parser_is_tracking_ids, .-rbtl_asm_parser_is_tracking_ids

.globl rbtl_asm_parser_is_tracking_classes
.type rbtl_asm_parser_is_tracking_classes, @function
rbtl_asm_parser_is_tracking_classes:
    xor eax, eax
    test dil, 2
    setne al
    ret
.size rbtl_asm_parser_is_tracking_classes, .-rbtl_asm_parser_is_tracking_classes

.globl rbtl_asm_parser_is_tracking
.type rbtl_asm_parser_is_tracking, @function
rbtl_asm_parser_is_tracking:
    xor eax, eax
    test dil, dil
    setne al
    ret
.size rbtl_asm_parser_is_tracking, .-rbtl_asm_parser_is_tracking

.globl rbtl_asm_attr_key_kind
.type rbtl_asm_attr_key_kind, @function
rbtl_asm_attr_key_kind:
    cmp rsi, 2
    je .Lattr_key_len2
    cmp rsi, 5
    je .Lattr_key_len5
    xor eax, eax
    ret
.Lattr_key_len2:
    cmp byte ptr [rdi], 'i'
    jne .Lattr_key_other
    cmp byte ptr [rdi + 1], 'd'
    jne .Lattr_key_other
    mov eax, 1
    ret
.Lattr_key_len5:
    cmp byte ptr [rdi], 'c'
    jne .Lattr_key_other
    cmp byte ptr [rdi + 1], 'l'
    jne .Lattr_key_other
    cmp byte ptr [rdi + 2], 'a'
    jne .Lattr_key_other
    cmp byte ptr [rdi + 3], 's'
    jne .Lattr_key_other
    cmp byte ptr [rdi + 4], 's'
    jne .Lattr_key_other
    mov eax, 2
    ret
.Lattr_key_other:
    xor eax, eax
    ret
.size rbtl_asm_attr_key_kind, .-rbtl_asm_attr_key_kind

.globl rbtl_asm_len_fits_u32
.type rbtl_asm_len_fits_u32, @function
rbtl_asm_len_fits_u32:
    xor eax, eax
    mov rcx, 4294967295
    cmp rdi, rcx
    setbe al
    ret
.size rbtl_asm_len_fits_u32, .-rbtl_asm_len_fits_u32

.globl rbtl_asm_byte_at_eq
.type rbtl_asm_byte_at_eq, @function
rbtl_asm_byte_at_eq:
    xor eax, eax
    cmp rdx, rsi
    jae .Lbyte_at_eq_ret
    cmp byte ptr [rdi + rdx], cl
    sete al
.Lbyte_at_eq_ret:
    ret
.size rbtl_asm_byte_at_eq, .-rbtl_asm_byte_at_eq

.globl rbtl_asm_selector_token_kind
.type rbtl_asm_selector_token_kind, @function
rbtl_asm_selector_token_kind:
    cmp dil, '#'
    je .Lselector_token_id
    cmp dil, '.'
    je .Lselector_token_class
    cmp dil, '*'
    je .Lselector_token_all
    cmp dil, '['
    je .Lselector_token_attr
    call rbtl_asm_is_ident
    test eax, eax
    jne .Lselector_token_tag
    xor eax, eax
    ret
.Lselector_token_id:
    mov eax, 1
    ret
.Lselector_token_class:
    mov eax, 2
    ret
.Lselector_token_all:
    mov eax, 3
    ret
.Lselector_token_attr:
    mov eax, 4
    ret
.Lselector_token_tag:
    mov eax, 5
    ret
.size rbtl_asm_selector_token_kind, .-rbtl_asm_selector_token_kind

.globl rbtl_asm_selector_attr_op_kind
.type rbtl_asm_selector_attr_op_kind, @function
rbtl_asm_selector_attr_op_kind:
    cmp dil, ']'
    je .Lselector_attr_close
    cmp dil, '='
    je .Lselector_attr_equal
    cmp dil, '~'
    je .Lselector_attr_tilde
    cmp dil, '^'
    je .Lselector_attr_caret
    cmp dil, '$'
    je .Lselector_attr_dollar
    cmp dil, '*'
    je .Lselector_attr_star
    xor eax, eax
    ret
.Lselector_attr_close:
    mov eax, 1
    ret
.Lselector_attr_equal:
    mov eax, 2
    ret
.Lselector_attr_tilde:
    mov eax, 3
    ret
.Lselector_attr_caret:
    mov eax, 4
    ret
.Lselector_attr_dollar:
    mov eax, 5
    ret
.Lselector_attr_star:
    mov eax, 6
    ret
.size rbtl_asm_selector_attr_op_kind, .-rbtl_asm_selector_attr_op_kind

.globl rbtl_asm_selector_combinator_kind
.type rbtl_asm_selector_combinator_kind, @function
rbtl_asm_selector_combinator_kind:
    cmp dil, ','
    je .Lselector_comb_or
    cmp dil, '>'
    je .Lselector_comb_parent
    test esi, esi
    jne .Lselector_comb_descendant
    mov eax, 4
    ret
.Lselector_comb_or:
    mov eax, 1
    ret
.Lselector_comb_parent:
    mov eax, 2
    ret
.Lselector_comb_descendant:
    mov eax, 3
    ret
.size rbtl_asm_selector_combinator_kind, .-rbtl_asm_selector_combinator_kind

.globl rbtl_asm_usize_is_zero
.type rbtl_asm_usize_is_zero, @function
rbtl_asm_usize_is_zero:
    xor eax, eax
    test rdi, rdi
    sete al
    ret
.size rbtl_asm_usize_is_zero, .-rbtl_asm_usize_is_zero

.globl rbtl_asm_usize_lt
.type rbtl_asm_usize_lt, @function
rbtl_asm_usize_lt:
    xor eax, eax
    cmp rdi, rsi
    setb al
    ret
.size rbtl_asm_usize_lt, .-rbtl_asm_usize_lt

.globl rbtl_asm_usize_ge
.type rbtl_asm_usize_ge, @function
rbtl_asm_usize_ge:
    xor eax, eax
    cmp rdi, rsi
    setae al
    ret
.size rbtl_asm_usize_ge, .-rbtl_asm_usize_ge

.globl rbtl_asm_usize_min
.type rbtl_asm_usize_min, @function
rbtl_asm_usize_min:
    mov rax, rdi
    cmp rdi, rsi
    cmova rax, rsi
    ret
.size rbtl_asm_usize_min, .-rbtl_asm_usize_min

.globl rbtl_asm_usize_add
.type rbtl_asm_usize_add, @function
rbtl_asm_usize_add:
    lea rax, [rdi + rsi]
    ret
.size rbtl_asm_usize_add, .-rbtl_asm_usize_add

.globl rbtl_asm_usize_sub_one
.type rbtl_asm_usize_sub_one, @function
rbtl_asm_usize_sub_one:
    lea rax, [rdi - 1]
    ret
.size rbtl_asm_usize_sub_one, .-rbtl_asm_usize_sub_one

.globl rbtl_asm_html_event_kind
.type rbtl_asm_html_event_kind, @function
rbtl_asm_html_event_kind:
    xor eax, eax
    cmp rdx, rsi
    jae .Lhtml_event_ret
    cmp byte ptr [rdi + rdx], '<'
    jne .Lhtml_event_text
    inc rdx
.Lhtml_event_skip_ws:
    cmp rdx, rsi
    jae .Lhtml_event_start
    mov cl, byte ptr [rdi + rdx]
    cmp cl, ' '
    je .Lhtml_event_skip_one
    cmp cl, 10
    je .Lhtml_event_skip_one
    jmp .Lhtml_event_classify
.Lhtml_event_skip_one:
    inc rdx
    jmp .Lhtml_event_skip_ws
.Lhtml_event_classify:
    cmp cl, '/'
    je .Lhtml_event_end
    cmp cl, '!'
    je .Lhtml_event_bang
.Lhtml_event_start:
    mov eax, 2
    ret
.Lhtml_event_text:
    mov eax, 1
    ret
.Lhtml_event_end:
    mov eax, 3
    ret
.Lhtml_event_bang:
    mov eax, 4
.Lhtml_event_ret:
    ret
.size rbtl_asm_html_event_kind, .-rbtl_asm_html_event_kind

.globl rbtl_asm_scan_html_event
.type rbtl_asm_scan_html_event, @function
rbtl_asm_scan_html_event:
    xor eax, eax
    cmp rdx, rsi
    jae .Lscan_event_ret

    mov qword ptr [rcx], rdx
    mov qword ptr [r8], 0
    cmp byte ptr [rdi + rdx], '<'
    jne .Lscan_event_text

    mov r9, rdx
    inc r9
.Lscan_event_skip_ws:
    cmp r9, rsi
    jae .Lscan_event_start
    mov r10b, byte ptr [rdi + r9]
    cmp r10b, ' '
    je .Lscan_event_skip_one
    cmp r10b, 10
    je .Lscan_event_skip_one
    jmp .Lscan_event_classify
.Lscan_event_skip_one:
    inc r9
    jmp .Lscan_event_skip_ws
.Lscan_event_classify:
    cmp r10b, '/'
    je .Lscan_event_end
    cmp r10b, '!'
    je .Lscan_event_bang
.Lscan_event_start:
    mov eax, 2
    ret
.Lscan_event_end:
    mov eax, 3
    ret
.Lscan_event_bang:
    mov eax, 4
    ret

.Lscan_event_text:
    mov r9, rdx
    mov eax, '<'
    movd xmm1, eax
    vpbroadcastb ymm1, xmm1
.Lscan_event_text_vector_loop:
    lea r10, [r9 + 32]
    cmp r10, rsi
    ja .Lscan_event_text_loop
    vmovdqu ymm0, ymmword ptr [rdi + r9]
    vpcmpeqb ymm0, ymm0, ymm1
    vpmovmskb eax, ymm0
    test eax, eax
    jne .Lscan_event_text_vector_hit
    add r9, 32
    jmp .Lscan_event_text_vector_loop
.Lscan_event_text_vector_hit:
    bsf eax, eax
    add r9, rax
    jmp .Lscan_event_text_emit
.Lscan_event_text_loop:
    cmp r9, rsi
    jae .Lscan_event_text_emit
    cmp byte ptr [rdi + r9], '<'
    je .Lscan_event_text_emit
    inc r9
    jmp .Lscan_event_text_loop
.Lscan_event_text_emit:
    mov r10, r9
    sub r10, rdx
    mov qword ptr [r8], r10
    mov eax, 1
.Lscan_event_ret:
    vzeroupper
    ret
.size rbtl_asm_scan_html_event, .-rbtl_asm_scan_html_event

.globl rbtl_asm_next_ascii_token
.type rbtl_asm_next_ascii_token, @function
rbtl_asm_next_ascii_token:
    mov rax, rdx
.Lnext_token_skip:
    cmp rax, rsi
    jae .Lnext_token_none
    mov r9b, byte ptr [rdi + rax]
    cmp r9b, ' '
    je .Lnext_token_skip_one
    cmp r9b, 9
    jb .Lnext_token_start
    cmp r9b, 13
    jbe .Lnext_token_skip_one
    jmp .Lnext_token_start
.Lnext_token_skip_one:
    inc rax
    jmp .Lnext_token_skip
.Lnext_token_start:
    mov r10, rax
.Lnext_token_scan:
    cmp rax, rsi
    jae .Lnext_token_emit
    mov r9b, byte ptr [rdi + rax]
    cmp r9b, ' '
    je .Lnext_token_emit
    cmp r9b, 9
    jb .Lnext_token_scan_one
    cmp r9b, 13
    jbe .Lnext_token_emit
.Lnext_token_scan_one:
    inc rax
    jmp .Lnext_token_scan
.Lnext_token_emit:
    mov qword ptr [rcx], r10
    mov r9, rax
    sub r9, r10
    mov qword ptr [r8], r9
    ret
.Lnext_token_none:
    lea rax, [rsi + 1]
    ret
.size rbtl_asm_next_ascii_token, .-rbtl_asm_next_ascii_token

.globl rbtl_asm_parse_attr
.type rbtl_asm_parse_attr, @function
rbtl_asm_parse_attr:
    cmp rdx, rsi
    jae .Lparse_attr_none

    mov r8, rdx
    mov r9b, byte ptr [rdi + rdx]
    call .Lparse_attr_is_ident
    test r11d, r11d
    je .Lparse_attr_none

.Lparse_attr_name_loop:
    inc rdx
    cmp rdx, rsi
    jae .Lparse_attr_name_done
    mov r9b, byte ptr [rdi + rdx]
    call .Lparse_attr_is_ident
    test r11d, r11d
    jne .Lparse_attr_name_loop

.Lparse_attr_name_done:
    mov qword ptr [rcx], r8
    mov r10, rdx
    sub r10, r8
    mov qword ptr [rcx + 8], r10

.Lparse_attr_skip_ws:
    cmp rdx, rsi
    jae .Lparse_attr_no_value
    mov r9b, byte ptr [rdi + rdx]
    cmp r9b, ' '
    je .Lparse_attr_skip_one
    cmp r9b, 10
    je .Lparse_attr_skip_one
    jmp .Lparse_attr_after_ws
.Lparse_attr_skip_one:
    inc rdx
    jmp .Lparse_attr_skip_ws

.Lparse_attr_after_ws:
    cmp r9b, '='
    jne .Lparse_attr_no_value
    inc rdx

.Lparse_attr_value_skip_ws:
    cmp rdx, rsi
    jae .Lparse_attr_empty_value
    mov r9b, byte ptr [rdi + rdx]
    cmp r9b, ' '
    je .Lparse_attr_value_skip_one
    cmp r9b, 10
    je .Lparse_attr_value_skip_one
    jmp .Lparse_attr_value_start
.Lparse_attr_value_skip_one:
    inc rdx
    jmp .Lparse_attr_value_skip_ws

.Lparse_attr_value_start:
    cmp r9b, '"'
    je .Lparse_attr_quoted
    cmp r9b, 39
    je .Lparse_attr_quoted

    mov r8, rdx
.Lparse_attr_unquoted_vector_setup:
    mov eax, ' '
    movd xmm1, eax
    vpbroadcastb ymm1, xmm1
    mov eax, 10
    movd xmm2, eax
    vpbroadcastb ymm2, xmm2
    mov eax, '>'
    movd xmm3, eax
    vpbroadcastb ymm3, xmm3
.Lparse_attr_unquoted_vector_loop:
    lea r11, [rdx + 32]
    cmp r11, rsi
    ja .Lparse_attr_unquoted_loop
    vmovdqu ymm0, ymmword ptr [rdi + rdx]
    vpcmpeqb ymm4, ymm0, ymm1
    vpcmpeqb ymm5, ymm0, ymm2
    vpcmpeqb ymm0, ymm0, ymm3
    vpor ymm4, ymm4, ymm5
    vpor ymm0, ymm0, ymm4
    vpmovmskb eax, ymm0
    test eax, eax
    jne .Lparse_attr_unquoted_vector_hit
    add rdx, 32
    jmp .Lparse_attr_unquoted_vector_loop
.Lparse_attr_unquoted_vector_hit:
    bsf eax, eax
    add rdx, rax
    jmp .Lparse_attr_emit_value
.Lparse_attr_unquoted_loop:
    cmp rdx, rsi
    jae .Lparse_attr_emit_value
    mov r9b, byte ptr [rdi + rdx]
    cmp r9b, ' '
    je .Lparse_attr_emit_value
    cmp r9b, 10
    je .Lparse_attr_emit_value
    cmp r9b, '>'
    je .Lparse_attr_emit_value
    inc rdx
    jmp .Lparse_attr_unquoted_loop

.Lparse_attr_quoted:
    mov r10b, r9b
    inc rdx
    mov r8, rdx
.Lparse_attr_quoted_vector_setup:
    movzx eax, r10b
    movd xmm1, eax
    vpbroadcastb ymm1, xmm1
.Lparse_attr_quoted_vector_loop:
    lea r11, [rdx + 32]
    cmp r11, rsi
    ja .Lparse_attr_quoted_loop
    vmovdqu ymm0, ymmword ptr [rdi + rdx]
    vpcmpeqb ymm0, ymm0, ymm1
    vpmovmskb eax, ymm0
    test eax, eax
    jne .Lparse_attr_quoted_vector_hit
    add rdx, 32
    jmp .Lparse_attr_quoted_vector_loop
.Lparse_attr_quoted_vector_hit:
    bsf eax, eax
    add rdx, rax
    jmp .Lparse_attr_emit_value
.Lparse_attr_quoted_loop:
    cmp rdx, rsi
    jae .Lparse_attr_emit_value
    cmp byte ptr [rdi + rdx], r10b
    je .Lparse_attr_emit_value
    inc rdx
    jmp .Lparse_attr_quoted_loop

.Lparse_attr_emit_value:
    mov qword ptr [rcx + 16], r8
    mov r10, rdx
    sub r10, r8
    mov qword ptr [rcx + 24], r10
    mov qword ptr [rcx + 32], rdx
    mov dword ptr [rcx + 40], 1
    mov eax, 1
    vzeroupper
    ret

.Lparse_attr_empty_value:
    mov qword ptr [rcx + 16], rdx
    mov qword ptr [rcx + 24], 0
    mov qword ptr [rcx + 32], rdx
    mov dword ptr [rcx + 40], 1
    mov eax, 1
    ret

.Lparse_attr_no_value:
    mov qword ptr [rcx + 16], rdx
    mov qword ptr [rcx + 24], 0
    mov qword ptr [rcx + 32], rdx
    mov dword ptr [rcx + 40], 0
    mov eax, 1
    ret

.Lparse_attr_none:
    xor eax, eax
    ret

.Lparse_attr_is_ident:
    xor r11d, r11d
    cmp r9b, '0'
    jb .Lparse_attr_ident_symbols
    cmp r9b, '9'
    jbe .Lparse_attr_ident_yes
    cmp r9b, 'A'
    jb .Lparse_attr_ident_symbols
    cmp r9b, 'Z'
    jbe .Lparse_attr_ident_yes
    cmp r9b, 'a'
    jb .Lparse_attr_ident_symbols
    cmp r9b, 'z'
    jbe .Lparse_attr_ident_yes
.Lparse_attr_ident_symbols:
    cmp r9b, '-'
    je .Lparse_attr_ident_yes
    cmp r9b, '_'
    je .Lparse_attr_ident_yes
    cmp r9b, '/'
    je .Lparse_attr_ident_yes
    cmp r9b, ':'
    je .Lparse_attr_ident_yes
    cmp r9b, '+'
    je .Lparse_attr_ident_yes
    ret
.Lparse_attr_ident_yes:
    mov r11d, 1
    ret
.size rbtl_asm_parse_attr, .-rbtl_asm_parse_attr

.globl rbtl_asm_simple_selector_kind
.type rbtl_asm_simple_selector_kind, @function
rbtl_asm_simple_selector_kind:
    test rsi, rsi
    je .Lsimple_selector_none
    mov qword ptr [rdx], 0

    cmp rsi, 1
    jne .Lsimple_selector_not_all
    cmp byte ptr [rdi], '*'
    jne .Lsimple_selector_not_all
    mov eax, 1
    ret

.Lsimple_selector_not_all:
    mov r8b, byte ptr [rdi]
    cmp r8b, '#'
    je .Lsimple_selector_leading_id
    cmp r8b, '.'
    je .Lsimple_selector_leading_class

    xor rax, rax
.Lsimple_selector_tag_scan:
    cmp rax, rsi
    jae .Lsimple_selector_tag_only
    mov r9b, byte ptr [rdi + rax]
    call .Lsimple_selector_is_ident
    test r10d, r10d
    je .Lsimple_selector_tag_done
    inc rax
    jmp .Lsimple_selector_tag_scan
.Lsimple_selector_tag_only:
    test rax, rax
    je .Lsimple_selector_none
    mov qword ptr [rdx], rax
    mov eax, 2
    ret
.Lsimple_selector_tag_done:
    test rax, rax
    je .Lsimple_selector_none
    mov r11, rax
    inc rax
    cmp rax, rsi
    jae .Lsimple_selector_none
    mov r8b, byte ptr [rdi + r11]
    cmp r8b, '#'
    je .Lsimple_selector_tag_id_rest
    cmp r8b, '.'
    je .Lsimple_selector_tag_class_rest
    jmp .Lsimple_selector_none

.Lsimple_selector_leading_id:
    mov rax, 1
    mov r11d, 3
    jmp .Lsimple_selector_rest
.Lsimple_selector_leading_class:
    mov rax, 1
    mov r11d, 4
    jmp .Lsimple_selector_rest
.Lsimple_selector_tag_id_rest:
    mov qword ptr [rdx], r11
    mov r11d, 5
    jmp .Lsimple_selector_rest
.Lsimple_selector_tag_class_rest:
    mov qword ptr [rdx], r11
    mov r11d, 6

.Lsimple_selector_rest:
    cmp rax, rsi
    jae .Lsimple_selector_none
.Lsimple_selector_rest_loop:
    cmp rax, rsi
    jae .Lsimple_selector_emit_rest
    mov r9b, byte ptr [rdi + rax]
    call .Lsimple_selector_is_ident
    test r10d, r10d
    je .Lsimple_selector_none
    inc rax
    jmp .Lsimple_selector_rest_loop
.Lsimple_selector_emit_rest:
    mov eax, r11d
    ret

.Lsimple_selector_is_ident:
    xor r10d, r10d
    cmp r9b, '0'
    jb .Lsimple_selector_ident_symbols
    cmp r9b, '9'
    jbe .Lsimple_selector_ident_yes
    cmp r9b, 'A'
    jb .Lsimple_selector_ident_symbols
    cmp r9b, 'Z'
    jbe .Lsimple_selector_ident_yes
    cmp r9b, 'a'
    jb .Lsimple_selector_ident_symbols
    cmp r9b, 'z'
    jbe .Lsimple_selector_ident_yes
.Lsimple_selector_ident_symbols:
    cmp r9b, '-'
    je .Lsimple_selector_ident_yes
    cmp r9b, '_'
    je .Lsimple_selector_ident_yes
    cmp r9b, '/'
    je .Lsimple_selector_ident_yes
    cmp r9b, ':'
    je .Lsimple_selector_ident_yes
    cmp r9b, '+'
    je .Lsimple_selector_ident_yes
    ret
.Lsimple_selector_ident_yes:
    mov r10d, 1
    ret

.Lsimple_selector_none:
    xor eax, eax
    ret
.size rbtl_asm_simple_selector_kind, .-rbtl_asm_simple_selector_kind

.section .note.GNU-stack,"",@progbits
