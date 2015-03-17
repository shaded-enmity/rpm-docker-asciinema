# rpm-docker-asciinema
A set of 4 Docker containers providing [ASCIInema](https://asciinema.org/) service, delivered as RPM package, orchestrated with systemd.

## Prerequisites

rpmbuild, systemd, docker, dnf/yum

## Build

```bash
$ git clone https://github.com/shaded-enmity/rpm-docker-asciinema
$ ./build.sh
```

Since `build.sh` uses rpmbuild, you can find the final RPM in `~/rpmbuild/RPMS/x86_64/`, if you're lazy and just want to try it out, grab a pre-built one from [my repo](https://podvody.fedorapeople.org/asciinema-docker-0.1-1.fc21_git526abc0.x86_64.rpm)

## Installation

```bash
$ dnf install asciinema-docker-0.1-1.fc21_git526abc0.x86_64.rpm
$ systemctl start asciinema-docker.service
```

The app is published on port 3000, so simply navigate to [http://localhost:3000/](http://localhost:3000/), and enjoy your own ASCIInema instance.

## Information

See how the `RPM/SRPM` dichotomy plays nicely with Docker:

Binary package contains:
 - Docker Images

Source package contains:
 - Dockerfiles

Images are loaded into Docker during the execution of the `%post` scriptlet with `docker load -i IMAGE.TAR`

Also included is a set of `systemd` service files, so you can bring up ASCIInema as a single logical unit. You can even find the container id in each of the service's status such as:

```bash
$ systemctl status asciinema-web
● asciinema-web.service - Rails Server instance for asciinema in Docker
   Loaded: loaded (/usr/lib/systemd/system/asciinema-web.service; disabled)
   Active: active (running) since Tue 2015-03-17 13:40:03 CET; 14min ago
 Main PID: 2939 (asciinema-boots)
   CGroup: /system.slice/asciinema-web.service
           ├─2939 /bin/bash /usr/sbin/asciinema-bootstrap.sh core
           └─3074 docker attach 03f92adb16736b7aa0e4b5de56c68dccfa692b30db4051287344e1b599e95fc2
```


 
