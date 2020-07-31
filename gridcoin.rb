class Gridcoin < Formula
  desc "OS X client (GUI and CLI)"
  homepage "https://gridcoin.us/"
  url "https://github.com/gridcoin/Gridcoin-Research/archive/4.0.6.0.tar.gz"
  sha256 "b2908f907227cae735a42dd5aadad26d6999077e6997ee42d9cb0e50738bec43"
  head "https://github.com/gridcoin/Gridcoin-Research.git", :branch => "development"

  def caveats
    s = ""
    s += "--HEAD uses Gridcoin's development branch.\n"
    s += "--devel uses Gridcoin's staging branch.\n"
    s += "Please refer to https://github.com/gridcoin/Gridcoin-Research/blob/master/README.md for Gridcoin's branching strategy\n"
    s
  end

  stable do
    patch <<-EOS
      diff --git a/configure.ac b/configure.ac
      index eb96af9c..8b692612 100644
      --- a/configure.ac
      +++ b/configure.ac
      @@ -829,5 +823,5 @@
       if test x$use_boost = xyes; then
       
      -BOOST_LIBS="$BOOST_LDFLAGS $BOOST_SYSTEM_LIB $BOOST_FILESYSTEM_LIB $BOOST_ZLIB_LIB $BOOST_IOSTREAMS_LIB $BOOST_PROGRAM_OPTIONS_LIB $BOOST_THREAD_LIB $BOOST_CHRONO_LIB $BOOST_ZLIB_LIB"
      +BOOST_LIBS="$BOOST_LDFLAGS $BOOST_SYSTEM_LIB $BOOST_FILESYSTEM_LIB $BOOST_ZLIB_LIB $BOOST_IOSTREAMS_LIB $BOOST_PROGRAM_OPTIONS_LIB $BOOST_THREAD_LIB $BOOST_CHRONO_LIB $BOOST_ZLIB_LIB -lboost_system-mt"
       
       
      @@ -1171,5 +1165,7 @@ echo "  CFLAGS        = $CFLAGS"
       echo "  CPPFLAGS      = $CPPFLAGS"
       echo "  CXX           = $CXX"
       echo "  CXXFLAGS      = $CXXFLAGS"
      +echo "  OBJCXX        = $OBJCXX"
      +echo "  OBJCXXFLAGS   = $OBJCXXFLAGS"
       echo "  LDFLAGS       = $LDFLAGS"
       echo
      diff --git a/src/qt/trafficgraphwidget.cpp b/src/qt/trafficgraphwidget.cpp
      index b1a698f1..6a2e6852 100644
      --- a/src/qt/trafficgraphwidget.cpp
      +++ b/src/qt/trafficgraphwidget.cpp
      @@ -2,6 +2,7 @@
       #include "clientmodel.h"
       
       #include <QPainter>
      +#include <QPainterPath>
       #include <QColor>
       #include <QTimer>
    EOS

    if build.with? "gui"

    patch <<-EOS
      diff --git a/src/qt/trafficgraphwidget.cpp b/src/qt/trafficgraphwidget.cpp
      index b1a698f1..6a2e6852 100644
      --- a/src/qt/trafficgraphwidget.cpp
      +++ b/src/qt/trafficgraphwidget.cpp
      @@ -2,6 +2,7 @@
       #include "clientmodel.h"
       
       #include <QPainter>
      +#include <QPainterPath>
       #include <QColor>
       #include <QTimer>
    EOS

    end





  end

  option "without-upnp", "Do not compile with UPNP support"
  option "with-cli", "Also compile the command line client"
  option "without-gui", "Do not compile the graphical client"

  depends_on "boost"
  depends_on "berkeley-db"
  depends_on "leveldb"
  depends_on "openssl"
  depends_on "miniupnpc"
  depends_on "libzip"
  depends_on "pkg-config" => :build
  depends_on "qrencode"
  depends_on "qt"
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "librsvg" => :build

  def install
    if build.with? "upnp"
      upnp_build_var = "1"
    else
      upnp_build_var = "-"
    end

    if build.with? "cli"
      chmod 0755, "src/leveldb/build_detect_platform"
      mkdir_p "src/obj/zerocoin"
      system "make", "-C", "src", "-f", "makefile.osx", "USE_UPNP=#{upnp_build_var}"
      bin.install "src/gridcoinresearchd"
    end

    if build.with? "gui"
      args = %W[
        BOOST_INCLUDE_PATH=#{Formula["boost"].include}
        BOOST_LIB_PATH=#{Formula["boost"].lib}
        OPENSSL_INCLUDE_PATH=#{Formula["openssl"].include}
        OPENSSL_LIB_PATH=#{Formula["openssl"].lib}
        BDB_INCLUDE_PATH=#{Formula["berkeley-db"].include}
        BDB_LIB_PATH=#{Formula["berkeley-db"].lib}
        MINIUPNPC_INCLUDE_PATH=#{Formula["miniupnpc"].include}
        MINIUPNPC_LIB_PATH=#{Formula["miniupnpc"].lib}
        QRENCODE_INCLUDE_PATH=#{Formula["qrencode"].include}
        QRENCODE_LIB_PATH=#{Formula["qrencode"].lib}
      ]

      system "./autogen.sh"
      system "unset OBJCXX ; ./configure --with-incompatible-bdb"
      system "make appbundle"
      prefix.install "gridcoinresearch.app"
    end
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! It's enough to just replace
    # "false" with the main program this formula installs, but it'd be nice if you
    # were more thorough. Run the test with `brew test Gridcoin`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end
