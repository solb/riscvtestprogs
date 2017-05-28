ifeq ($(OS),Windows_NT)
	LOGISIM := /usr/local/bin/logisim
	LOGISIM_BINARY := $(LOGISIM).exe
	PATH := $(wildcard /c/Program\ Files/Java/jdk*/bin):$(PATH)
else
	LOGISIM := $(HOME)/local/bin/logisim
	LOGISIM_BINARY := $(LOGISIM)
	PATH := $(HOME)/local/bin:$(PATH)
endif

CROSS := riscv32-

AS           := $(CROSS)as
ASFLAGS      := -march=rv32i
CC           := $(CROSS)gcc
CFLAGS       := -Og -std=c99 -Wall -Wextra -Wpedantic
CPP          := cpp
CPPFLAGS     := $(if $(wildcard include),-Iinclude)
JAVA         := java
JAVAC        := javac
JAVACFLAGS   :=
JAVAFLAGS    := -cp .
LD           := $(CROSS)ld
LDFLAGS      := -Ttext=0x0 -e 0x0 $(if $(wildcard lib),-Llib) $(if $(wildcard /usr/local/lib/gcc/riscv32-elf/7.1.0/libgcc.a),-L/usr/local/lib/gcc/riscv32-elf/7.1.0)
LDLIBS       := $(if $(wildcard lib/libc.a),-lc) $(if $(wildcard /usr/local/lib/gcc/riscv32-elf/7.1.0/libgcc.a),-lgcc)
LOGISIMFLAGS := -tty tty
OBJCOPY      := $(CROSS)objcopy
OBJDUMP      := $(CROSS)objdump

.SECONDARY: crt0.o Bin2Img.class tar.check preprocessor.check assembler.check compiler.check java.check $(subst .S,.o,$(wildcard riscv-tests/isa/rv32ui/*.S))

.PHONY: help
help:
	@echo "USAGE: make <filename>"
	@echo
	@echo "Produces the requested output file, which should be named after the input file."
	@echo "The most useful targets are:"
	@echo "	program.img : Generates a Logisim memory image"
	@echo "	program.txt : Disassembles a program to show instructions alongside addresses"
	@echo "	lib/libc.a  : Builds a very limited C language library for application use"
	@echo "For example, if you have an assembly source file named myprog.S or myprog.s, do:"
	@echo -n "	"
ifeq ($(OS),Windows_NT)
	@echo -n "$$"
else
	@echo -n "%"
endif
	@echo " make program.img	and load the resulting memory image into your Logisim CPU"
	@echo
	@echo "There are also a few special targets that don't produce files:"
	@echo "	run       : Generate the command necessary to run an image file in your CPU"
	@echo "	clean     : Remove generated files"
	@echo "	distclean : Same and also make riscv-tests/ pristine"
	@echo "	help      : You're looking at it!"

.PHONY: run
run: $(LOGISIM_BINARY) cpu.path
	@echo "$(LOGISIM) $(LOGISIMFLAGS) $(shell cat $(word 2,$^)) -load"

.PHONY: clean
clean:
	git clean -fX

.PHONY: distclean
distclean: clean
	git submodule foreach --recursive git clean -fx

cpu.path:
	@echo >&2
	@echo -n "Enter the path to your CPU CIRC file: " >&2
	@read path; \
		echo "$$path" >cpu.path

tar.check:
	@which tar >/dev/null || \
		pacman -S --noconfirm tar
	touch "$@"

preprocessor.check:
	@which $(word 1,$(CPP)) >/dev/null || \
		if [ "$(OS)" = "Windows_NT" ] ;\
		then \
			pacman -S --noconfirm gcc ;\
		else \
			xcode-select --install ;\
		fi
	touch "$@"

assembler.check: tar.check
	@which $(AS) >/dev/null || (\
		echo ;\
		echo ERROR: No cross-assembly toolchain found! ;\
		echo Please install one by running: ;\
		echo -n "	" ;\
		if [ "$(OS)" = "Windows_NT" ] ;\
		then \
			echo $$ curl cs.shadysideacademy.org/comporg/riscv32-msys.tar \| tar xP ;\
		else \
			echo % curl cs.shadysideacademy.org/comporg/riscv32-osx.tar \| sudo tar xP \&\& chmod +x /usr/local/bin/riscv32-\* ;\
		fi ;\
		echo ;\
		false )
	touch "$@"

compiler.check: assembler.check
	@which $(CC) >/dev/null || (\
		echo ;\
		echo ERROR: No cross-compilation toolchain found! ;\
		echo Please install one by running: ;\
		echo -n "	" ;\
		if [ "$(OS)" = "Windows_NT" ] ;\
		then \
			echo $$ curl cs.shadysideacademy.org/comporg/riscv32-msys-c.tar \| tar xP ;\
		else \
			echo % curl cs.shadysideacademy.org/comporg/riscv32-osx-c.tar \| sudo tar xP \&\& chmod +x /usr/local/bin/riscv32-\* ;\
		fi ;\
		echo ;\
		false )
	touch "$@"

java.check:
	@which javac >/dev/null || (\
		echo ;\
		echo ERROR: No Java installation found! ;\
		echo Please download the JDK from http://www.oracle.com/technetwork/java/javase/downloads ;\
		echo Then run the installer to completion, keeping the default installation path. ;\
		echo ;\
		false )
	touch "$@"

/usr/local/bin/logisim.exe $(HOME)/local/bin/logisim.jar:
	@mkdir -p "$(dir $@)"
	@curl -L sf.net/projects/circuit/files/latest >"$@"

$(HOME)/local/bin/logisim: $(HOME)/local/bin/logisim.jar
	echo "#!/bin/sh" >"$@"
	echo 'java -jar $< "$$@"' >>"$@"
	chmod +x "$@"

lib/libc.a: $(subst .c,.o,$(wildcard lib/*.c)) $(subst .s,.o,$(wildcard lib/*.s)) | compiler.check

%.a:
	ar rs "$@" $^

%.bin: %.lo
	$(OBJCOPY) -O binary "$<" "$@"

%.class: %.java java.check
	$(JAVAC) $(JAVACFLAGS) "$<"

%.img: %.bin Bin2Img.class
	$(JAVA) $(JAVAFLAGS) "$(basename $(word 2,$^))" "$<" "$@"

%.lo: %.o crt0.o
	$(LD) $(LDFLAGS) -o "$@" crt0.o "$<" $(LDLIBS)

%.o: %.c compiler.check
	$(CC) $(CPPFLAGS) $(CFLAGS) -c -o "$@" "$<"

%.o: %.S preprocessor.check assembler.check
	$(CPP) $(CPPFLAGS) "$<" | $(AS) $(ASFLAGS) -o "$@"

%.o: %.s assembler.check
	$(AS) $(ASFLAGS) -o "$@" "$<"

%.s: %.c compiler.check
	$(CC) $(CPPFLAGS) $(CFLAGS) -S -o "$@" "$<"

%.txt: %.lo
	$(OBJDUMP) -d "$<" >"$@"
