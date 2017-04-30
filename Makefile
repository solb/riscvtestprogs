CROSS := riscv32-

AS         := $(CROSS)as
JAVA       := java
JAVAC      := javac
JAVACFLAGS :=
JAVAFLAGS  := -cp .
LD         := $(CROSS)ld
LDFLAGS    :=
OBJCOPY    := $(CROSS)objcopy
OBJDUMP    := $(CROSS)objdump

.SECONDARY: Bin2Img.class

%.bin: %.lo
	$(OBJCOPY) -O binary "$<" "$@"

%.class: %.java
	$(JAVAC) $(JAVACFLAGS) "$<"

%.img: %.bin Bin2Img.class
	$(JAVA) $(JAVAFLAGS) "$(basename $(word 2,$^))" "$<" "$@"

%.lo: %.o
	$(LD) $(LDFLAGS) -o "$@" "$<"

%.o: %.S
	$(CPP) $(CPPFLAGS) "$<" | $(AS) $(ASFLAGS) -o "$@"

%.o: %.s
	$(AS) $(ASFLAGS) -o "$@" "$<"

%.txt: %.o
	$(OBJDUMP) -d "$<" >"$@"
