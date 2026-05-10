# JM OS Common Configuration

PRODUCT_NAME := jmos
PRODUCT_BRAND := JM_OS
PRODUCT_DEVICE := generic
PRODUCT_MANUFACTURER := JM_OS

# Inherit from common AOSP product configuration
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)

# JM OS Specific Properties
PRODUCT_PROPERTY_OVERRIDES += \
    ro.jmos.version=1.0.0 \
    ro.jmos.build.type=official \
    ro.jmos.release=stable \
    ro.config.ringtone=JM_Ringtone.ogg \
    ro.config.notification_sound=JM_Notification.ogg \
    ro.config.alarm_alert=JM_Alarm.ogg \
    ro.jmos.kernel=JM-Vortex-Kernel \
    ro.config.bootsound=1 \
    ro.boot.bootsound=1

# Boot Animation & Audio
PRODUCT_COPY_FILES += \
    vendor/jmos/prebuilt/common/media/bootanimation.zip:system/media/bootanimation.zip \
    vendor/jmos/prebuilt/common/media/audio/ui/PowerOn.ogg:system/media/audio/ui/PowerOn.ogg

# Audio Prebuilts
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,vendor/jmos/prebuilt/common/media/audio,system/media/audio)

# App Inclusion
PRODUCT_PACKAGES += \
    JM_FileManager

# Setup Wizard & Support
PRODUCT_PROPERTY_OVERRIDES += \
    ro.jmos.setupwizard.mode=custom \
    ro.jmos.support.url=https://jmos.dev \
    ro.jmos.community.url=https://t.me/jmos_official

# Performance & RAM Management
PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.zram_enabled=true \
    ro.vendor.qti.config.zram=true \
    ro.zram.mark_idle_delay_mins=60 \
    ro.zram.first_wb_delay_mins=180 \
    ro.config.low_ram=false \
    ro.lmk.kill_heaviest_task=true \
    ro.lmk.kill_timeout_ms=100

# Privacy & Advanced Features
PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.call_recording=true \
    persist.sys.reboot.advanced=true \
    ro.reboot.advanced=true \
    persist.sys.privacy_guard=true \
    ro.jmos.privacy.enabled=true

# Status Bar & UI Customization
PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.network_traffic.enabled=1 \
    persist.sys.network_traffic.unit=1 \
    persist.sys.network_traffic.period=1000 \
    persist.sys.statusbar.clock_center=true \
    persist.sys.statusbar.battery_percent=true \
    ro.jmos.statusbar.custom=true \
    persist.sys.double_tap_to_sleep=true \
    persist.sys.double_tap_to_wake=true \
    ro.jmos.audio.steps_custom=true \
    persist.sys.spoofing_enabled=1 \
    ro.jmos.spoofing=true \
    persist.sys.custom_carrier=JM OS \
    ro.jmos.parallel_space=true \
    ro.product.model=JM-Vortex-One \
    ro.product.brand=JM \
    ro.product.manufacturer=JM-OS \
    ro.jmos.device_name=JM-Vortex-One \
    ro.config.lock_sound=/system/media/audio/ui/Lock.ogg \
    ro.config.unlock_sound=/system/media/audio/ui/Unlock.ogg \
    ro.config.low_battery_sound=/system/media/audio/ui/LowBattery.ogg \
    ro.config.trusted_sound=/system/media/audio/ui/Trusted.ogg \
    ro.config.charging_started_sound=/system/media/audio/ui/ChargingStarted.ogg

# Signature Spoofing Permissions
PRODUCT_COPY_FILES += \
    vendor/jmos/prebuilt/common/etc/permissions/android.privileged.fake_signature.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/android.privileged.fake_signature.xml

# Performance Init Script
PRODUCT_COPY_FILES += \
    vendor/jmos/prebuilt/common/etc/init/jmos-sysinit.rc:$(TARGET_COPY_OUT_SYSTEM)/etc/init/jmos-sysinit.rc

# Fonts
PRODUCT_COPY_FILES += \
    vendor/jmos/prebuilt/common/etc/fonts.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/fonts.xml \
    $(call find-copy-subdir-files,*,vendor/jmos/prebuilt/common/fonts,$(TARGET_COPY_OUT_SYSTEM)/fonts)

PRODUCT_PROPERTY_OVERRIDES += \
    ro.jmos.font_custom=true

# SELinux (Default to Enforcing for security, uncomment to set permissive)
# PRODUCT_PROPERTY_OVERRIDES += \
#    ro.selinux.state=permissive

# Resource Overlays
DEVICE_PACKAGE_OVERLAYS += vendor/jmos/overlay
