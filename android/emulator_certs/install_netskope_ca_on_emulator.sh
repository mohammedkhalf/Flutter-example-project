#!/usr/bin/env bash
# Install Tamara Netskope SWG CAs as user certificates on a connected emulator/device.
# Needed so Chrome/WebView can trust corporate SSL inspection outside the app NSC.
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"

adb wait-for-device
adb shell settings put global private_dns_mode off || true
adb shell settings put global captive_portal_mode 0 || true

for cer in \
  CertServiceCA.cer \
  ca.tamara-ksa.goskope.com.cer \
  ns-swg.ca.tamara-ksa.goskope.com.cer
do
  adb push "$DIR/$cer" "/sdcard/Download/$cer"
  echo "Opening installer for $cer — choose 'CA certificate' if prompted."
  adb shell am start -a android.intent.action.VIEW \
    -t application/x-x509-ca-cert \
    -d "file:///sdcard/Download/$cer" || true
  sleep 2
done

echo "Done. In the emulator: Settings → Security → Encryption & credentials → Trusted credentials → User"
echo "should list the Netskope/Tamara CAs after you confirm each install prompt."
