# 设置交叉编译器 (改为你的实际路径)
CC := x86_64-w64-mingw32-gcc
LD := x86_64-w64-mingw32-ld

# 使用 Windows 兼容的路径设置
BUILD_DIR := build
SRC_DIR := src
INCLUDE_DIR := include

# Windows 兼容的源文件查找方式
SOURCES := $(wildcard $(SRC_DIR)/*.c $(SRC_DIR)/*/*.c)
OBJECTS := $(patsubst $(SRC_DIR)/%.c,$(BUILD_DIR)/%.o,$(SOURCES))

# 编译选项
CFLAGS := -I$(INCLUDE_DIR) -Wall -Wextra
LDFLAGS := -nostdlib

# 默认目标
all: $(BUILD_DIR)/kernel.bin

# 确保构建目录存在
$(shell mkdir -p $(BUILD_DIR))

# 编译规则
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	@echo Compiling $<
	@$(CC) $(CFLAGS) -c $< -o $@

# 链接规则
$(BUILD_DIR)/kernel.bin: $(OBJECTS)
	@echo Linking $@
	@$(LD) $(LDFLAGS) -o $@ $^

# 清理
clean:
	@echo Cleaning...
	@if exist $(BUILD_DIR) rmdir /s /q $(BUILD_DIR)

.PHONY: all clean