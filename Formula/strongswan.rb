class Strongswan < Formula
  desc "VPN based on IPsec"
  homepage "https://www.strongswan.org"
  license "GPL-2.0-or-later"
  revision 1

  stable do
    url "https://download.strongswan.org/strongswan-5.9.4.tar.bz2"
    sha256 "45fdf1a4c2af086d8ff5b76fd7b21d3b6f0890f365f83bf4c9a75dda26887518"

    # Fix -flat_namespace being used on Big Sur and later.
    patch do
      url "https://raw.githubusercontent.com/Homebrew/formula-patches/03cf8088210822aa2c1ab544ed58ea04c897d9c4/libtool/configure-big_sur.diff"
      sha256 "35acd6aebc19843f1a2b3a63e880baceb0f5278ab1ace661e57a502d9d78c93c"
    end

    # Fix Installation of virtual IPs in strongSwan failing on macOS Monterey
    # Remove from `not_a_binary_url_prefix_allowlist.json` when this patch is removed.
    patch do
      url "https://github.com/Homebrew/homebrew-core/files/7503555/macos-12-tun-fix.txt"
      sha256 "733a6868f18d7e28ad90d41fde4dfedd2b975ccaf9bb98ede31eac00685a697a"
    end
  end

  livecheck do
    url "https://download.strongswan.org/"
    regex(/href=.*?strongswan[._-]v?(\d+(?:\.\d+)+[a-z]?)\.t/i)
  end

  bottle do
    sha256 arm64_monterey: "5c263f7bdc0f889d3ab6ab9390e55e82116afbed1d498cbc99e54ea40ba28990"
    sha256 arm64_big_sur:  "6e319f2ec766a4095d53f98d9c8e7974c7e13c5ad1d629884c34abc96fa5f4f0"
    sha256 monterey:       "c149f692c40982c2ae6fab672bbd378a16b3747d82edc12c7783ff32301537be"
    sha256 big_sur:        "3686b4aecc7b5a1ce8d085dfe2572b15ec5f1585b64be464411b7e1379ee875f"
    sha256 catalina:       "19214f5451b8e000f74761a1fc55f72b9c1793a145fb168b2d889de0931d9893"
  end

  head do
    url "https://git.strongswan.org/strongswan.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "bison" => :build
    depends_on "gettext" => :build
    depends_on "libtool" => :build
    depends_on "pkg-config" => :build
  end

  depends_on "openssl@1.1"

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --sbindir=#{bin}
      --sysconfdir=#{etc}
      --disable-defaults
      --enable-charon
      --enable-cmd
      --enable-constraints
      --enable-curve25519
      --enable-eap-gtc
      --enable-eap-identity
      --enable-eap-md5
      --enable-eap-mschapv2
      --enable-ikev1
      --enable-ikev2
      --enable-kernel-pfkey
      --enable-nonce
      --enable-openssl
      --enable-pem
      --enable-pgp
      --enable-pkcs1
      --enable-pkcs8
      --enable-pki
      --enable-pubkey
      --enable-revocation
      --enable-scepclient
      --enable-socket-default
      --enable-sshkey
      --enable-stroke
      --enable-swanctl
      --enable-unity
      --enable-updown
      --enable-x509
      --enable-xauth-generic
    ]

    args << "--enable-kernel-pfroute" << "--enable-osx-attr" if OS.mac?

    system "./autogen.sh" if build.head?
    system "./configure", *args
    system "make", "install"
  end

  def caveats
    <<~EOS
      You will have to run both "ipsec" and "charon-cmd" with "sudo".
    EOS
  end

  test do
    system "#{bin}/ipsec", "--version"
    system "#{bin}/charon-cmd", "--version"
  end
end
