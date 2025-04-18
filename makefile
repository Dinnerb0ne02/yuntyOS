# 当程序为测试版时, 在版本头添加beta, 如果不是则不添加
VERSION := beta 0.0.1
NOTE := Hello World

# 交叉编译器 (MinGW64 工具链)
CC := x86_64-w64-mingw32-gcc
LD := ld

# 项目文件
BUILD_DIR := build
INCLUDE_DIR := includes
GRUB_DIR := grub
ISO_DIR := iso

SOURCE_DIRS := kernel arch/x86 hal

C_SOURCES := $(foreach dir,$(SOURCE_DIRS),$(wildcard $(dir)/*.c $(dir)/*/*.c))
S_SOURCES := $(foreach dir,$(SOURCE_DIRS),$(wildcard $(dir)/*.S))

OBJECTS := $(patsubst %.c,$(BUILD_DIR)/%.o,$(C_SOURCES)) $(patsubst %.S,$(BUILD_DIR)/%.o,$(S_SOURCES))

# 编译选项 CFLAGS
LDFLAGS := -m32 -nostdlib -T link/link.ld
WARNINGS := -Wall -Wextra
OPTIMIZATION := -O0
DEBUG_FLAGS := -g

CFLAGS := -I$(INCLUDE_DIR) -ffreestanding -mno-red-zone -m32
CFLAGS += $(OPTIMIZATION) $(DEBUG_FLAGS)



# 默认目标
all: iso

# 创建构建目录
$(shell mkdir -p $(BUILD_DIR))

# 编译
$(BUILD_DIR)/%.o: %.c
	@echo "[CC] $<"
	@mkdir -p $(dir $@)
	@$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: %.S
	@echo "[AS] $<"
	@mkdir -p $(dir $@)
	@$(CC) $(CFLAGS) -c $< -o $@

# 链接
$(BUILD_DIR)/kernel.elf: $(OBJECTS)
	@echo "[LD] $@"
	@mkdir -p $(dir $@)
	@$(LD) $(LDFLAGS) -o $@ $^


GRUB_MODULES_PATH=D:/MTY/Code/grub-2.06-for-windows/i386-pc/
# GRUB core
$(ISO_DIR)/boot/grub/core.img:
	@echo "[GRUB] Deploying grub files"

	@mkdir -p $(BUILD_DIR)
	@mkdir -p $(ISO_DIR)/boot
	@mkdir -p $(ISO_DIR)/boot/grub
	@mkdir -p $(ISO_DIR)/boot/grub/fonts

	@cp -r $(GRUB_DIR)/i386-pc $(ISO_DIR)/boot/grub/
	@cp -r $(GRUB_DIR)/i386-efi $(ISO_DIR)/boot/grub/
	@cp -r $(GRUB_DIR)/x86_64-efi $(ISO_DIR)/boot/grub/
	@cp -r $(GRUB_DIR)/locale $(ISO_DIR)/boot/grub/
	@cp $(GRUB_DIR)/*.pf2 $(ISO_DIR)/boot/grub/fonts/
	@mkdir -p $(dir $@)

	@echo "[GRUB] Generating core image"
	@grub-mkimage --directory=$(ISO_DIR)/boot/grub/i386-pc \
	    --prefix=/boot/grub \
	    --output=$@ \
	    --format=i386-pc-eltorito \
	    --compression=auto \
	    --config=$(ISO_DIR)/boot/grub/grub.cfg \
	    biosdisk iso9660

# GRUB config
$(ISO_DIR)/boot/grub/grub.cfg:
	@echo "[GRUB] Creating configuration"
	@mkdir -p $(dir $@)
	@echo "menuentry 'YuntyOS' {" > $@
	@echo "  multiboot2 /boot/kernel.elf" >> $@
	@echo "  boot" >> $@

# file
$(ISO_DIR)/boot/kernel.elf: $(BUILD_DIR)/kernel.elf
	@echo "[COPY] kernel.elf to ISO directory"
	@mkdir -p $(dir $@)
	@cp $< $@

# generate ISO 
iso: $(ISO_DIR)/boot/kernel.elf $(ISO_DIR)/boot/grub/grub.cfg $(ISO_DIR)/boot/grub/core.img
	@echo "[ISO] Creating ISO image"
	@genisoimage -R -J -o $(BUILD_DIR)/YuntyOS.iso -b boot/grub/core.img -c boot/grub/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table $(ISO_DIR)


clean:
	@echo "[CLEAN] Cleaning build files"
	@rm -rf $(BUILD_DIR)
	@rm -rf $(ISO_DIR)
	@rm -rf ./*.log
	@echo "[CLEAN] Done"

# run QEMU
run: iso
	@echo "[QEMU] Running QEMU"
	@qemu-system-x86_64 -cdrom $(BUILD_DIR)/YuntyOS.iso -boot d

# # 调试模式
# debug: CFLAGS += -g
# debug: WARNINGS := -Wall
# debug: OPTIMIZATION := -O0
# debug: all

# PHONY: all clean iso run