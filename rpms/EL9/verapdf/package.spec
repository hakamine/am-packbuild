Name:     verapdf
Version:  %{version}
Release:  1%{?dist}
Summary:  VeraPDF validation tool
License:  GPLv3

BuildRequires: unzip, wget
Requires: java-1.8.0-openjdk-headless

%description
VeraPDF validation tool

%prep
# download veraPDF installer
wget -q http://downloads.verapdf.org/rel/verapdf-installer.zip
# configure installation path for unattended installation
sed -i 's#INSTALL_PATH#/rpmbuild/BUILD/%{name}#g' auto-install.xml
# extract
unzip verapdf-installer.zip
# run the veraPDF installer using autoinstall configuration
java -jar verapdf-greenfield-%{version}/verapdf-izpack-installer-%{version}.jar auto-install.xml

%build
# no need to build anything, veraPDF comes precompiled

%install
mkdir -p %{buildroot}/usr/local/verapdf/
cp -r /rpmbuild/BUILD/verapdf/* %{buildroot}/usr/local/verapdf

%files
# DOC: http://ftp.rpm.org/max-rpm/s1-rpm-inside-files-list-directives.html
/usr/local/verapdf/

%license
