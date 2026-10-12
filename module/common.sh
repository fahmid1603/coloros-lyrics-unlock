# shared by service.sh / action.sh / uninstall.sh
MODDIR=${MODDIR:-${0%/*}}
U=content://com.oplus.romupdate.provider.db/update_list
F=app_systemui_oplus_media_controller_config
A=assets/$F.xml
STATE=$MODDIR/state
LOG=$MODDIR/log.txt
log() { echo "$(date '+%m-%d %H:%M:%S') $*" >> "$LOG"; }
bb() {
  for b in /data/adb/ksu/bin/busybox /data/adb/ap/bin/busybox /data/adb/magisk/busybox; do
    [ -x "$b" ] && { "$b" "$@"; return; }
  done
  "$@"
}
wait_boot() { until [ "$(getprop sys.boot_completed)" = 1 ]; do sleep 2; done; sleep 3; }
# version must beat the asset (17xx / port asset 18000000xx) AND the last applied one -> grows with time
new_version() { echo $(( 1800000000 + ($(date -u +%s) - 1767225600) / 60 )); }
stock_xml() { # $1 = out file
  local apk; apk=$(pm path com.android.systemui | head -1 | sed 's/^package://')
  [ -f "$apk" ] || { log "SystemUI apk not found"; return 1; }
  bb unzip -p "$apk" "$A" > "$1" 2>/dev/null
  grep -q '</policy>' "$1" || { log "no $A in $apk (not ColorOS/OxygenOS?)"; return 1; }
}
players() { sed -e 's/#.*//' "$MODDIR/players.txt" | tr -s ' \t\r' '\n' | grep -E '^[A-Za-z0-9_.]+$'; }
patch_xml() { # $1 in, $2 out, $3 version  (adds players, lyricEntrance=52, never lyricEnable)
  players > "$MODDIR/.pk"
  awk -v ver="$3" -v pkf="$MODDIR/.pk" '
    BEGIN { while ((getline p < pkf) > 0) pk[++n] = p }
    { buf[++L] = $0 }
    END {
      for (i = 1; i <= L; i++) {
        s = buf[i]
        if (s ~ /<whitelist>/) sec = "w"; else if (s ~ /<policy>/) sec = "p"; else if (s ~ /<excludeList>/) sec = "x"
        for (k = 1; k <= n; k++) if (index(s, "name=\"" pk[k] "\"")) seen[sec, pk[k]] = 1
      }
      for (i = 1; i <= L; i++) {
        s = buf[i]
        if (s ~ /<version>[0-9]+<\/version>/) sub(/<version>[0-9]+<\/version>/, "<version>" ver "</version>", s)
        if (s ~ /^[ \t]*<\/whitelist>/) for (k = 1; k <= n; k++) if (!seen["w", pk[k]] && !seen["x", pk[k]])
          print "        <packageName name=\"" pk[k] "\"/>"
        if (s ~ /^[ \t]*<\/policy>/) for (k = 1; k <= n; k++) if (!seen["p", pk[k]] && !seen["x", pk[k]])
          print "        <packageName name=\"" pk[k] "\" actionPriority=\"0\" actionPriorityQs=\"2\" lyricEntrance=\"52\"/>"
        print s
      }
    }' "$1" | sed 's/:/\&#58;/g' > "$2"   # `content --bind` rejects ":" in values; XML parser decodes &#58;
}
put_row() { # $1 xml file, $2 version
  content delete --uri $U --where "filterName='$F'" >/dev/null 2>&1
  content insert --uri $U --bind filterName:s:$F --bind version:s:$2 --bind isOpen:i:1 --bind xml:s:"$(cat "$1")"
  content query --uri $U --projection version --where "filterName='$F'" | grep -q "version=$2" || { log "insert failed"; return 1; }
  am broadcast -a oplus.intent.action.ROM_UPDATE_CONFIG_SUCCESS --esal ROM_UPDATE_CONFIG_LIST $F >/dev/null 2>&1
  log "applied version $2"
}
# announce the unlock to players (debug.* is readable by every SELinux domain): value = applied version
PROP=debug.coloros.lyrics_unlock
set_flag() {
  local rp; for rp in /data/adb/ksu/bin/resetprop /data/adb/ap/bin/resetprop "$(command -v resetprop)"; do
    [ -x "$rp" ] && { if [ -n "$1" ]; then "$rp" -n $PROP "$1"; else "$rp" --delete $PROP; fi; return; }
  done
  setprop $PROP "$1"
}
have_provider() { pm path com.oplus.romupdate >/dev/null 2>&1 || { log "com.oplus.romupdate missing/disabled - nothing to do"; return 1; }; }
apply() { # $1 = force
  have_provider || return 1
  local t="$MODDIR/.tmp" key cur v
  stock_xml "$t.stock" || return 1
  key=$( (cat "$MODDIR/players.txt"; md5sum "$t.stock") | md5sum | cut -d' ' -f1)
  cur=$(content query --uri $U --projection version --where "filterName='$F'" 2>/dev/null | sed -n 's/.*version=\([0-9]*\).*/\1/p' | head -1)
  if [ "$1" != force ] && [ -f "$STATE" ] && [ "$(sed -n 1p "$STATE")" = "$key" ] && [ "$cur" = "$(sed -n 2p "$STATE")" ]; then
    log "up to date (version $cur)"; set_flag "$cur"; return 0
  fi
  v=$(new_version)
  patch_xml "$t.stock" "$t.xml" "$v"
  put_row "$t.xml" "$v" && printf '%s\n%s\n' "$key" "$v" > "$STATE" && set_flag "$v"
  rm -f "$t.stock" "$t.xml" "$MODDIR/.pk"
}
restore_stock() {
  have_provider || return 1
  local t="$MODDIR/.tmp" v
  stock_xml "$t.stock" || return 1
  v=$(new_version)
  sed -E "s:<version>[0-9]+</version>:<version>$v</version>:; s/:/\&#58;/g" "$t.stock" > "$t.xml"
  put_row "$t.xml" "$v" && log "stock list restored"; set_flag ""
  rm -f "$t.stock" "$t.xml" "$STATE"
}
