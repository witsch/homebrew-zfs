require 'formula'

class Maczfs < Formula
  homepage 'http://maczfs.org/'
  url 'https://github.com/zfs-osx/zfs.git', :revision => '2cab57bd'
  version '99-2cab57bd'

  head 'https://github.com/zfs-osx/zfs.git'

  depends_on :automake
  depends_on :libtool
  depends_on 'spl'

  env :std    # superenv add `-I...`, which breaks the build

  def install
    ENV['CC'] = 'clang'
    ENV['CXX'] = 'clang++'
    ENV['CPPFLAGS'] = ''
    ENV.deparallelize

    spl_prefix = Formula.factory('spl').opt_prefix

    system "./autogen.sh"
    system "./configure", "--prefix=#{prefix}", "--with-spl=#{spl_prefix}"
    system "make"
  end

  def caveats
    message = <<-EOS.undent
      In order for ZFS-based filesystems to work, the zfs kernel extension
      must be installed by the root user:

        sudo /bin/cp -rfX #{prefix}/spl.kext /Library/Extensions

      If upgrading from a previous version of MacZFS, the old kernel extension
      will need to be unloaded before performing the steps listed above. First,
      check that no ZFS-based filesystems are running:

        mount -t zfs

      Unmount all ZFS filesystems and then unload the kernel extensions:

        sudo kextunload -b net.lundman.zfs
        sudo kextunload -b net.lundman.spl

    EOS

    return message
  end

end
