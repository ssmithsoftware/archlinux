# https://wiki.archlinux.org/title/Universal_Wayland_Session_Manager
# https://wiki.hypr.land/Useful-Utilities/Systemd-start/

if uwsm check may-start; then
    exec uwsm start hyprland-uwsm.desktop
fi
