TARGET := iphone:clang:latest:14.0

ARCHS = arm64
SDKVERSION = 17.0
TARGET_VERSION = 14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = zxUpdateNotifier

zxUpdateNotifier_FILES = Tweak.m zxUpdateManager.m
zxUpdateNotifier_FRAMEWORKS = UIKit Foundation
zxUpdateNotifier_CFLAGS = -fobjc-arc
zxUpdateNotifier_LDFLAGS = -Wl,-segalign,4000

include $(THEOS_MAKE_PATH)/tweak.mk