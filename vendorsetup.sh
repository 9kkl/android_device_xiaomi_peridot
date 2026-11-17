#
# Copyright (C) 2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Apply AGM patch (c6bcc20)
for AGM_PATH in "vendor/qcom/opensource/agm" "hardware/qcom-caf/sm8650/audio/agm"; do
    if [ -d "$AGM_PATH" ]; then
        if ! grep -q "libagmclient_headers" "$AGM_PATH/ipc/HwBinders/agm_ipc_client/Android.bp" 2>/dev/null; then
            echo "Applying AGM Soong conversion patch to $AGM_PATH..."
            git -C "$AGM_PATH" apply -v --whitespace=nowarn "$DEVICE_PATH/patches/0001-agm-convert-bringup-libraries-to-soong.patch"
        fi
        break
    fi
done

# Apply system/media patch (b08cbeb)
if [ -d "system/media" ]; then
    if ! grep -q "libaudioroute-v34" system/media/audio_route/Android.bp 2>/dev/null; then
        echo "Applying system/media libaudioroute-v34 patch..."
        git -C system/media apply -v --whitespace=nowarn "$DEVICE_PATH/patches/0002-system-media-add-libaudioroute-v34.patch"
    fi
fi

# Ensure UAPI_HEADER_TEST is disabled in peridot_GKI.config
PERIDOT_GKI_CONFIG="kernel/xiaomi/sm8635/arch/arm64/configs/vendor/peridot_GKI.config"
if [ -f "$PERIDOT_GKI_CONFIG" ]; then
    if ! grep -q "CONFIG_UAPI_HEADER_TEST" "$PERIDOT_GKI_CONFIG"; then
        echo "Disabling CONFIG_UAPI_HEADER_TEST in $PERIDOT_GKI_CONFIG..."
        echo -e "\n# Disable UAPI header test\n# CONFIG_UAPI_HEADER_TEST is not set" >> "$PERIDOT_GKI_CONFIG"
    fi
fi
