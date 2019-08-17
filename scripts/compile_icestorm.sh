# -- Compile Icestorm script

ICESTORM=icestorm
COMMIT=cfac9f950412ae139fa3c085c21881cbaf24822f
GIT_ICESTORM=https://github.com/cliffordwolf/icestorm.git

# -- Setup
. $WORK_DIR/scripts/build_setup.sh

cd $UPSTREAM_DIR

# -- Clone the sources from github
test -e $ICESTORM || git clone $GIT_ICESTORM $ICESTORM
git -C $ICESTORM pull
git -C $ICESTORM checkout $COMMIT
git -C $ICESTORM log -1

# -- Copy the upstream sources into the build directory
rsync -a $ICESTORM $BUILD_DIR --exclude .git

cd $BUILD_DIR/$ICESTORM

# -- Compile it
if [ $ARCH == "darwin" ]; then
  gsed -i "s/-ggdb //;" config.mk
  make -j$J CXX="$CXX" \
            CXXFLAGS="-I/tmp/conda/include" LDFLAGS="-:/tmp/conda/lib" \
            SUBDIRS="icebox icepack icemulti icepll icetime icebram"
else
  sed -i "s/-ggdb //;" config.mk
  make -j$J CXX="$CXX" STATIC=1 \
            SUBDIRS="icebox icepack icemulti icepll icetime icebram"
fi

TOOLS="icepack icemulti icepll icetime icebram"

EXE_O=
if [ -f icepack/icepack.exe ]; then
  EXE_O=.exe
fi

# -- Test the generated executables
for dir in $TOOLS; do
  test_bin $dir/$dir$EXE_O
done

# -- Copy the executables to the bin dir
for dir in $TOOLS; do
  cp $dir/$dir$EXE_O $PACKAGE_DIR/$NAME/bin/$dir$EXE
done

# -- Copy the chipdb*.txt data files
mkdir -p $PACKAGE_DIR/$NAME/share/icebox
cp -r icebox/chipdb*.txt $PACKAGE_DIR/$NAME/share/icebox
cp -r icefuzz/timings*.txt $PACKAGE_DIR/$NAME/share/icebox
