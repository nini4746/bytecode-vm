# Makefile for clox - bytecode VM for the Lox language (Crafting Interpreters Part III)
# macOS clang, C99, no external dependencies.
#
# Usage:
#   make                 -> builds ./clox
#   make clean
#   make CFLAGS_EXTRA=-DDEBUG_TRACE_EXECUTION
#   make CFLAGS_EXTRA='-DDEBUG_STRESS_GC -DDEBUG_LOG_GC'

CC       := clang
CFLAGS   := -std=c99 -Wall -Wextra -Wno-unused-parameter -g -O2
CFLAGS_EXTRA ?=
SRC_DIR  := src
BUILD_DIR := build
TARGET   := clox

SRCS := $(wildcard $(SRC_DIR)/*.c)
OBJS := $(patsubst $(SRC_DIR)/%.c,$(BUILD_DIR)/%.o,$(SRCS))
DEPS := $(OBJS:.o=.d)

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) $(CFLAGS_EXTRA) -o $@ $(OBJS)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) $(CFLAGS_EXTRA) -MMD -MP -c $< -o $@

$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

clean:
	@rm -rf $(BUILD_DIR) $(TARGET)

-include $(DEPS)
