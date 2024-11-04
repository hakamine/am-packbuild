Name: %{name}
Version: %{version}
Release: 1%{?dist}
Summary: JSTOR/Harvard Object Validation Environment
Buildrequires: maven, gcc
Source: https://github.com/openpreserve/jhove/archive/%{version}.zip
License: LGPL


%description
JHOVE (the JSTOR/Harvard Object Validation Environment, pronounced "jhove") is an extensible software framework for performing format identification, validation, and characterization of digital objects.


%files
/usr/share/jhove/
/usr/share/doc/jhove/
/usr/bin/jhove
/usr/bin/jhove-gui


%prep
rm -rf %{buildroot}/*
%setup -q


%install
mvn clean install

mkdir -p \
	%{buildroot}/usr/bin/ \
	%{buildroot}/usr/share/doc/jhove/ \
	%{buildroot}/usr/share/jhove/conf

cp %{_sourcedir}/files/jhove %{buildroot}/usr/bin/
cp %{_sourcedir}/files/jhove-gui %{buildroot}/usr/bin/
chmod 755 %{buildroot}/usr/bin/jhove %{buildroot}/usr/bin/jhove-gui

cp -rf jhove-installer/target/staging/config/*  %{buildroot}/usr/share/jhove/conf/
cp -rf jhove-installer/target/staging/bin %{buildroot}/usr/share/jhove/
cp -rf lib %{buildroot}/usr/share/jhove/

cp LICENSE README.md COPYING %{buildroot}/usr/share/doc/jhove/

%changelog
* Mon Nov 4 2024 - sysadmin@artefactual.com
- 1.32.0-1 package: Bump version to 1.32.0
* Mon Sep 25 2023 - sysadmin@artefactual.com
- 1.26.1-2 package: Fix /usr/bin/jhove and /usr/bin/jhove-gui scripts
* Tue Jun 28 2023 - sysadmin@artefactual.com
- 1.26.1-1 package: Bump version to 1.26.1
