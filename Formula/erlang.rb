class Erlang < Formula
  desc "Programming language for highly scalable real-time systems"
  homepage "https://www.erlang.org/"
  # Download tarball from GitHub; it is served faster than the official tarball.
  url "https://github.com/erlang/otp/releases/download/OTP-24.1.7/otp_src_24.1.7.tar.gz"
  sha256 "20075d3e8c495e33b29763d0bba9a5bb274f0a8f4a31ff8d201cd9ea33d5e383"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^OTP[._-]v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any,                 arm64_monterey: "80d050c1ae1bbdcc58a64cc61d749ba4ea3e9377d533f5102d06a74c48d4e089"
    sha256 cellar: :any,                 arm64_big_sur:  "10c8953929f5f01e2d43b95f78ec4ca24320bf8f22893ed8ccb8c5ab8edbe355"
    sha256 cellar: :any,                 monterey:       "d5adeb2b9d41f74c4ba51b2e12ccabdc6d94ccb4690efd8edaebdfcf915598e2"
    sha256 cellar: :any,                 big_sur:        "36e1be56d22b25fde8bc2c1cc140110d038867e96e1847fb3f341e7a86858ad9"
    sha256 cellar: :any,                 catalina:       "980d03b2202b26d174ae6ba90f401bcb232ebc180e767bd01642156c3013e701"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "1611cdc3ee6de30612014d501b8f654eb9c354c99f6fa2d4149944975cc5dbf3"
  end

  head do
    url "https://github.com/erlang/otp.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "openssl@1.1"
  depends_on "wxwidgets" # for GUI apps like observer

  resource "html" do
    url "https://github.com/erlang/otp/releases/download/OTP-24.1.7/otp_doc_html_24.1.7.tar.gz"
    mirror "https://fossies.org/linux/misc/otp_doc_html_24.1.7.tar.gz"
    sha256 "cd5ac7007fec0847cf84589e6d0f5055578df0f96edc13379abe579ecd5d17d7"
  end

  def install
    # Unset these so that building wx, kernel, compiler and
    # other modules doesn't fail with an unintelligible error.
    %w[LIBS FLAGS AFLAGS ZFLAGS].each { |k| ENV.delete("ERL_#{k}") }

    # Do this if building from a checkout to generate configure
    system "./otp_build", "autoconf" unless File.exist? "configure"

    args = %W[
      --disable-debug
      --disable-silent-rules
      --prefix=#{prefix}
      --enable-dynamic-ssl-lib
      --enable-hipe
      --enable-shared-zlib
      --enable-smp-support
      --enable-threads
      --enable-wx
      --with-ssl=#{Formula["openssl@1.1"].opt_prefix}
      --without-javac
    ]

    if OS.mac?
      args << "--enable-darwin-64bit"
      args << "--enable-kernel-poll" if MacOS.version > :el_capitan
      args << "--with-dynamic-trace=dtrace" if MacOS::CLT.installed?
    end

    system "./configure", *args
    system "make"
    system "make", "install"

    # Build the doc chunks (manpages are also built by default)
    system "make", "docs", "DOC_TARGETS=chunks"
    system "make", "install-docs"

    doc.install resource("html")
  end

  def caveats
    <<~EOS
      Man pages can be found in:
        #{opt_lib}/erlang/man

      Access them with `erl -man`, or add this directory to MANPATH.
    EOS
  end

  test do
    system "#{bin}/erl", "-noshell", "-eval", "crypto:start().", "-s", "init", "stop"
    (testpath/"factorial").write <<~EOS
      #!#{bin}/escript
      %% -*- erlang -*-
      %%! -smp enable -sname factorial -mnesia debug verbose
      main([String]) ->
          try
              N = list_to_integer(String),
              F = fac(N),
              io:format("factorial ~w = ~w\n", [N,F])
          catch
              _:_ ->
                  usage()
          end;
      main(_) ->
          usage().

      usage() ->
          io:format("usage: factorial integer\n").

      fac(0) -> 1;
      fac(N) -> N * fac(N-1).
    EOS
    chmod 0755, "factorial"
    assert_match "usage: factorial integer", shell_output("./factorial")
    assert_match "factorial 42 = 1405006117752879898543142606244511569936384000000000", shell_output("./factorial 42")
  end
end
