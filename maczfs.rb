require 'formula'

class Maczfs < Formula
  homepage 'http://maczfs.org/'
  url 'https://github.com/zfs-osx/zfs/archive/alpha-0.6.3.tar.gz'
  sha1 '2df9e32fbc5fb3fd2875adae06967e5d84278305'
  head 'https://github.com/zfs-osx/zfs.git'

  depends_on :automake
  depends_on :libtool
  depends_on 'spl'

  env :std    # superenv add `-I...`, which breaks the build

  keg_only "Linking should only be done once the matching kernel extension has been loaded."

  def install
    ENV['CC'] = 'clang'
    ENV['CXX'] = 'clang++'
    ENV['CPPFLAGS'] = ''
    ENV.deparallelize

    spl_prefix = Formula.factory('spl').opt_prefix

    system "./autogen.sh"
    system "./configure", "--prefix=#{prefix}", "--with-spl=#{spl_prefix}"
    system "make"
    prefix.install 'module/zfs/zfs.kext'
    lib.install Dir['lib/libnvpair/.libs/*.dylib']
    lib.install Dir['lib/libuutil/.libs/*.dylib']
    lib.install Dir['lib/libzfs/.libs/*.dylib']
    lib.install Dir['lib/libzfs_core/.libs/*.dylib']
    lib.install Dir['lib/libzpool/.libs/*.dylib']
    sbin.install 'cmd/zpool/.libs/zpool'
    sbin.install 'cmd/zfs/.libs/zfs'
    sbin.install 'cmd/zdb/.libs/zdb'
    man8.install 'man/man8/zpool.8'
    man8.install 'man/man8/zfs.8'
    man8.install 'man/man8/zdb.8'

    # create convenience script to reload kexts and link the binaries
    (prefix + "setup.sh").write <<-EOS.undent
      #!/bin/bash

      # define locations
      exts=/System/Library/Extensions
      splx=#{spl_prefix}/spl.kext
      zfsx=#{prefix}/zfs.kext

      # unload kexts if they exist in /System/...
      echo Unloading kexts...
      test -e $exts/zfs.kext && kextunload $exts/zfs.kext
      test -e $exts/spl.kext && kextunload $exts/spl.kext

      # prepare extensions
      chown -R root $splx $zfsx

      function onexit() {
          local status=${1:-$?}
          kextload $splx
          kextload $zfsx
          exit $status
      }

      # try to load new extensions, and revert to the old ones should that fail...
      echo Loading new kexts...
      trap 'onexit' ERR
      set -o errexit
      kextload $splx
      kextload $zfsx
      trap - ERR

      # the kexts can be loaded, so they should be copied into place...
      echo Copying new kexts...
      cp -rf $splx $zfsx $exts/

      # lastly the zfs binaries are linked (from the homebrew cellar)
      sudo -u $SUDO_USER brew unlink maczfs
      sudo -u $SUDO_USER brew link --force maczfs
    EOS

  end

  def caveats
    message = <<-EOS.undent
      In order for ZFS-based filesystems to work, matching spl and zfs
      kernel extensions must be loaded, and only then any binaries etc
      should be linked from the cellar.  A setup script taking care of
      the required steps is provided for convenience.  Please run:

        sudo bash #{prefix}/setup.sh

      Note that before running this script all ZFS-based filesystems
      should be unmounted.
    EOS
    return message
  end

end
