require 'formula'

class Spl < Formula
  homepage 'http://maczfs.org/'
  url 'https://github.com/zfs-osx/spl.git', :revision => '101d5778'
  version '99-101d5778'

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
