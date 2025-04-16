# 设置交叉编译器 (MinGW-w64 工具链)
CC := x86_64-w64-mingw32-gcc
LD := ld

# 设置路径
BUILD_DIR := build
INCLUDE_DIR := includes
GRUB_DIR := grub
ISO_DIR := iso

# 源文件目录列表
SOURCE_DIRS := kernel arch/x86 hal

# 自动查找所有源文件
C_SOURCES := $(foreach dir,$(SOURCE_DIRS),$(wildcard $(dir)/*.c $(dir)/*/*.c))
S_SOURCES := $(foreach dir,$(SOURCE_DIRS),$(wildcard $(dir)/*.S))

# 生成目标文件路径
OBJECTS := $(patsubst %.c,$(BUILD_DIR)/%.o,$(C_SOURCES)) $(patsubst %.S,$(BUILD_DIR)/%.o,$(S_SOURCES))

# 编译选项
CFLAGS := -I$(INCLUDE_DIR) -ffreestanding -mno-red-zone
LDFLAGS := -nostdlib -T link/link.ld
WARNINGS := -Wall -Wextra
OPTIMIZATION := -O0
DEBUG_FLAGS := -g

CFLAGS := -I$(INCLUDE_DIR) -ffreestanding -mno-red-zone
CFLAGS += $(WARNINGS) $(OPTIMIZATION) $(DEBUG_FLAGS)

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

# 生成 GRUB 核心
$(ISO_DIR)/boot/grub/core.img:
	@echo "[GRUB] Generating core image"
	@mkdir -p $(dir $@)
	@GRUB_MODULES_PATH=D:/MTY/Code/grub-2.06-for-windows/i386-pc/
	@grub-mkimage -O i386-pc -o $@ -p "(hd0,msdos1)/boot/grub" \
		minicmd normal gzio gcry_crc terminal priority_queue gettext \
		extcmd datetime crypto bufio boot biosdisk part_gpt part_msdos \
		fat ext2 fshelp net multiboot2 all_video gfxterm

# 生成 GRUB 配置文件
$(ISO_DIR)/boot/grub/grub.cfg:
	@echo "[GRUB] Creating configuration"
	@mkdir -p $(dir $@)
	@echo "menuentry 'YuntyOS' {" > $@
	@echo "  multiboot2 /boot/kernel.elf" >> $@
	@echo "  boot" >> $@

# 复制内核文件到 ISO 目录
$(ISO_DIR)/boot/kernel.elf: $(BUILD_DIR)/kernel.elf
	@echo "[COPY] kernel.elf to ISO directory"
	@mkdir -p $(dir $@)
	@cp $< $@

# 生成 ISO 文件
iso: $(ISO_DIR)/boot/kernel.elf $(ISO_DIR)/boot/grub/grub.cfg $(ISO_DIR)/boot/grub/core.img
	@echo "[ISO] Creating ISO image"
	@genisoimage -R -J -o $(BUILD_DIR)/YuntyOS.iso -b boot/grub/core.img -c boot/grub/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table $(ISO_DIR)

# 清理
clean:
	@echo "[CLEAN] Cleaning build files"
	@rm -rf $(BUILD_DIR)
	@rm -rf $(ISO_DIR)
	@rm -rf ./*.log
	@echo "[CLEAN] Done"

# 运行 QEMU
run: iso
	@echo "[QEMU] Running QEMU"
	@qemu-system-x86_64 -cdrom $(BUILD_DIR)/kernel.iso -boot d

# # 调试模式
# debug: CFLAGS += -g
# debug: WARNINGS := -Wall
# debug: OPTIMIZATION := -O0
# debug: all

.PHONY: all clean iso run