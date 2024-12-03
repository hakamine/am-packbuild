# This scripts downloads packages from external repositories.
# The SHA256SUM needs to be checked *before* packages are signed with our key
# Requires EPEL repo installed


# RPM fusion repo

wget https://download1.rpmfusion.org/free/el/updates/9/x86_64/f/ffmpeg-5.1.6-2.el9.x86_64.rpm
wget https://download1.rpmfusion.org/free/el/updates/9/x86_64/f/ffmpeg-libs-5.1.6-2.el9.x86_64.rpm
wget https://download1.rpmfusion.org/free/el/updates/9/x86_64/x/x264-0.163-6.20210613git5db6aa6.el9.x86_64.rpm
wget https://download1.rpmfusion.org/free/el/updates/9/x86_64/x/x264-libs-0.163-6.20210613git5db6aa6.el9.x86_64.rpm
wget https://download1.rpmfusion.org/free/el/updates/9/x86_64/x/x265-3.5-5.el9.x86_64.rpm
wget https://download1.rpmfusion.org/free/el/updates/9/x86_64/x/x265-libs-3.5-5.el9.x86_64.rpm
wget https://download1.rpmfusion.org/free/el/updates/9/x86_64/g/gpac-libs-2.0.0-1.el9.x86_64.rpm
wget https://download1.rpmfusion.org/free/el/updates/9/x86_64/f/faad2-libs-2.10.1-1.el9.x86_64.rpm
wget https://download1.rpmfusion.org/free/el/updates/9/x86_64/l/libavdevice-5.1.6-2.el9.x86_64.rpm

# CERT Forensics repo

wget https://forensics.cert.org/repository/centos/cert/9/x86_64/bulk_extractor-2.0.3-1.el9.x86_64.rpm
wget https://forensics.cert.org/repository/centos/cert/9/x86_64/libewf-20160718-20140812.1.el9.x86_64.rpm
wget https://forensics.cert.org/repository/centos/cert/9/x86_64/libpst-libs-0.6.76-5.el9.x86_64.rpm
wget https://forensics.cert.org/repository/centos/cert/9/x86_64/libpst-0.6.76-5.el9.x86_64.rpm
wget https://forensics.cert.org/repository/centos/cert/9/x86_64/libvhdi-20221124-1.el9.x86_64.rpm
wget https://forensics.cert.org/repository/centos/cert/9/x86_64/libvmdk-20221124-1.el9.x86_64.rpm
wget https://forensics.cert.org/repository/centos/cert/9/x86_64/mac-robber-1.02-21.el9.x86_64.rpm
wget https://forensics.cert.org/repository/centos/cert/9/x86_64/md5deep-4.4-16.el9.x86_64.rpm
wget https://forensics.cert.org/repository/centos/cert/9/x86_64/sleuthkit-libs-4.12.0-100.el9.x86_64.rpm
wget https://forensics.cert.org/repository/centos/cert/9/x86_64/sleuthkit-4.12.0-100.el9.x86_64.rpm
