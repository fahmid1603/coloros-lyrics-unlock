#!/system/bin/sh
# put back the stock media-controller list once the system is up
MODDIR=${0%/*}
cp "$MODDIR/common.sh" /data/local/tmp/.cou_common.sh 2>/dev/null
( MODDIR=/data/local/tmp; . /data/local/tmp/.cou_common.sh; LOG=/data/local/tmp/coloros_lyrics_unlock_uninstall.log
  wait_boot; restore_stock; rm -f /data/local/tmp/.cou_common.sh ) &
