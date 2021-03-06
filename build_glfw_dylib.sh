# Ref.: https://github.com/malkia/ufo/blob/master/build/OSX/glfw.sh
wget http://downloads.sourceforge.net/project/glfw/glfw/3.0.1/glfw-3.0.1.zip
unzip glfw-3.0.1.zip
cd glfw-3.0.1/
mkdir build
cd build
export MACOSX_DEPLOYMENT_TARGET=10.8 
cmake -D GLFW_NATIVE_API=1 -D CMAKE_OSX_ARCHITECTURES="i386;x86_64" -D BUILD_SHARED_LIBS=ON -D CMAKE_C_COMPILER=clang ../
make
# ls -l src/libglfw*
# 
#     $ ls -l src/libglfw*
#     -rwxr-xr-x  1 foo  staff  222008  8 11 22:29 src/libglfw.3.0.dylib
#     lrwxr-xr-x  1 foo  staff      17  8 11 22:29 src/libglfw.3.dylib -> libglfw.3.0.dylib
#     lrwxr-xr-x  1 foo  staff      15  8 11 22:29 src/libglfw.dylib -> libglfw.3.dylib

cp src/libglfw* ../..
