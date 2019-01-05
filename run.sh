xhost +;
docker run -t -i -v /var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket  -v /tmp/.X11-unix:/tmp/.X11-unix -v /data/workspaces/git:/git -v /dev/shm:/dev/shm -e DISPLAY=unix$DISPLAY -v /dev/snd:/dev/snd --device /dev/dri --name java-eclipse-maven java-eclipse-maven 
