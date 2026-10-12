#!/system/bin/sh
# KernelSU / Magisk "Action" button: re-apply now (after editing players.txt)
MODDIR=${0%/*}
. "$MODDIR/common.sh"
echo "ColorOS Lyrics Unlock - applying $(players | wc -l) players..."
apply force && echo "Done: $(tail -1 "$LOG")" || { echo "Failed:"; tail -3 "$LOG"; }
