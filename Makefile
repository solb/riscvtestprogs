ifeq ($(OS),Windows_NT)
	PATH := $(wildcard /c/Program\ Files/Java/jdk*/bin):$(PATH)
endif

CROSS := riscv32-

AS         := $(CROSS)as
JAVA       := java
JAVAC      := javac
JAVACFLAGS :=
JAVAFLAGS  := -cp .
LD         := $(CROSS)ld
LDFLAGS    := -e 0x0
OBJCOPY    := $(CROSS)objcopy
OBJDUMP    := $(CROSS)objdump

.SECONDARY: Bin2Img.class java.check

java.check:
	@which javac >/dev/null || (\
		echo ;\
		echo ERROR: No Java installation found! ;\
		echo Please download the JDK from http://www.oracle.com/technetwork/java/javase/downloads ;\
		echo Then run the installer to completion, keeping the default installation path. ;\
		echo ;\
		false )
	touch java.check

%.bin: %.lo
	$(OBJCOPY) -O binary "$<" "$@"

%.class: %.java java.check
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
