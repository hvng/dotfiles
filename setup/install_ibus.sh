#!/bin/bash

if [[ `lsb_release -is` == "Arch" ]]; then
    sudo pacman -Syu adobe-source-han-sans-jp-fonts otf-ipafont --noconfirm
    yay -Syu ttf-monapo --noconfirm
    sudo pacman -Syu ibus ibus-anthy --noconfirm
    yay -Syu ibus-bamboo --noconfirm

elif [[ `lsb_release -is` == "Ubuntu" ]]; then
    # ibus-anthy is not packaged on 24.04, use mozc
    sudo apt-get install software-properties-common -y
    sudo add-apt-repository -y ppa:bamboo-engine/ibus-bamboo
    sudo apt-get update -y
    sudo apt-get install ibus ibus-bamboo ibus-mozc fonts-noto-cjk fonts-ipafont -y
    ibus restart || ibus-daemon -drx

    if command -v gsettings >/dev/null && [[ -n $DBUS_SESSION_BUS_ADDRESS ]]; then
        env DCONF_PROFILE=ibus dconf write /desktop/ibus/general/preload-engines "['BambooUs', 'Bamboo', 'mozc-jp']"
        sources=$(python3 - "$(gsettings get org.gnome.desktop.input-sources sources)" <<'PY'
import ast, sys
raw = sys.argv[1]
sources = [] if raw.startswith("@") else ast.literal_eval(raw)
for entry in [("xkb", "us"), ("ibus", "Bamboo"), ("ibus", "mozc-jp")]:
    if entry not in sources:
        sources.append(entry)
print(sources)
PY
)
        gsettings set org.gnome.desktop.input-sources sources "$sources"
    else
        echo "No desktop session, add Bamboo and Mozc in Settings > Keyboard manually."
    fi
    echo "Log out and back in to load the new input sources."

else
    echo "Only Arch and Ubuntu are supported, please install IBus Bamboo and a Japanese input method manually."
fi
