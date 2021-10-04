.DEFAULT_GOAL := all

NAME := sml1_practice

GFX := gfx
GFX_OUT := gfx/out

BUILD_DIR := build

SML1_V10_ROM := Super Mario Land (W) (V1.0) [!].gb
SML1_V10_SAVESTATES_BSDIFF := Super Mario Land (W) (V1.0) [!].gb.bsdiff

SML1_V11_ROM := Super Mario Land (W) (V1.1) [!].gb
SML1_V11_SAVESTATES_BSDIFF := Super Mario Land (W) (V1.1) [!].gb.bsdiff

SOURCE_FILE := $(NAME).asm

OBJECT_FILE_V10 := $(BUILD_DIR)/$(NAME)_v10.o
OBJECT_FILE_V11 := $(BUILD_DIR)/$(NAME)_v11.o

OUTPUT_V10_ROM := $(NAME)_v10.gb
OUTPUT_V11_ROM := $(NAME)_v11.gb

SYM_V10_ROM := $(BUILD_DIR)/$(NAME)_v10.sym
SYM_V11_ROM := $(BUILD_DIR)/$(NAME)_v11.sym

TMP_ROM_V10 := $(BUILD_DIR)/$(NAME)_temp_v10.gb
TMP_ROM_V11 := $(BUILD_DIR)/$(NAME)_temp_v11.gb

$(GFX_OUT)/version.2bpp:
	rgbgfx -f -o $(GFX_OUT)/version.2bpp $(GFX)/version.png

$(GFX_OUT)/up_down_arrows_active.2bpp:
	rgbgfx -f -o $(GFX_OUT)/up_down_arrows_active.2bpp $(GFX)/up_down_arrows_active.png

$(GFX_OUT)/up_down_arrows_inactive.2bpp:
	rgbgfx -f -o $(GFX_OUT)/up_down_arrows_inactive.2bpp $(GFX)/up_down_arrows_inactive.png

.PHONY: dirs
dirs:
	mkdir -p $(BUILD_DIR) $(GFX_OUT)

.PHONY: gfx
gfx: $(GFX_OUT)/version.2bpp $(GFX_OUT)/up_down_arrows_active.2bpp $(GFX_OUT)/up_down_arrows_inactive.2bpp

.PHONY: v10
v10: dirs gfx
	bspatch "$(SML1_V10_ROM)" "$(TMP_ROM_V10)" "$(SML1_V10_SAVESTATES_BSDIFF)" || cp "$(SML1_V10_ROM)" "$(TMP_ROM_V10)"
	rgbasm -D "VERSION=10" -E $(SOURCE_FILE) -o $(OBJECT_FILE_V10)
	rgblink -n $(SYM_V10_ROM) -O $(TMP_ROM_V10) -o $(OUTPUT_V10_ROM) $(OBJECT_FILE_V10)
	rgbfix -p 0 -f gh $(OUTPUT_V10_ROM)

.PHONY: v11
v11: dirs gfx
	bspatch "$(SML1_V11_ROM)" "$(TMP_ROM_V11)" "$(SML1_V11_SAVESTATES_BSDIFF)" || cp "$(SML1_V11_ROM)" "$(TMP_ROM_V11)"
	rgbasm -D "VERSION=11" -E $(SOURCE_FILE) -o $(OBJECT_FILE_V11)
	rgblink -n $(SYM_V11_ROM) -O $(TMP_ROM_V11) -o $(OUTPUT_V11_ROM) $(OBJECT_FILE_V11)
	rgbfix -p 0 -f gh $(OUTPUT_V11_ROM)

all: v10 v11

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR) $(GFX_OUT) $(OUTPUT_V10_ROM) $(OUTPUT_V11_ROM)
