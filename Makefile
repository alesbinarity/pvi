# procedure
# COM path

PLM      = plm80c
ASM80    = asm80
LINKER   = link
LOCATE   = locate
OBJHEX   = objhex
HEXBIN   = hex2bin

# --- главный модуль проекта (входная точка) ---
MAIN     := PVI
MAIN_OBJ := $(MAIN).OBJ

# входные файлы
PLMS := $(wildcard *.PLM)
ASMS := $(wildcard *.ASM)

# все объекты проекта
OBJS := $(PLMS:.PLM=.OBJ) $(ASMS:.ASM=.OBJ)

# гарантируем порядок: сначала MAIN_OBJ, потом остальные
OTHER_OBJS := $(filter-out $(MAIN_OBJ),$(OBJS))
LINK_OBJS  := $(MAIN_OBJ) $(OTHER_OBJS)

# что билдим (одна COM)
all: $(MAIN_OBJ) $(MAIN).COM


# --- цепочка проекта: OBJ -> LNK -> LOC -> HEX -> COM ---

$(MAIN).COM: $(MAIN).HEX
	$(HEXBIN) -s 100H -e COM $<

$(MAIN).HEX: $(MAIN).LOC
	$(OBJHEX) $< TO $@

$(MAIN).LOC: $(MAIN).LNK
	$(LOCATE) $< TO $@ "CODE(100H) STACKSIZE(100)" MAP

# Линкуем проект: первым MAIN_OBJ, затем остальные OBJ, затем CPM.LIB
$(MAIN).LNK: $(LINK_OBJS) CPM.LIB
	$(LINKER) $(LINK_OBJS),CPM.LIB,PLM80.LIB TO $@ MAP

# --- компиляция исходников ---

%.OBJ: %.PLM
	$(PLM) $< CODE

%.OBJ: %.ASM
	$(ASM80) $<

clean:
	rm -f *.OBJ *.LNK *.LOC *.MAP *.LST *.HEX *.COM ntvcm.log

.PHONY: all clean

.SECONDARY: %.OBJ %.LNK %.LOC %.HEX
