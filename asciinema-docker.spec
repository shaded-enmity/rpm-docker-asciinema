Name:		asciinema-docker
Version:	0.1
Release:	1%{?dist}_git526abc0
Summary:	Record and share your terminal sessions, the right way.

Group:		docker-rpm
License:	GPLv3+, AGPLv3, 3-BSD, PostgreSQL Licence
URL:		https://asciinema.org/
Source0:	context.tar

BuildRequires:	docker-io%{?_isa}
Requires:	docker-io%{?_isa}

%define _statedir   %{_sharedstatedir}/%{name}

%description
Asciinema, Redis, PostgreSQL - containerized, interlinked and delivered
for your immediate consumption with zero-configuration.

%prep
%setup -c

%build
source ./container-names.env
docker build -t ${ASCIINEMA_REDS} redis/build-context/
docker build -t ${ASCIINEMA_PSQL} postgres/build-context/
docker build -t ${ASCIINEMA_CORE} core/build-context/

%install
source ./container-names.env
docker save --output='redis.tar' ${ASCIINEMA_REDS}
docker save --output='postgres.tar' ${ASCIINEMA_PSQL}
docker save --output='core.tar' ${ASCIINEMA_CORE}

mkdir -p %{buildroot}/%{_statedir}/{pgsql,uploads,redis}
mkdir -p %{buildroot}/%{_sbindir}/
mkdir -p %{buildroot}/usr/lib/systemd/system/

install -m 0644 -t %{buildroot}/%{_statedir}/ *.tar
install -m 0644 redis/env.list %{buildroot}/%{_statedir}/redis-env.list
install -m 0644 postgres/env.list %{buildroot}/%{_statedir}/postgres-env.list
install -m 0644 container-names.env %{buildroot}/%{_statedir}/container-names.env
install -m 0744 asciinema-bootstrap.sh %{buildroot}/%{_sbindir}/
install -m 0644 systemd/* %{buildroot}/usr/lib/systemd/system/

%clean
rm -rf $RPM_BUILD_ROOT

%pre
mkdir -p %{_statedir}/{pgsql,uploads,redis}
chcon -t svirt_sandbox_file_t %{_statedir}/{pgsql,uploads,redis}
echo "  Loading images into Docker"

%post
for image in %{_statedir}/*.tar; do
  docker load --input="${image}"
  _image_name=$(basename ${image})
  echo "  Image ${_image_name} loaded!"
  rm -f ${image} && touch ${image}
done

%preun
source %{_statedir}/container-names.env
_name_list="${ASCIINEMA_CORE} ${ASCIINEMA_SDKQ} ${ASCIINEMA_PSQL} ${ASCIINEMA_REDS}"
docker kill ${_name_list} >/dev/null 2>&1
docker rmi -f ${_name_list} >/dev/null 2>&1
echo "  Image ${_name_list} removed!"

%files
%{_statedir}/*.tar
%{_statedir}/*.list
%{_statedir}/container-names.env
%{_sbindir}/asciinema-bootstrap.sh
/usr/lib/systemd/system/asciinema*.service

%doc



%changelog
* Wed Jan 21 2015 Pavel Odvody <podvody@redhat.com> - 0.1.0-1:git.527abc0
- Initial packaging effort
