# Colemak-DH .kbd files for Kanata

[Colemak-DH](https://colemakmods.github.io/mod-dh/) ANSI layout with [Extend](https://dreymar.colemak.org/layers-extend.html) and [Symbols layer](https://colemakmods.github.io/ergonomic-mods/symbols.html) `.kbd` configuration files for [Kanata](https://github.com/jtroo/kanata).

Based directly on the [Colemak Mod-DH Kanata template](https://github.com/ColemakMods/mod-dh/blob/master/kanata/colemak-dh-ansi.kbd). Inspired by [DreymaR's EPKL](https://github.com/DreymaR/BigBagKbdTrixPKL).

## Linux

_Tested on Fedora Linux 45 (KDE Plasma Desktop Edition)._

Run the setup script to download the latest Kanata binary and `linux.kbd` and enable instantly and on every login:

```sh
curl -fsSL https://raw.githubusercontent.com/OpaliteArchitect/kanata-colemak-dh/main/setup-linux.sh | sh
```

_(Note: You may need to log out and back in once for the new `input` and `uinput` group memberships to take effect.)_

## Windows

1. Download the latest Windows release (`windows-binaries-x64.zip` or `windows-binaries-arm64.zip`) from [Kanata Releases](https://github.com/jtroo/kanata/releases/latest) and extract it to a folder.
2. Download [`windows.kbd`](https://github.com/OpaliteArchitect/kanata-colemak-dh/blob/main/windows.kbd) from this repository, rename it to `kanata.kbd`, and place it in the same folder as the Kanata executable.
3. Run `kanata_windows_gui_winIOv2_x64.exe`.

_Feel free to use, modify, distribute, or incorporate these files with no restrictions._
