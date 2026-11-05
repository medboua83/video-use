#!/usr/bin/env bash
set -euo pipefail

sudo DEBIAN_FRONTEND=noninteractive apt-get -o Acquire::Retries=2 -o Acquire::http::Timeout=20 -o Acquire::https::Timeout=20 install --no-install-recommends -y \
  xfce4 xfce4-terminal tigervnc-standalone-server novnc websockify dbus-x11 x11-xserver-utils fonts-liberation

desktop_state="$HOME/.cache/video-use-desktop"
mkdir -p "$desktop_state/runtime" "$HOME/Desktop" "$HOME/videos"
chmod 700 "$desktop_state/runtime"
export XDG_RUNTIME_DIR="$desktop_state/runtime"
export DISPLAY=:1

if ! pgrep -u "$(id -u)" -f '^Xtigervnc :1 ' >/dev/null; then
  nohup Xtigervnc :1 -geometry 1440x900 -depth 24 -SecurityTypes None -localhost yes \
    -rfbport 5901 -nolisten tcp -desktop 'Ubuntu video-use' \
    > "$desktop_state/vnc.log" 2>&1 < /dev/null &
fi
for attempt in {1..20}; do
  if [ -S /tmp/.X11-unix/X1 ]; then break; fi
  sleep 1
done
if ! pgrep -u "$(id -u)" -x xfce4-session >/dev/null; then
  nohup dbus-run-session -- xfce4-session > "$desktop_state/xfce.log" 2>&1 < /dev/null &
fi

cat > "$HOME/Desktop/video-use-terminal.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Video-use Terminal
Comment=Ouvrir le terminal pour tester video-use
Exec=xfce4-terminal --working-directory=$HOME/videos
Icon=utilities-terminal
Terminal=false
EOF
chmod +x "$HOME/Desktop/video-use-terminal.desktop"

# VNC stays on loopback. Only the browser gateway binds the private VPN IP.
# Access to the desktop is controlled by the tailnet's device identity and ACLs.
desktop_ip=$(tailscale ip -4)
if ! pgrep -u "$(id -u)" -f "websockify.*${desktop_ip}:6080" >/dev/null; then
  nohup /usr/bin/websockify --web /usr/share/novnc/ "${desktop_ip}:6080" 127.0.0.1:5901 \
    > "$desktop_state/web.log" 2>&1 < /dev/null &
fi
for attempt in {1..30}; do
  if curl --fail --silent "http://${desktop_ip}:6080/vnc.html" > /dev/null; then
    printf 'Bureau pret : http://%s:6080/vnc.html?autoconnect=1&resize=remote\n' "$desktop_ip"
    exit 0
  fi
  sleep 1
done
echo 'Le bureau ne repond pas. Consulter ~/.cache/video-use-desktop/*.log' >&2
exit 1
