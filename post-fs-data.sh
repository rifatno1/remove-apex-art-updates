#!/system/bin/sh
MOD_DIR=${0%/*}
APEX_DIR="/data/apex/active"
PROP_FILE="$MOD_DIR/module.prop"

update_description() {
	escaped=$(printf '%s' "$1" | sed 's/[\\&|]/\\&/g')
	sed -i "s|^description=.*|description=${escaped}|" "$PROP_FILE"
}

get_description() {
	sed -n 's|^description=||p' "$PROP_FILE" | head -n 1
}

# get the current description from module.prop
description=$(get_description)

# if already triggered, removed the "Triggered | " prefix from description and stop execution
if [ -z "${description##Triggered | *}" ]; then
	update_description "${description#Triggered | }"
	exit 0
fi

triggered=0

# rename the apex files
for APEXFILE in "$APEX_DIR"/com.android.art*.apex; do
	[ -e "$APEXFILE" ] || continue
	mv -f "$APEXFILE" "${APEXFILE%.apex}.bak"
	triggered=1
done

# add "Triggered | " prefix to the description and trigger a reboot if any apex files were renamed
if [ "$triggered" = "1" ]; then
	update_description "Triggered | $description"
	sync
	/system/bin/reboot
fi
