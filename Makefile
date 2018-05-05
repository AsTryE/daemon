export THEOS_DEVICE_IP = 192.168.2.98
export ARCHS = arm64
export TARGET = iphone:clang:latest:9.0

ADDITIONAL_CFLAGS = -w

include $(THEOS)/makefiles/common.mk

TOOL_NAME = ezsystemd
ezsystemd_FRAMEWORK = MobileCoreService
ezsystemd_CODESIGN_FLAGS += -Sezsystemd_server.ent
ezsystemd_FILES = main.mm
main.mm_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tool.mk
