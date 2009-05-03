
SECTIONS {
  . = 0x1000 ;
  .init : { *(.init)  }
  stage3_start = . ;
  .text : { *(.text) }
  .data : { *(.data) *(.bss) }
  stage3_end = . ;
}