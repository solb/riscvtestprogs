ifeq ($(OS),Windows_NT)
	LOGISIM_BINARY := /usr/local/bin/logisim.exe
	PATH := $(wildcard /c/Program\ Files/Java/jdk*/bin):$(PATH)
else
	LOGISIM_BINARY := $(HOME)/local/bin/logisim
	PATH := $(HOME)/local/bin:$(PATH)
endif

CROSS := riscv32-

AS           := $(CROSS)as
JAVA         := java
JAVAC        := javac
JAVACFLAGS   :=
JAVAFLAGS    := -cp .
LD           := $(CROSS)ld
LDFLAGS      := -e 0x0
LOGISIM       = $(shell which logisim 2>/dev/null)
LOGISIMFLAGS := -tty tty
OBJCOPY      := $(CROSS)objcopy
OBJDUMP      := $(CROSS)objdump

.SECONDARY: Bin2Img.class java.check

.PHONY: help
help:
	@echo "USAGE: make <filename>"
	@echo
	@echo "Produces the requested output file, which should be named after the input file."
	@echo "The most useful targets are:"
	@echo "	program.img : Generates a Logisim memory image"
	@echo "	program.txt : Disassembles a program to show instructions alongside addresses"
	@echo "For example, if you have an assembly source file named myprog.S or myprog.s, do:"
	@echo "	$ make program.img	and load the resulting memory image into your Logisim CPU"
	@echo
	@echo "There are also a few special targets that don't produce files:"
	@echo "	run   : Generate the command necessary to run an image file in your CPU"
	@echo "	clean : Remove generated files"
	@echo "	help  : You're looking at it!"

.PHONY: run
run: $(LOGISIM_BINARY) cpu.path
	@echo "$(LOGISIM) $(LOGISIMFLAGS) $(shell cat $(word 2,$^)) -load"

.PHONY: clean
clean:
	git clean -fX

cpu.path:
	@echo -n "Enter the path to your CPU CIRC file: " >&2
	@read path; \
		echo "$$path" >cpu.path

java.check:
	@which javac >/dev/null || (\
		echo ;\
		echo ERROR: No Java installation found! ;\
		echo Please download the JDK from http://www.oracle.com/technetwork/java/javase/downloads ;\
		echo Then run the installer to completion, keeping the default installation path. ;\
		echo ;\
		false )
	touch java.check

/usr/local/bin/logisim.exe $(HOME)/local/bin/logisim.jar:
	mkdir -p "$(dir $@)"
	curl -L sf.net/projects/circuit/files/latest >"$@"

$(HOME)/local/bin/logisim: $(HOME)/local/bin/logisim.jar
	echo "#!/bin/sh" >"$@"
	echo 'java -jar $< "$$@"' >>"$@"
	chmod +x "$@"

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
