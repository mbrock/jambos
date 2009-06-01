
SECTIONS {
  . = 0x1000 ;
  .init : { *(.init)  }
  stage3_start = . ;
  .text : { *(.text) }
  .data : { *(.data) *(.rodata) *(.bss) }
  /DISCARD/ : { *(.eh_frame .comment) }
  stage3_end = . ;
}
