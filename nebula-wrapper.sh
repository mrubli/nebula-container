#!/bin/sh

set -eu

startup_script="/usr/local/bin/startup.sh"
wrappee="/usr/local/bin/nebula"

if [ -f "$startup_script" ]; then
	if [ ! -x "$startup_script" ]; then
		echo "ERROR: Startup script '$startup_script' not executable."
		exit 1
	fi

	echo "Executing startup script '$startup_script' ..."
	$startup_script
	echo "Startup script finished."
fi

exec "$wrappee" "$@"
