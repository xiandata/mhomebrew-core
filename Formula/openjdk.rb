class Openjdk < Formula
  desc "Development kit for the Java programming language"
  homepage "https://openjdk.java.net/"
  url "https://github.com/openjdk/jdk17u/archive/jdk-17.0.1-ga.tar.gz"
  sha256 "f27e2f3fd2dcfd144f875e610e7d6c2d9d957e1be96e4f865307b6df381cf7a9"
  license "GPL-2.0-only" => { with: "Classpath-exception-2.0" }

  livecheck do
    url :stable
    regex(/^jdk[._-]v?(\d+(?:\.\d+)*)-ga$/i)
  end

  bottle do
    sha256 cellar: :any, arm64_monterey: "dff2595b1bd5bfc0d630786b5eec9dcd65af7f71ec603e2bb7394ee7ba4549cf"
    sha256 cellar: :any, arm64_big_sur:  "6cd342cc46a444ddc821dc2dbaf2f0b4f30530e89a5ec1f472fb37ed5639dc1b"
    sha256 cellar: :any, monterey:       "d44ec9edcc2743a7e6ca21629951b5ae92ecf55d3173d73d7e9a65495f02e9dd"
    sha256 cellar: :any, big_sur:        "91b650ff481f27671645c4bae344cc38ac7ec3cf32cf2a3188cfbb60fb24d52c"
    sha256 cellar: :any, catalina:       "1275629b5f778935659d35bc0cda71040cb1dc3bacd881e86bd756b190274fc6"
    sha256               x86_64_linux:   "b9836436c6a8b56a9982bfeec807e44748d127abf8914ef925cfe5335a6edc99"
  end

  keg_only :shadowed_by_macos

  depends_on "autoconf" => :build

  on_linux do
    depends_on "pkg-config" => :build
    depends_on "alsa-lib"
    depends_on "cups"
    depends_on "fontconfig"
    depends_on "gcc"
    depends_on "libx11"
    depends_on "libxext"
    depends_on "libxrandr"
    depends_on "libxrender"
    depends_on "libxt"
    depends_on "libxtst"
    depends_on "unzip"
    depends_on "zip"

    ignore_missing_libraries "libjvm.so"
  end

  fails_with gcc: "5"

  # From https://jdk.java.net/archive/
  resource "boot-jdk" do
    on_macos do
      if Hardware::CPU.arm?
        url "https://download.java.net/java/GA/jdk17/0d483333a00540d886896bac774ff48b/35/GPL/openjdk-17_macos-aarch64_bin.tar.gz"
        sha256 "b5bf6377aabdc935bd72b36c494e178b12186b0e1f4be50f35134daa33bda052"
      else
        url "https://download.java.net/java/GA/jdk16.0.2/d4a915d82b4c4fbb9bde534da945d746/7/GPL/openjdk-16.0.2_osx-x64_bin.tar.gz"
        sha256 "e65f2437585f16a01fa8e10139d0d855e8a74396a1dfb0163294ed17edd704b8"
      end
    end
    on_linux do
      url "https://download.java.net/java/GA/jdk16.0.2/d4a915d82b4c4fbb9bde534da945d746/7/GPL/openjdk-16.0.2_linux-x64_bin.tar.gz"
      sha256 "6c714ded7d881ca54970ec949e283f43d673a142fda1de79b646ddd619da9c0c"
    end
  end

  def install
    boot_jdk = Pathname.pwd/"boot-jdk"
    resource("boot-jdk").stage boot_jdk
    boot_jdk /= "Contents/Home" if OS.mac?
    java_options = ENV.delete("_JAVA_OPTIONS")

    args = %W[
      --disable-warnings-as-errors
      --with-boot-jdk-jvmargs=#{java_options}
      --with-boot-jdk=#{boot_jdk}
      --with-debug-level=release
      --with-jvm-variants=server
      --with-native-debug-symbols=none
      --with-vendor-bug-url=#{tap.issues_url}
      --with-vendor-name=#{tap.user}
      --with-vendor-url=#{tap.issues_url}
      --with-vendor-version-string=#{tap.user}
      --with-vendor-vm-bug-url=#{tap.issues_url}
      --with-version-build=#{revision}
      --without-version-opt
      --without-version-pre
    ]

    args += if OS.mac?
      %W[
        --enable-dtrace
        --with-extra-ldflags=-headerpad_max_install_names
        --with-sysroot=#{MacOS.sdk_path}
      ]
    else
      %W[
        --with-x=#{HOMEBREW_PREFIX}
        --with-cups=#{HOMEBREW_PREFIX}
        --with-fontconfig=#{HOMEBREW_PREFIX}
      ]
    end

    chmod 0755, "configure"
    system "./configure", *args

    ENV["MAKEFLAGS"] = "JOBS=#{ENV.make_jobs}"
    system "make", "images"

    if OS.mac?
      jdk = Dir["build/*/images/jdk-bundle/*"].first
      libexec.install jdk => "openjdk.jdk"
      bin.install_symlink Dir[libexec/"openjdk.jdk/Contents/Home/bin/*"]
      include.install_symlink Dir[libexec/"openjdk.jdk/Contents/Home/include/*.h"]
      include.install_symlink Dir[libexec/"openjdk.jdk/Contents/Home/include/darwin/*.h"]
      man1.install_symlink Dir[libexec/"openjdk.jdk/Contents/Home/man/man1/*"]
    else
      libexec.install Dir["build/linux-x86_64-server-release/images/jdk/*"]
      bin.install_symlink Dir[libexec/"bin/*"]
      include.install_symlink Dir[libexec/"include/*.h"]
      include.install_symlink Dir[libexec/"include/linux/*.h"]
      man1.install_symlink Dir[libexec/"man/man1/*"]
    end
  end

  def caveats
    on_macos do
      <<~EOS
        For the system Java wrappers to find this JDK, symlink it with
          sudo ln -sfn #{opt_libexec}/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk
      EOS
    end
  end

  test do
    (testpath/"HelloWorld.java").write <<~EOS
      class HelloWorld {
        public static void main(String args[]) {
          System.out.println("Hello, world!");
        }
      }
    EOS

    system bin/"javac", "HelloWorld.java"

    assert_match "Hello, world!", shell_output("#{bin}/java HelloWorld")
  end
end
