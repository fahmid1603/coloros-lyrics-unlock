# ColorOS Lyrics Unlock

by ₚₑdₑₛₜᵣᵢₐₙ — [t.me/pedestrian1603](https://t.me/pedestrian1603)

Root module (KernelSU / Magisk / APatch) that turns on the **native ColorOS / OxygenOS lock-screen and AOD lyric page** for open-source music players.

## Why
ColorOS SystemUI only draws lyrics for players listed, with a `lyricEntrance`, in its media-controller config (`app_systemui_oplus_media_controller_config`). Out of the box that list holds partner apps only (QQ Music, NetEase, KuGou, HeyTap Music…).

## How
The same config can be updated through the ROM Update Service (`com.oplus.romupdate`). After boot, the module:
1. reads the stock config from your own SystemUI,
2. adds the players in `players.txt` (`lyricEntrance="52"`, never `lyricEnable`),
3. inserts it as a RUS update with a higher version, and broadcasts `ROM_UPDATE_CONFIG_SUCCESS`.

SystemUI itself is **not modified**, so it survives OTAs. Uninstalling puts the stock list back.

## Requirements
- ColorOS / OxygenOS 16 or newer, rooted.
- A player that publishes OPlus `lyricInfo` metadata:
  - **Exhale**: turn **off** "Lyrics on the media card".
  - **Namida**: turn on "ColorOS & HyperLyric".
  - Others in `players.txt` are listed for future support.

## Use
- Flash, reboot, play a **new** song, lock the screen, tap the lyric icon on the full-screen album-art card.
- Edit `/data/adb/modules/coloros_lyrics_unlock/players.txt`, then press the module **Action** button (or reboot).
- Log: `/data/adb/modules/coloros_lyrics_unlock/log.txt`.

## Notes
- `lyricEnable="1"` does **not** enable lyrics: SystemUI then demands `oplus.media.config=1` in the player's metadata.
- SystemUI re-applies a RUS config only when its version is higher than the last applied one, so the module uses `1800000000 + minutes since 2026`.
