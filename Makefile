TARGET := iphone:clang:17.0:10.0
INSTALL_TARGET_PROCESSES = SpringBoard

THEOS_DEVICE_IP = 127.0.0.1
THEOS_DEVICE_PORT = 22

ARCHS = arm64 arm64e
SDKVERSION = 17.0
TARGET_VERSION = 10.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = zxUpdateNotifier

zxUpdateNotifier_FILES = Tweak.m zxUpdateManager.m
zxUpdateNotifier_FRAMEWORKS = UIKit Foundation
zxUpdateNotifier_PRIVATE_FRAMEWORKS = AppSupport
zxUpdateNotifier_CFLAGS = -fobjc-arc
zxUpdateNotifier_LDFLAGS = -Wl,-segalign,4000

include $(THEOS_MAKE_PATH)/tweak.mk