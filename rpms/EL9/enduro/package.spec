%define _builddir ./
%define build_timestamp %(date +"%Y%m%d%H%M")

Name: enduro
Version: %{version}
Release: %{release}
Summary: Enduro is a tool to aid automation of Archivematica
URL: https://github.com/artefactual-labs/enduro
Group: Application/SystemTools
License: Apache License, Version 2.0

BuildRequires: systemd-rpm-macros
BuildRequires: which

%description
A tool to aid automation of Archivematica and surrounding workflows

%build
make ui
make build


%install
rm -rf $RPM_BUILD_ROOT
install -m 0755 -d $RPM_BUILD_ROOT/usr/bin/
install -m 0755 -d $RPM_BUILD_ROOT/etc/systemd/system/
install -m 0755 build/enduro $RPM_BUILD_ROOT/usr/bin/enduro
install -m 0644 enduro.toml $RPM_BUILD_ROOT/etc/enduro.toml
install -m 0644 enduro.service $RPM_BUILD_ROOT/etc/systemd/system/enduro.service

%clean
rm -rf $RPM_BUILD_ROOT

%files
/usr/bin/enduro
%config(noreplace) /etc/enduro.toml
%config(noreplace) /etc/systemd/system/enduro.service


%post

# Create enduro user and group
getent group enduro >/dev/null || groupadd -f -g 444 -r enduro
if ! getent passwd enduro >/dev/null ; then
  if ! getent passwd 444 >/dev/null ; then
    useradd -r -u 444 -g enduro -d /var/lib/enduro/ -s /sbin/nologin -c "Enduro system account" -m enduro
    else
    useradd -r -g enduro -d /var/lib/enduro/ -s /sbin/nologin -c "Enduro system account" -m enduro
  fi
fi

systemctl daemon-reload
