# Source environment variables
#	Ensures variables exist for uwsm/hyprland or login shells using ssh/tty
[ -f $HOME/.env ] && . $HOME/.env

# https://wiki.archlinux.org/title/Universal_Wayland_Session_Manager
# https://wiki.hypr.land/Useful-Utilities/Systemd-start/
if uwsm check may-start; then
	exec uwsm start hyprland-uwsm.desktop
fi
