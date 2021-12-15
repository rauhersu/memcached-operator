#!/bin/bash
set +e

COLOR_CYAN="\033[0;36m"
COLOR_RESET="\033[0m"

# dlvCmd="dlv --listen=:40000 --headless=true --api-version=2 --accept-multiclient exec bin/manager"
dlvCmd="dlv debug --listen=:40000 --headless=true --api-version=2 --accept-multiclient -- --leader-elect --metrics-bind-address=127.0.0.1:8080"

echo -e "${COLOR_CYAN}
   ____              ____
  |  _ \  _____   __/ ___| _ __   __ _  ___ ___
  | | | |/ _ \ \ / /\___ \| '_ \ / _\` |/ __/ _ \\
  | |_| |  __/\ V /  ___) | |_) | (_| | (_|  __/
  |____/ \___| \_/  |____/| .__/ \__,_|\___\___|
                          |_|
${COLOR_RESET}

Initiating debugging: $dlvCmd

"
$dlvCmd
