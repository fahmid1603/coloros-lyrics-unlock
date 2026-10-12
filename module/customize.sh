SKIPUNZIP=0
ui_print " "
ui_print "  \"And the servants of the Most Merciful are those"
ui_print "   who walk upon the earth easily [humbly], and when"
ui_print "   the ignorant address them [harshly], they say"
ui_print "   [words of] peace.\""
ui_print "                           - Al-Furqan 25:63"
ui_print " "
ui_print "==========================================="
ui_print "   ColorOS Lyrics Unlock by ₚₑdₑₛₜᵣᵢₐₙ"
ui_print "   t.me/pedestrian1603"
ui_print "==========================================="
if ! pm path com.oplus.romupdate >/dev/null 2>&1 && [ -z "$(getprop ro.build.version.oplusrom)" ]; then
  ui_print "! This does not look like ColorOS / OxygenOS."
  ui_print "! The module will do nothing here."
fi
OLD=/data/adb/modules/coloros_lyrics_unlock/players.txt
[ -f "$OLD" ] && { cp -f "$OLD" "$MODPATH/players.txt"; ui_print "- Kept your players.txt"; }
set_perm_recursive "$MODPATH" 0 0 0755 0644
for f in service.sh action.sh uninstall.sh; do set_perm "$MODPATH/$f" 0 0 0755; done
ui_print "- Reboot. Then play music in a listed player,"
ui_print "  lock the screen and tap the lyric icon on the"
ui_print "  full-screen album-art media card."
ui_print "- First time only: after the reboot, start a NEW"
ui_print "  song (or press next) - a song that was already"
ui_print "  playing keeps the old (no-lyric) setting."
ui_print "- Exhale: turn OFF 'Lyrics on the media card'."
ui_print "- Namida: enable 'ColorOS & HyperLyric'."
ui_print "- Edit players.txt in the module folder, then"
ui_print "  press the module Action button."
