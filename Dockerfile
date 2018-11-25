FROM ubuntu
MAINTAINER Wincent Balin <wincent.balin@gmail.com>

# Update all packages
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get -y clean && \
    apt-get -y autoremove

# Install compilation prerequisites
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get install -y \
        build-essential \
        mingw-w64 \
        gperf \
        pkg-config \
        cmake \
        python \
        python-lxml \
        man \
        wget \
        unzip \
        zip \
        less && \
    apt-get -y clean

# Enter versions!!!
ENV LIBICONV_VERSION 1.15
ENV ZLIB_VERSION 1.2.11
ENV LIBMAD_VERSION 0.15.1b
ENV LIBID3TAG_VERSION 0.15.1b
ENV LIBOGG_VERSION 1.3.2
ENV LIBVORBIS_VERSION 1.3.5
ENV FLAC_VERSION 1.3.1
ENV LIBSNDFILE_VERSION 1.0.28
ENV LIBPNG_VERSION 1.6.34
ENV JPEG_VERSION 9c
ENV JBIGKIT_VERSION 2.1
ENV TIFF_VERSION  4.0.9
ENV LIBWEBP_VERSION 0.6.1
ENV LIQ_VERSION 2.11.9
ENV FREETYPE2_VERSION 2.9.1
ENV EXPAT_VERSION 2.2.5
ENV EXPAT_VERSION_MANGLED 2_2_5
ENV FONTCONFIG_VERSION 2.12.6
ENV LIBGD_VERSION 2.2.5
ENV BOOST_VERSION 1.65.1
ENV BOOST_VERSION_MANGLED 1_65_1
ENV AUDIOWAVEFORM_VERSION master

# Prepare compilation directories
ENV C /tmp/compile
WORKDIR ${C}
ENV BOOST_BUILD_PATH ${C}/boost-build

# Set environment variables
ENV PATH ${C}/lib:$PATH
ENV PATH ${C}/bin:$PATH
ENV LD_RUN_PATH ${C}/lib:${LD_RUN_PATH}

# Compile for Win32
ENV CROSS_ARCH i686-w64-mingw32
ENV BUILD_ARCH x86_64-pc-linux-gnu

# Create pkg-config
WORKDIR bin
COPY pkg-config .
RUN chmod 0755 pkg-config && \
    mv pkg-config ${CROSS_ARCH}-pkg-config
WORKDIR ..

# Download and compile libiconv
RUN wget -q -O - ftp://ftp.gnu.org/gnu/libiconv/libiconv-${LIBICONV_VERSION}.tar.gz | \
    tar zxvf -
WORKDIR libiconv-${LIBICONV_VERSION}
RUN ./configure --prefix=${C} --host=${CROSS_ARCH} --build=${BUILD_ARCH} --disable-shared --enable-static && \
    make && \
    make install
WORKDIR ..

# Download and compile zlib
RUN wget -q -O - http://sourceforge.net/projects/libpng/files/zlib/${ZLIB_VERSION}/zlib-${ZLIB_VERSION}.tar.gz | \
    tar zxvf -
WORKDIR zlib-${ZLIB_VERSION}
RUN CC=${CROSS_ARCH}-gcc ./configure --prefix ${C} --static && \
    make && \
    make install
WORKDIR ..

# Download and compile libmad
RUN wget -q -O - http://sourceforge.net/projects/mad/files/libmad/${LIBMAD_VERSION}/libmad-${LIBMAD_VERSION}.tar.gz | \
    tar zxvf -
WORKDIR libmad-${LIBMAD_VERSION}
RUN ./configure --prefix=${C} --host=${CROSS_ARCH} --build=${BUILD_ARCH} --enable-static --disable-shared CFLAGS="-I${C}/include -L${C}/lib" && \
    make && \
    make install
WORKDIR ..

# Download and compile libid3tag
RUN wget -q -O - http://sourceforge.net/projects/mad/files/libid3tag/${LIBID3TAG_VERSION}/libid3tag-${LIBID3TAG_VERSION}.tar.gz | \
    tar zxvf -
WORKDIR libid3tag-${LIBID3TAG_VERSION}
RUN ./configure --prefix=${C} --host=${CROSS_ARCH} --build=${BUILD_ARCH} --enable-static --disable-shared CFLAGS="-I${C}/include -L${C}/lib" && \
    make && \
    make install
WORKDIR ..

# Download and compile libogg
RUN wget -q -O - http://downloads.xiph.org/releases/ogg/libogg-${LIBOGG_VERSION}.tar.gz | \
    tar zxvf -
WORKDIR libogg-${LIBOGG_VERSION}
RUN ./configure --prefix=${C} --host=${CROSS_ARCH} --build=${BUILD_ARCH} --enable-static --disable-shared CFLAGS="-I${C}/include -L${C}/lib" && \
    make && \
    make install
WORKDIR ..

# Download and compile libvorbis
RUN wget -q -O - http://downloads.xiph.org/releases/vorbis/libvorbis-${LIBVORBIS_VERSION}.tar.gz | \
    tar zxvf -
WORKDIR libvorbis-${LIBVORBIS_VERSION}
RUN ./configure --prefix=${C} --host=${CROSS_ARCH} --build=${BUILD_ARCH} --enable-static --disable-shared CFLAGS="-I${C}/include -L${C}/lib" && \
    make && \
    make install
WORKDIR ..

# Download and compile FLAC
RUN wget -q -O - http://downloads.xiph.org/releases/flac/flac-${FLAC_VERSION}.tar.xz | \
    tar Jxvf -
WORKDIR flac-${FLAC_VERSION}
RUN ./configure --prefix=${C} --host=${CROSS_ARCH} --build=${BUILD_ARCH} --enable-static --disable-shared CFLAGS="-I${C}/include -L${C}/lib" --disable-doxygen-docs && \
    make && \
    make install
WORKDIR ..

# Download and compile libsndfile
RUN wget -q -O - http://www.mega-nerd.com/libsndfile/files/libsndfile-${LIBSNDFILE_VERSION}.tar.gz | \
    tar zxvf -
WORKDIR libsndfile-${LIBSNDFILE_VERSION}
RUN ./configure --prefix=${C} --host=${CROSS_ARCH} --build=${BUILD_ARCH} --enable-static --disable-shared CFLAGS="-I${C}/include -L${C}/lib" --disable-sqlite && \
    make && \
    make install
WORKDIR ..
ENV SNDFILE_CFLAGS "-I${C}/include"
ENV SNDFILE_LIBS "-L${C}/lib -lFLAC -lvorbisenc -lvorbis -lm -logg -lsndfile"

# Download and compile libpng
RUN wget -q -O - http://sourceforge.net/projects/libpng/files/libpng16/${LIBPNG_VERSION}/libpng-${LIBPNG_VERSION}.tar.gz | \
    tar zxvf -
WORKDIR libpng-${LIBPNG_VERSION}
RUN ./configure --prefix=${C} --host=${CROSS_ARCH} --build=${BUILD_ARCH} --enable-static --disable-shared CFLAGS="-I${C}/include -L${C}/lib" CPPFLAGS="-I${C}/include" && \
    make && \
    make install
WORKDIR ..

# Download and compile jpeg
#RUN wget -q -O - http://www.ijg.org/files/jpegsrc.v${JPEG_VERSION}.tar.gz | \
#    tar zxvf -
#WORKDIR jpeg-${JPEG_VERSION}
#RUN ./configure --prefix=${C} --host=${CROSS_ARCH} --build=${BUILD_ARCH} --enable-static --disable-shared && \
#    make && \
#    make install
#WORKDIR ..

# Download and compile tiff
#RUN wget -q -O - http://www.cl.cam.ac.uk/~mgk25/jbigkit/download/jbigkit-${JBIGKIT_VERSION}.tar.gz | \
#    tar zxvf -
#WORKDIR jbigkit-${JBIGKIT_VERSION}/libjbig
#RUN make CC=${CROSS_ARCH}-gcc && \
#    cp *.a ${C}/lib && \
#    cp *.h ${C}/include
#WORKDIR ../..

# Download and compile tiff
#RUN wget -q -O - ftp://download.osgeo.org/libtiff/tiff-${TIFF_VERSION}.tar.gz | \
#    tar zxvf -
#WORKDIR tiff-${TIFF_VERSION}
#RUN CPPFLAGS="-I${C}/include -L${C}/lib" LDFLAGS="-L${C}/lib" ./configure --prefix=${C} --host=${CROSS_ARCH} --build=${BUILD_ARCH} --enable-static --disable-shared && \
#    make && \
#    make install
#WORKDIR ..

# Download and compile libwebp
#RUN wget -q -O - https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-${LIBWEBP_VERSION}.tar.gz | \
#    tar zxvf -
#WORKDIR libwebp-${LIBWEBP_VERSION}
#RUN sed -ie 's/LIBPNG_CONFIG --ldflags/LIBPNG_CONFIG --static --ldflags/' configure && \
#    CPPFLAGS="-I${C}/include -L${C}/lib" ./configure --prefix=${C} --host=${CROSS_ARCH} --build=${BUILD_ARCH} --enable-static --disable-shared --enable-libwebpmux --enable-libwebpdemux --enable-libwebpdecoder && \
#    make && \
#    make install
#WORKDIR ..

# Download and compile liq (libimagequant)
RUN wget -q -O - https://github.com/ImageOptim/libimagequant/archive/${LIQ_VERSION}.tar.gz | \
    tar zxvf -
WORKDIR libimagequant-${LIQ_VERSION}
RUN make CC=${CROSS_ARCH}-gcc static && \
    ${CROSS_ARCH}-ranlib libimagequant.a && \
    cp libimagequant.h ${C}/include && \
    cp libimagequant.a ${C}/lib
WORKDIR ..

# Download and compile freetype
RUN wget -q -O - https://sourceforge.net/projects/freetype/files/freetype2/${FREETYPE2_VERSION}/freetype-${FREETYPE2_VERSION}.tar.gz | \
    tar zxvf -
WORKDIR freetype-${FREETYPE2_VERSION}
RUN ./configure --prefix=${C} --host=${CROSS_ARCH} --build=${BUILD_ARCH} --enable-static --disable-shared && \
    make && \
    make install
WORKDIR ..

# Download and compile expat
RUN wget -q -O - https://github.com/libexpat/libexpat/releases/download/R_${EXPAT_VERSION_MANGLED}/expat-${EXPAT_VERSION}.tar.bz2 | \
    tar jxvf -
WORKDIR expat-${EXPAT_VERSION}
RUN ./configure --prefix=${C} --host=${CROSS_ARCH} --build=${BUILD_ARCH} --enable-static --disable-shared --without-xmlwf && \
    make && \
    make install
WORKDIR ..

# Download and compile fontconfig
RUN wget -q -O - https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.12.6.tar.bz2 | \
    tar jxvf -
WORKDIR fontconfig-${FONTCONFIG_VERSION}
RUN ./configure --prefix=${C} --host=${CROSS_ARCH} --build=${BUILD_ARCH} --enable-static --disable-shared && \
    make && \
    make install
WORKDIR ..

# Download and compile libgd
RUN wget -q -O - https://github.com/libgd/libgd/releases/download/gd-${LIBGD_VERSION}/libgd-${LIBGD_VERSION}.tar.gz | \
    tar zxvf -
WORKDIR libgd-${LIBGD_VERSION}
# Defines and sed command taken from https://github.com/mxe/mxe/blob/master/src/gd.mk
RUN sed -i 's,-I@includedir@,-I@includedir@ -DNONDLL -DBGDWIN32,' 'config/gdlib-config.in' && \
    CFLAGS="-DNONDLL" ./configure --prefix=${C} --host=${CROSS_ARCH} --build=${BUILD_ARCH} --enable-static --disable-shared && \
    make && \
    make install
WORKDIR ..

# Download and compile boost
RUN wget -q -O - https://sourceforge.net/projects/boost/files/boost/${BOOST_VERSION}/boost_${BOOST_VERSION_MANGLED}.tar.gz | \
    tar zxvf -
WORKDIR ${BOOST_BUILD_PATH}
RUN echo "using gcc : mingw : ${CROSS_ARCH}-g++ ;" > user-config.jam
WORKDIR ..
WORKDIR boost_${BOOST_VERSION_MANGLED}
RUN ./bootstrap.sh && \
    ./b2 install --prefix=${C} toolset=gcc-mingw target-os=windows --with-filesystem --with-program_options --with-regex variant=release link=static runtime-link=static
WORKDIR ..

# Download and compile audiowaveform
RUN wget -q -O - https://github.com/bbc/audiowaveform/archive/${AUDIOWAVEFORM_VERSION}.tar.gz | \
    tar zxvf -
WORKDIR audiowaveform-${AUDIOWAVEFORM_VERSION}
COPY audiowaveform-mingw.patch .
RUN patch -p0 < audiowaveform-mingw.patch
WORKDIR build
COPY ${CROSS_ARCH}.cmake .
RUN cmake -DCMAKE_TOOLCHAIN_FILE=${C}/audiowaveform-${AUDIOWAVEFORM_VERSION}/build/${CROSS_ARCH}.cmake -DCMAKE_INSTALL_PREFIX=${C} -DENABLE_TESTS=0 -DCMAKE_CXX_FLAGS_RELEASE="-O3 -DNDEBUG -DBGDWIN32 -static-libgcc -static-libstdc++ -static" -DCMAKE_FIND_LIBRARY_SUFFIXES=".a" -DEXTRA_LIBS="-L${C}/lib -lFLAC -lvorbisenc -lvorbis -logg -lpng -lz" .. && \
    make && \
    make install
WORKDIR ../..

# Strip binaries
RUN $CROSS_ARCH-strip bin/*.exe

# Create mingw32 archive
RUN zip -r -9 audiowaveform-mingw32.zip bin/ etc/ include/ lib/ share/

# Clean up everything
RUN rm -rf bin/ etc/ include/ lib/ share/

WORKDIR libiconv-${LIBICONV_VERSION}
RUN make distclean
WORKDIR ..

WORKDIR zlib-${ZLIB_VERSION}
RUN make distclean
WORKDIR ..

WORKDIR libmad-${LIBMAD_VERSION}
RUN make distclean
WORKDIR ..

WORKDIR libid3tag-${LIBID3TAG_VERSION}
RUN make distclean
WORKDIR ..

WORKDIR libogg-${LIBOGG_VERSION}
RUN make distclean
WORKDIR ..

WORKDIR libvorbis-${LIBVORBIS_VERSION}
RUN make distclean
WORKDIR ..

WORKDIR flac-${FLAC_VERSION}
RUN make distclean
WORKDIR ..

WORKDIR libsndfile-${LIBSNDFILE_VERSION}
RUN make distclean
WORKDIR ..

WORKDIR libpng-${LIBPNG_VERSION}
RUN make distclean
WORKDIR ..

#WORKDIR jpeg-${JPEG_VERSION}
#RUN make distclean
#WORKDIR ..

#WORKDIR jbigkit-${JBIGKIT_VERSION}/libjbig
#RUN make distclean
#WORKDIR ../..

#WORKDIR tiff-${TIFF_VERSION}
#RUN make distclean
#WORKDIR ..

#WORKDIR libwebp-${LIBWEBP_VERSION}
#RUN make distclean
#WORKDIR ..

WORKDIR libimagequant-${LIQ_VERSION}
RUN make distclean
WORKDIR ..

WORKDIR freetype-${FREETYPE2_VERSION}
RUN make distclean
WORKDIR ..

WORKDIR expat-${EXPAT_VERSION}
RUN make distclean
WORKDIR ..

WORKDIR fontconfig-${FONTCONFIG_VERSION}
RUN make distclean
WORKDIR ..

WORKDIR libgd-${LIBGD_VERSION}
RUN make distclean
WORKDIR ..

WORKDIR boost_${BOOST_VERSION_MANGLED}
RUN ./b2 install --prefix=${C} toolset=gcc-mingw target-os=windows --with-filesystem --with-program_options --with-regex variant=release link=static runtime-link=static --clean && \
    rm -r bin.v2
WORKDIR ..

WORKDIR audiowaveform-${AUDIOWAVEFORM_VERSION}
WORKDIR build
RUN make clean
WORKDIR ..
RUN rm -r build
WORKDIR ..


# Compile for Win64
ENV CROSS_ARCH x86_64-w64-mingw32
ENV BUILD_ARCH x86_64-pc-linux-gnu

# Create pkg-config
WORKDIR bin
COPY pkg-config .
RUN chmod 0755 pkg-config && \
    mv pkg-config ${CROSS_ARCH}-pkg-config
WORKDIR ..

# Compile libiconv
WORKDIR libiconv-${LIBICONV_VERSION}
RUN ./configure --prefix=${C} --host=${CROSS_ARCH} --build=${BUILD_ARCH} --disable-shared --enable-static && \
    make && \
    make install
WORKDIR ..

# Compile zlib
WORKDIR zlib-${ZLIB_VERSION}
RUN CC=${CROSS_ARCH}-gcc ./configure --prefix ${C} --static && \
    make && \
    make install
WORKDIR ..

# Compile libmad
WORKDIR libmad-${LIBMAD_VERSION}
RUN ./configure --prefix=${C} --host=${CROSS_ARCH} --build=${BUILD_ARCH} --enable-static --disable-shared CFLAGS="-I${C}/include -L${C}/lib" && \
    make && \
    make install
WORKDIR ..

# Compile libid3tag
WORKDIR libid3tag-${LIBID3TAG_VERSION}
RUN ./configure --prefix=${C} --host=${CROSS_ARCH} --build=${BUILD_ARCH} --enable-static --disable-shared CFLAGS="-I${C}/include -L${C}/lib" && \
    make && \
    make install
WORKDIR ..

# Compile libogg
WORKDIR libogg-${LIBOGG_VERSION}
RUN ./configure --prefix=${C} --host=${CROSS_ARCH} --build=${BUILD_ARCH} --enable-static --disable-shared CFLAGS="-I${C}/include -L${C}/lib" && \
    make && \
    make install
WORKDIR ..

# Compile libvorbis
WORKDIR libvorbis-${LIBVORBIS_VERSION}
RUN ./configure --prefix=${C} --host=${CROSS_ARCH} --build=${BUILD_ARCH} --enable-static --disable-shared CFLAGS="-I${C}/include -L${C}/lib" && \
    make && \
    make install
WORKDIR ..

# Compile FLAC
WORKDIR flac-${FLAC_VERSION}
RUN ./configure --prefix=${C} --host=${CROSS_ARCH} --build=${BUILD_ARCH} --enable-static --disable-shared CFLAGS="-I${C}/include -L${C}/lib" --disable-doxygen-docs && \
    make && \
    make install
WORKDIR ..

# Compile libsndfile
WORKDIR libsndfile-${LIBSNDFILE_VERSION}
RUN ./configure --prefix=${C} --host=${CROSS_ARCH} --build=${BUILD_ARCH} --enable-static --disable-shared CFLAGS="-I${C}/include -L${C}/lib" --disable-sqlite && \
    make && \
    make install
WORKDIR ..
ENV SNDFILE_CFLAGS "-I${C}/include"
ENV SNDFILE_LIBS "-L${C}/lib -lFLAC -lvorbisenc -lvorbis -lm -logg -lsndfile"

# Compile libpng
WORKDIR libpng-${LIBPNG_VERSION}
RUN ./configure --prefix=${C} --host=${CROSS_ARCH} --build=${BUILD_ARCH} --enable-static --disable-shared CFLAGS="-I${C}/include -L${C}/lib" CPPFLAGS="-I${C}/include" && \
    make && \
    make install
WORKDIR ..

# Compile jpeg
#WORKDIR jpeg-${JPEG_VERSION}
#RUN ./configure --prefix=${C} --host=${CROSS_ARCH} --build=${BUILD_ARCH} --enable-static --disable-shared && \
#    make && \
#    make install
#WORKDIR ..

# Compile tiff
#WORKDIR jbigkit-${JBIGKIT_VERSION}/libjbig
#RUN make CC=${CROSS_ARCH}-gcc && \
#    cp *.a ${C}/lib && \
#    cp *.h ${C}/include
#WORKDIR ../..

# Compile tiff
#WORKDIR tiff-${TIFF_VERSION}
#RUN CPPFLAGS="-I${C}/include -L${C}/lib" LDFLAGS="-L${C}/lib" ./configure --prefix=${C} --host=${CROSS_ARCH} --build=${BUILD_ARCH} --enable-static --disable-shared && \
#    make && \
#    make install
#WORKDIR ..

# Compile libwebp
#WORKDIR libwebp-${LIBWEBP_VERSION}
#RUN CPPFLAGS="-I${C}/include -L${C}/lib" ./configure --prefix=${C} --host=${CROSS_ARCH} --build=${BUILD_ARCH} --enable-static --disable-shared --enable-libwebpmux --enable-libwebpdemux --enable-libwebpdecoder && \
#    make && \
#    make install
#WORKDIR ..

# Compile liq (libimagequant)
WORKDIR libimagequant-${LIQ_VERSION}
RUN make CC=${CROSS_ARCH}-gcc static && \
    ${CROSS_ARCH}-ranlib libimagequant.a && \
    cp libimagequant.h ${C}/include && \
    cp libimagequant.a ${C}/lib
WORKDIR ..

# Compile freetype
WORKDIR freetype-${FREETYPE2_VERSION}
RUN ./configure --prefix=${C} --host=${CROSS_ARCH} --build=${BUILD_ARCH} --enable-static --disable-shared && \
    make && \
    make install
WORKDIR ..

# Compile expat
WORKDIR expat-${EXPAT_VERSION}
RUN ./configure --prefix=${C} --host=${CROSS_ARCH} --build=${BUILD_ARCH} --enable-static --disable-shared --without-xmlwf && \
    make && \
    make install
WORKDIR ..

# Compile fontconfig
WORKDIR fontconfig-${FONTCONFIG_VERSION}
RUN ./configure --prefix=${C} --host=${CROSS_ARCH} --build=${BUILD_ARCH} --enable-static --disable-shared && \
    make && \
    make install
WORKDIR ..

# Compile libgd
WORKDIR libgd-${LIBGD_VERSION}
# Define taken from https://github.com/mxe/mxe/blob/master/src/gd.mk
RUN CFLAGS="-DNONDLL" ./configure --prefix=${C} --host=${CROSS_ARCH} --build=${BUILD_ARCH} --enable-static --disable-shared && \
    make && \
    make install
WORKDIR ..

# Compile boost
WORKDIR ${BOOST_BUILD_PATH}
RUN echo "using gcc : mingw : ${CROSS_ARCH}-g++ ;" > user-config.jam
WORKDIR ..
WORKDIR boost_${BOOST_VERSION_MANGLED}
RUN ./bootstrap.sh && \
    ./b2 install --prefix=${C} toolset=gcc-mingw target-os=windows --with-filesystem --with-program_options --with-regex variant=release link=static runtime-link=static address-model=64
WORKDIR ..

# Compile audiowaveform
WORKDIR audiowaveform-${AUDIOWAVEFORM_VERSION}
WORKDIR build
COPY ${CROSS_ARCH}.cmake .
RUN cmake -DCMAKE_TOOLCHAIN_FILE=${C}/audiowaveform-${AUDIOWAVEFORM_VERSION}/build/${CROSS_ARCH}.cmake -DCMAKE_INSTALL_PREFIX=${C} -DENABLE_TESTS=0 -DCMAKE_CXX_FLAGS_RELEASE="-O3 -DNDEBUG -DBGDWIN32 -static-libgcc -static-libstdc++ -static" -DCMAKE_FIND_LIBRARY_SUFFIXES=".a" -DEXTRA_LIBS="-L${C}/lib -lFLAC -lvorbisenc -lvorbis -logg -lpng -lz" .. && \
    make && \
    make install
WORKDIR ../..

# Strip binaries
RUN $CROSS_ARCH-strip bin/*.exe

# Create mingw64 archive
RUN zip -r -9 audiowaveform-mingw64.zip bin/ etc/ include/ lib/ share/


