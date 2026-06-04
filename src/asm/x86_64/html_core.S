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
    je .Lvalidate_unsupported
.Lvalidate_next:
    inc rax
    jmp .Lvalidate_loop
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

.section .note.GNU-stack,"",@progbits
