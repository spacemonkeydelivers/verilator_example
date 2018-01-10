SECTIONS
{
    /* this is the reset address */
    __reset=0;
    ENTRY(__reset)
    /* the assembly should be placed in  in .text section */
    .text 0 : {
        *(.text);
    }
}
