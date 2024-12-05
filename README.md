# Build packages

You need Docker installed and running.

Rocky Linux 9 packages:

    make -C rpms/EL9

This also builds a local repository that you can use later from `rpms/EL9-testing`.

Ubuntu 22.04 Jammy packages:

    make -C debs/jammy

## Using parameters

Most makefiles support parameters in the form of environment variables. They
may be a bit different between packages, but the most common are `BRANCH`,
`VERSION` and `RELEASE`.

So in order to build a specific branch or version, this command can be used from
the folder of the package we want to build:

    make BRANCH=qa/1.x VERSION=1.17.0 RELEASE=rc5

Keep in mind that the makefiles are a bit recursive, they will invoke Docker,
mount the current folder, and run the deb-build target.

## Development

Some makefiles have a `dev` target, that give you a shell inside of the Docker
container used to build packages. When you are inside the container, the command
needed to build the packages is:

    make deb-build

## Repositories management

This repo generates Archivematica packages, but also packages that need to be
installed in order for Archivematica to run. They are placed in the
ubuntu-externals, rocky8-extras or rocky9-extras repos.

In order to add a package to a repo, once it's built and uploaded to a temporary
folder at <https://packages.archivematica.org>, the steps are:

For Rocky Linux/RedHat packages:

- Copy the rpm into rocky8-extras or rocky9-extras repo
- Run `createrepo`
- Run `gpg --detach-sign --armor repodata/repomd.xml` to sign the
repository contents

For Ubuntu packages:

- Upload the package to packages.archivematica.org
- Go to the repository folder
( mnt/st-sites-pub/packages.archivematica.org/1.7.x/ubuntu-externals )
- Add the packages with

        reprepro includedeb trusty /path/to/packages/*.deb
        reprepro includedsc trusty /path/to/packages/*.deb

This needs to be repeated for each Ubuntu release and package. More info about
managing Ubuntu repositories using reprepro can be found
[here](https://wiki.archivematica.org/Release_Process#Build_deb.2Frpm_packages).

## Test package

See the [tests/archivematica](tests/archivematica) directory for more details.
