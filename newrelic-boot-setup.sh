#!/bin/sh

echo "[INFO] This is $0"

if [ -z $NEW_RELIC_KEY ]; then
  echo "[WARN] No NEW_RELIC_KEY was provided. No telemetry will be sent"
  exit 0
fi

if [ $NEW_RELIC_APP_NAME ]; then
  echo "[INFO] Given app name defined at NEW_RELIC_APP_NAME=${NEW_RELIC_APP_NAME}"
else
  echo "[WARN] You can define the app name using the env var NEW_RELIC_APP_NAME"
  NEW_RELIC_APP_NAME=$(hostname | sed 's/-[a-zA-Z0-9]*-[a-zA-Z0-9]*$//')
  echo "[WARN] No app name defined: assuming ${NEW_RELIC_APP_NAME}"
fi

echo "[INFO] Configuring NewRelic for $NEW_RELIC_APP_NAME"
NR_INSTALL_SILENT=true NR_INSTALL_KEY=$NEW_RELIC_KEY newrelic-install install

echo "[INFO] Updating newrelic.appname"
for INI in $(find /etc -name newrelic.ini); do
  echo "[INFO] -> Updating ${INI}"
  sed -i -E "s/^;?newrelic.appname = \".+$/newrelic.appname = \"${NEW_RELIC_APP_NAME}\"/gi" $INI
done

for INI in $(find /usr -name newrelic.ini); do
  echo "[INFO] -> Updating ${INI}"
  sed -i -E "s/^;?newrelic.appname = \".+$/newrelic.appname = \"${NEW_RELIC_APP_NAME}\"/gi" $INI
done

echo "[INFO] NewRelic setup is done."