# -- Compile Icoprog script for RPI

ICOTOOLS=icotools
COMMIT=3f62cd560f57899f61c830215f0496655cae5217
GIT_ICOTOOLS=https://github.com/cliffordwolf/icotools.git

J=$(($(nproc)-1))

## Icoprog

cd $UPSTREAM_DIR

# -- Clone the sources from github
test -e $ICOTOOLS || git clone $GIT_ICOTOOLS $ICOTOOLS
git -C $ICOTOOLS pull
git -C $ICOTOOLS checkout $COMMIT
git -C $ICOTOOLS log -1

# -- Copy the upstream sources into the build directory
rsync -a $ICOTOOLS $BUILD_DIR --exclude .git

cd $BUILD_DIR/$ICOTOOLS

# -- Compile it
arm-linux-gnueabihf-gcc -o icoprog/icoprog -Wall -Os icoprog/icoprog.cc -D GPIOMODE -static -lrt -lstdc++

# -- Test the generated executables
test_bin icoprog/icoprog

# -- Copy the executables to the bin dir
cp icoprog/icoprog $PACKAGE_DIR/$NAME/bin
