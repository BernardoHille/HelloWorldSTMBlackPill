TARGET    := HelloWorld
BUILD_DIR := build

PREFIX    := arm-none-eabi-
CC        := $(PREFIX)gcc
AS        := $(PREFIX)gcc -x assembler-with-cpp
OBJCOPY   := $(PREFIX)objcopy
SIZE      := $(PREFIX)size
STM32_PROGRAMMER ?= C:/Program Files/STMicroelectronics/STM32Cube/STM32CubeProgrammer/bin/STM32_Programmer_CLI.exe

MCU       := -mcpu=cortex-m4 -mthumb

C_DEFS    := -DSTM32F401xE

CFLAGS    := $(MCU) $(C_DEFS) \
             -Wall -Wextra \
             -fdata-sections -ffunction-sections -ffreestanding \
             -std=c99 -O2 -g3

ASFLAGS   := $(MCU) -Wall -fdata-sections -ffunction-sections

LDSCRIPT  := linker/STM32F401CETX_FLASH.ld

LDFLAGS   := $(MCU) -nostdlib \
             -T$(LDSCRIPT) \
             -Wl,-Map=$(BUILD_DIR)/$(TARGET).map,--cref \
             -Wl,--gc-sections \
             -Wl,--print-memory-usage \
             -Wl,--build-id=none

C_SOURCES   := src/main.c
ASM_SOURCES := startup/startup_stm32f401ceux.s

OBJECTS  := $(addprefix $(BUILD_DIR)/,$(notdir $(C_SOURCES:.c=.o)))
OBJECTS  += $(addprefix $(BUILD_DIR)/,$(notdir $(ASM_SOURCES:.s=.o)))
DEPS     := $(OBJECTS:.o=.d)

.PHONY: all clean flash

all: $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).hex $(BUILD_DIR)/$(TARGET).bin

$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS) $(LDSCRIPT) | $(BUILD_DIR)
	$(CC) $(OBJECTS) $(LDFLAGS) -o $@
	$(SIZE) $@

$(BUILD_DIR)/%.o: src/%.c | $(BUILD_DIR)
	$(CC) -c $(CFLAGS) -MMD -MP -MF $(@:.o=.d) $< -o $@

$(BUILD_DIR)/%.o: startup/%.s | $(BUILD_DIR)
	$(AS) -c $(ASFLAGS) $< -o $@

$(BUILD_DIR)/$(TARGET).hex: $(BUILD_DIR)/$(TARGET).elf
	$(OBJCOPY) -O ihex $< $@

$(BUILD_DIR)/$(TARGET).bin: $(BUILD_DIR)/$(TARGET).elf
	$(OBJCOPY) -O binary -S $< $@

$(BUILD_DIR):
	mkdir -p $@

flash: $(BUILD_DIR)/$(TARGET).bin
	"$(STM32_PROGRAMMER)" -c port=SWD freq=4000 mode=UR -w "$(BUILD_DIR)/$(TARGET).bin" 0x08000000 -v -rst

clean:
	rm -rf $(BUILD_DIR)

-include $(DEPS)
