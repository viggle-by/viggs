#!/bin/bash
set -e

echo "---- Installing KDE Plasma 6 and VNC/noVNC in Codespaces ----"

# 1. Update and install kde, VNC, noVNC, and utilities
sudo apt update
sudo apt install -y plasma-desktop kde-standard \
    tigervnc-standalone-server novnc websockify \
    python3-websockify x11-utils

# 2. Setup VNC initial password
mkdir -p ~/.vnc
echo "vncpassword" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd

# 3. Create VNC xstartup to launch KDE Plasma session
cat > ~/.vnc/xstartup << 'EOF'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec startplasma-x11 &
EOF
chmod +x ~/.vnc/xstartup

# 4. Generate a self-signed certificate for secure noVNC over HTTPS
mkdir -p ~/.vnc
openssl req -x509 -nodes -newkey rsa:3072 \
    -keyout ~/.vnc/novnc.pem -out ~/.vnc/novnc.pem \
    -days 365 -subj "/CN=localhost"

# 5. Start VNC server (e.g. display :1, 1280×720)
vncserver :1 -geometry 1280x720 -depth 24

# 6. Launch noVNC using websockify
NOVNC_PORT=6080
VNC_DISPLAY=5901
websockify --web=/usr/share/novnc/ $NOVNC_PORT localhost:$VNC_DISPLAY &

echo "KDE Plasma VNC running!"
echo "• VNC display is on :1 (port $VNC_DISPLAY)"
echo "• noVNC web UI is on port $NOVNC_PORT"
echo
echo "In Codespaces, forward the noVNC port (${NOVNC_PORT}), then open the forwarded URL in your browser."