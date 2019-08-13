# -- Compile dfu-util script

dfu_util=dfu-util
commit=0c621882e4fd73cda323e739c6a48b3ddcbcb8ad
git_dfu_util=https://git.code.sf.net/p/dfu-util/dfu-util

# -- Setup
. $WORK_DIR/scripts/build_setup.sh

cd $UPSTREAM_DIR

# -- Clone the sources from github
test -e $dfu_util || git clone $git_dfu_util $dfu_util
git -C $dfu_util pull
git -C $dfu_util checkout $commit
git -C $dfu_util log -1

# -- Copy the upstream sources into the build directory
rsync -a $dfu_util $BUILD_DIR --exclude .git

cd $BUILD_DIR/$dfu_util

# -- Compile it
./autogen.sh
if [ $ARCH == "darwin" ]; then
    ./configure --libdir=/opt/local/lib --includedir=/opt/local/include
    cd src
    $CC -g -O2 -I$WORK_DIR/build-data/include/libusb-1.0 \
        -o dfu-util$EXE \
        main.c dfu_load.c dfu_util.c dfuse.c dfuse_mem.c dfu.c dfu_file.c quirks.c \
        -static -lpthread $(pkg-config --cflags --libs --static /usr/local/Cellar/libusb/*/lib/pkgconfig/libusb-1.0.pc) \
        -DHAVE_CONFIG_H=1 -I..
    $CC -o dfu-prefix$EXE prefix.c dfu_file.c -static -DHAVE_NANOSLEEP=1 -DHAVE_CONFIG_H=1 -I..
    $CC -o dfu-suffix$EXE suffix.c dfu_file.c -static -DHAVE_NANOSLEEP=1 -DHAVE_CONFIG_H=1 -I..
    cd ..
else
    ./configure $HOST_FLAGS
    cd src
    $CC -g -O2 -I$WORK_DIR/build-data/include/libusb-1.0 \
        -o dfu-util$EXE \
        main.c dfu_load.c dfu_util.c dfuse.c dfuse_mem.c dfu.c dfu_file.c quirks.c \
        -static $WORK_DIR/build-data/lib/$ARCH/libusb-1.0.a -lpthread \
        -DHAVE_CONFIG_H=1 -DHAVE_NANOSLEEP=1 -I..
    $CC -o dfu-prefix$EXE prefix.c dfu_file.c -static -DHAVE_NANOSLEEP=1 -DHAVE_CONFIG_H=1 -I..
    $CC -o dfu-suffix$EXE suffix.c dfu_file.c -static -DHAVE_NANOSLEEP=1 -DHAVE_CONFIG_H=1 -I..
    cd ..
fi

TOOLS="dfu-util dfu-prefix dfu-suffix"

# -- Test the generated executables
for tool in $TOOLS; do
  test_bin src/$tool$EXE
done

# -- Copy the executables to the bin dir
for tool in $TOOLS; do
  cp src/$tool$EXE $PACKAGE_DIR/$NAME/bin/$tool$EXE
done