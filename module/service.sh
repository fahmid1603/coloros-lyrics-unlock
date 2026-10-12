#!/system/bin/sh
MODDIR=${0%/*}
. "$MODDIR/common.sh"
( wait_boot; apply ) &
