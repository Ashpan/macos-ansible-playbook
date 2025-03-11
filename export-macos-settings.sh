#!/bin/bash
# Script to export current macOS settings to a YAML file for Ansible

OUTPUT_DIR="./roles/macos/vars"
SETTINGS_FILE="${OUTPUT_DIR}/exported_settings.yml"

# Create output directory if it doesn't exist
mkdir -p "${OUTPUT_DIR}"

# Header for the file
echo "---" > "${SETTINGS_FILE}"
echo "# macOS Settings exported on $(date)" >> "${SETTINGS_FILE}"
echo "# These settings were exported from $(hostname)" >> "${SETTINGS_FILE}"
echo "" >> "${SETTINGS_FILE}"
echo "macos_settings:" >> "${SETTINGS_FILE}"

# Function to read a default and append to output file
get_setting() {
  local domain=$1
  local key=$2
  local description=$3
  
  # Get the type
  local type_info=$(defaults read-type "${domain}" "${key}" 2>/dev/null)
  if [ $? -ne 0 ]; then
    return
  fi
  
  local type=$(echo "${type_info}" | awk '{print $3}')
  local ansible_type=""
  local value_format=""
  
  # Read the value
  local raw_value=$(defaults read "${domain}" "${key}" 2>/dev/null)
  local value="${raw_value}"
  
  # Map macOS type to the correct format for defaults write
  case "${type}" in
    boolean)
      ansible_type="bool"
      if [ "${raw_value}" == "1" ] || [ "${raw_value}" == "true" ]; then
        value="true"
      else
        value="false"
      fi
      ;;
    float)
      ansible_type="float"
      # Ensure it has a decimal point
      if [[ "${value}" != *"."* ]]; then
        value="${value}.0"
      fi
      ;;
    integer)
      ansible_type="int"
      ;;
    string)
      ansible_type="string"
      # Escape quotes in string values
      value=$(echo "${value}" | sed 's/"/\\"/g')
      # Surround with quotes
      value="\"${value}\""
      ;;
    array|dictionary|data)
      # Complex types - skip for now as they require special handling
      echo "# Skipping complex type ${type} for ${domain} ${key}" >> "${SETTINGS_FILE}"
      return
      ;;
    *)
      # Unknown type - use string as default
      ansible_type="string"
      value="\"${value}\""
      ;;
  esac
  
  # Add the setting to the YAML file
  echo "  # ${description}" >> "${SETTINGS_FILE}"
  echo "  - domain: \"${domain}\"" >> "${SETTINGS_FILE}"
  echo "    key: \"${key}\"" >> "${SETTINGS_FILE}"
  echo "    type: \"${ansible_type}\"" >> "${SETTINGS_FILE}"
  echo "    value: ${value}" >> "${SETTINGS_FILE}"
  echo "" >> "${SETTINGS_FILE}"
}

echo "Exporting Finder settings..."
get_setting "com.apple.finder" "ShowPathbar" "Show path bar in Finder"
get_setting "com.apple.finder" "ShowStatusBar" "Show status bar in Finder"
get_setting "com.apple.finder" "FXDefaultSearchScope" "Default search scope"
get_setting "com.apple.finder" "NewWindowTarget" "New window target"
get_setting "com.apple.finder" "NewWindowTargetPath" "New window target path"
get_setting "NSGlobalDomain" "AppleShowAllExtensions" "Show all file extensions"

echo "Exporting Dock settings..."
get_setting "com.apple.dock" "tilesize" "Dock icon size"
get_setting "com.apple.dock" "magnification" "Dock magnification enabled"
get_setting "com.apple.dock" "largesize" "Dock magnification size"
get_setting "com.apple.dock" "autohide" "Auto-hide dock"
get_setting "com.apple.dock" "autohide-delay" "Auto-hide delay"
get_setting "com.apple.dock" "autohide-time-modifier" "Auto-hide animation time"
get_setting "com.apple.dock" "orientation" "Dock orientation"
get_setting "com.apple.dock" "mineffect" "Minimize effect"

echo "Exporting keyboard settings..."
get_setting "NSGlobalDomain" "KeyRepeat" "Key repeat rate"
get_setting "NSGlobalDomain" "InitialKeyRepeat" "Delay until key repeat"
get_setting "NSGlobalDomain" "NSAutomaticSpellingCorrectionEnabled" "Auto-correct enabled"
get_setting "NSGlobalDomain" "NSAutomaticCapitalizationEnabled" "Auto-capitalization enabled"
get_setting "NSGlobalDomain" "NSAutomaticPeriodSubstitutionEnabled" "Period substitution enabled"
get_setting "NSGlobalDomain" "NSAutomaticDashSubstitutionEnabled" "Dash substitution enabled"
get_setting "NSGlobalDomain" "NSAutomaticQuoteSubstitutionEnabled" "Quote substitution enabled"

echo "Exporting trackpad settings..."
get_setting "com.apple.driver.AppleBluetoothMultitouch.trackpad" "Clicking" "Tap to click"
get_setting "com.apple.AppleMultitouchTrackpad" "Clicking" "Tap to click (alternative)"
get_setting "com.apple.driver.AppleBluetoothMultitouch.trackpad" "TrackpadThreeFingerDrag" "Three finger drag"
get_setting "com.apple.driver.AppleBluetoothMultitouch.trackpad" "TrackpadRightClick" "Two-finger right click"

echo "Exporting screenshot settings..."
get_setting "com.apple.screencapture" "location" "Screenshot save location"
get_setting "com.apple.screencapture" "type" "Screenshot file format"
get_setting "com.apple.screencapture" "disable-shadow" "Disable window shadow in screenshots"

echo "Exporting other settings..."
get_setting "NSGlobalDomain" "AppleLanguages" "System languages"
get_setting "NSGlobalDomain" "AppleLocale" "System locale"
get_setting "NSGlobalDomain" "AppleMeasurementUnits" "Measurement units"
get_setting "NSGlobalDomain" "AppleMetricUnits" "Use metric units"
get_setting "NSGlobalDomain" "AppleTemperatureUnit" "Temperature unit"
get_setting "com.apple.menuextra.clock" "DateFormat" "Menu bar clock format"

echo ""
echo "Settings exported to ${SETTINGS_FILE}"
echo ""
echo "To apply these settings on another computer:"
echo "1. Copy the exported_settings.yml file to the roles/macos/vars/ directory on the target computer"
echo "2. Run the Ansible playbook with the macos tag: ansible-playbook -i inventory.yml playbook.yml --tags macos"