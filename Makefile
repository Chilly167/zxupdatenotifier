TARGET := iphone:clang:latest:latest
ARCHS = arm64 arm64e
INSTALL_TARGET_PROCESSES = WhatsApp

export SDKVERSION = $(shell xcrun --sdk iphoneos --show-sdk-version)

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = zxUpdateNotifier

$(TWEAK_NAME)_FILES = $(wildcard src/*.m)
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -Wno-deprecated-declarations

include $(THEOS_MAKE_PATH)/tweak.mk