
One can use the scripts in question as follows:

---
cc -nostdlib -nodefaultlibs -nostartfiles \
       -T<INFRA_PATH>/ld.scripts/simple_asm.ld
---

To disasm:

---
riscv32-unknown-elf-objdump the_object_file -d
---
