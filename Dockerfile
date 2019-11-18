FROM ubuntu:bionic

# hints related to apt and multiple architectures:
# https://stackoverflow.com/questions/37706635/in-docker-apt-get-install-fails-with-failed-to-fetch-http-archive-ubuntu-com
# https://wiki.ubuntuusers.de/sources.list/
# https://wiki.debian.org/QemuUserEmulation
# https://wiki.debian.org/Multiarch/HOWTO

RUN mv /etc/apt/sources.list /etc/apt/sources.list.old

RUN printf \
"deb [arch=amd64,i386] http://de.archive.ubuntu.com/ubuntu bionic main restricted universe multiverse\n\
deb [arch=amd64,i386] http://de.archive.ubuntu.com/ubuntu bionic-updates main restricted universe multiverse\n\
deb [arch=amd64,i386] http://de.archive.ubuntu.com/ubuntu bionic-security main restricted universe multiverse\n\
deb [arch=amd64,i386] http://de.archive.ubuntu.com/ubuntu bionic-backports main restricted universe multiverse\n\
deb [arch=armhf] http://ports.ubuntu.com/ubuntu-ports/ bionic main universe restricted multiverse\n\
deb [arch=armhf] http://ports.ubuntu.com/ubuntu-ports/ bionic-security main universe restricted multiverse\n\
deb [arch=armhf] http://ports.ubuntu.com/ubuntu-ports/ bionic-updates main universe restricted multiverse\n\
deb [arch=armhf] http://ports.ubuntu.com/ubuntu-ports/ bionic-backports main universe restricted multiverse\n"\
> /etc/apt/sources.list


RUN dpkg --add-architecture i386 && dpkg --add-architecture armhf && apt-get update

RUN apt-get -y install build-essential  gcc-multilib mingw-w64 wine64 wine32 qemu binfmt-support qemu-user-static 
RUN apt-get -y install crossbuild-essential-armhf libc6:armhf

#RUN mkdir -p /raspbian wget -O /raspbian/raspian.zip wget https://downloads.raspberrypi.org/raspbian_lite_latest && unzip /raspbian/raspbian.zip
#RUN losetup -f -P --show 2019-07-10-raspbian-buster-lite.img > loopdev.txt  &&  mkdir -p /rpi_mnt && mount "$(cat loopdev.txt)p2" -o rw /rpi_mnt && cp /usr/bin/qemu-arm-static /rpi_mnt/usr/bin
#RUN WINEPREFIX=/wine32 WINEARCH=win32 winecfg 
#RUN WINEPREFIX=/wine64 WINEARCH=win64 winecfg
