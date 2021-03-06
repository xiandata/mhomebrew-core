class Openldap < Formula
  desc "Open source suite of directory software"
  homepage "https://www.openldap.org/software/"
  url "https://www.openldap.org/software/download/OpenLDAP/openldap-release/openldap-2.6.0.tgz"
  mirror "http://fresh-center.net/linux/misc/openldap-2.6.0.tgz"
  mirror "http://fresh-center.net/linux/misc/legacy/openldap-2.6.0.tgz"
  sha256 "b71c580eac573e9aba15d95f33dd4dd08f2ed4f0d7fc09e08ad4be7ed1e41a4f"
  license "OLDAP-2.8"

  livecheck do
    url "https://www.openldap.org/software/download/OpenLDAP/openldap-release/"
    regex(/href=.*?openldap[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    sha256 arm64_monterey: "32ca782d525e3dfa153699604c63dbe7d9e17e07ffa91f8716182099cbf4d933"
    sha256 arm64_big_sur:  "ffbaaef1efdb003a16c58de104df6b1c7c3b4ffea7716f9bd076051254888dfe"
    sha256 monterey:       "e620a3a13105b488ef8c240882510cd98bcdb468321785bdecd4fe4c9e78e9f6"
    sha256 big_sur:        "c115978e2754736f9ab7390b62722aee6fccf703b050936dd09350943644fde1"
    sha256 catalina:       "ca98ae4585a63d2f500bf989c7ce2fc769e62919dbfba1709ee54bef6c652a69"
    sha256 x86_64_linux:   "9d36c5c8060799e903c66bef0280240e4d51359182e2c7e49fa7376b7d41777f"
  end

  keg_only :provided_by_macos

  depends_on "openssl@1.1"

  on_linux do
    depends_on "util-linux"
  end

  # Fix -flat_namespace being used on Big Sur and later.
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/03cf8088210822aa2c1ab544ed58ea04c897d9c4/libtool/configure-big_sur.diff"
    sha256 "35acd6aebc19843f1a2b3a63e880baceb0f5278ab1ace661e57a502d9d78c93c"
  end

  # Fix https://bugs.openldap.org/show_bug.cgi?id=9733, remove in next release
  patch do
    url "https://git.openldap.org/openldap/openldap/-/commit/eb989be4081cf996bd7e7eb6a529bbc1dc483a59.patch"
    sha256 "d083c2ca7c0ec5c211df53a98ffb02e1ba926abf108bbe4d88550fa6064536a4"
  end

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --sysconfdir=#{etc}
      --localstatedir=#{var}
      --enable-accesslog
      --enable-auditlog
      --enable-bdb=no
      --enable-constraint
      --enable-dds
      --enable-deref
      --enable-dyngroup
      --enable-dynlist
      --enable-hdb=no
      --enable-memberof
      --enable-ppolicy
      --enable-proxycache
      --enable-refint
      --enable-retcode
      --enable-seqmod
      --enable-translucent
      --enable-unique
      --enable-valsort
    ]

    if OS.linux?
      args << "--without-systemd"

      # Disable manpage generation, because it requires groff which has a huge
      # dependency tree on Linux
      inreplace "Makefile.in" do |s|
        s.change_make_var! "SUBDIRS", "include libraries clients servers"
      end
    end

    system "./configure", *args
    system "make", "install"
    (var/"run").mkpath

    # https://github.com/Homebrew/homebrew-dupes/pull/452
    chmod 0755, Dir[etc/"openldap/*"]
    chmod 0755, Dir[etc/"openldap/schema/*"]
  end

  test do
    system sbin/"slappasswd", "-s", "test"
  end
end
