require 'formula'

class Spl < Formula
  homepage 'http://maczfs.org/'
  url 'https://github.com/zfs-osx/spl/archive/alpha-0.6.3.tar.gz'
  sha1 'b9ff6d4d4b219fe443f44d629c4e379e82597d6b'
  head 'https://github.com/zfs-osx/spl.git'

  depends_on :autoconf
  depends_on :automake
  depends_on :libtool

  keg_only "Only the kernel extension is needed, but it cannot be linked anyway."

  def install
    ENV['CC'] = 'clang'
    ENV['CXX'] = 'clang++'
    ENV.deparallelize

    system "./autogen.sh"
    system "./configure", "--prefix=#{prefix}", "--with-kernel-modprefix=''"
    system "make"
    prefix.install 'module/spl/spl.kext'
    prefix.install 'spl.release', 'spl_config.h', 'include'
  end

end
