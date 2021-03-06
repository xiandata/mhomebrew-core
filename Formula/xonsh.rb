class Xonsh < Formula
  include Language::Python::Virtualenv

  desc "Python-powered, cross-platform, Unix-gazing shell language and command prompt"
  homepage "https://xon.sh/"
  url "https://files.pythonhosted.org/packages/12/5c/b6143c3d6a3007450f2126a5188a86d7524122c761bf1652428c3393dfd2/xonsh-0.11.0.tar.gz"
  sha256 "0d9c3d9a4e8b8199ae697fbc9d1e0ae55085cdbdd4306d04813350996f9c15dc"
  license "BSD-2-Clause-Views"
  head "https://github.com/xonsh/xonsh.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_monterey: "06af4f708d6d754355fd8dab959d0833142dc33b229f1421bb0f77ff7b2d5d1b"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "d685043c048c2862f26257596e1138fce31bc6437eb06af08210a0bbf65785e4"
    sha256 cellar: :any_skip_relocation, monterey:       "812da8c14878d72f5eaaaef32eb585ca98a8040e4b5cb0f23d0ffce05ec350bb"
    sha256 cellar: :any_skip_relocation, big_sur:        "0e2832390e930c870aa83dfe55a8ba4efaf835d5b533d84bcd4edceefd03ea81"
    sha256 cellar: :any_skip_relocation, catalina:       "e8e7d350fcfe24c80fe7603851fac5c33fd1d9417bb52153bba7ae88fbd6b3cd"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "c5af7744fa6a39c0ffeea9db4e61d9f42e3b43a6985b2aaddfa168235964930b"
  end

  depends_on "python@3.10"

  # Resources based on `pip3 install xonsh[ptk,pygments,proctitle]`
  # See https://xon.sh/osx.html#dependencies

  resource "prompt-toolkit" do
    url "https://files.pythonhosted.org/packages/53/96/b3bff620964869c07252fc2eac4e7e2dd48aea07314d932d21cfd92428da/prompt_toolkit-3.0.22.tar.gz"
    sha256 "449f333dd120bd01f5d296a8ce1452114ba3a71fae7288d2f0ae2c918764fa72"
  end

  resource "Pygments" do
    url "https://files.pythonhosted.org/packages/b7/b3/5cba26637fe43500d4568d0ee7b7362de1fb29c0e158d50b4b69e9a40422/Pygments-2.10.0.tar.gz"
    sha256 "f398865f7eb6874156579fdf36bc840a03cab64d1cde9e93d68f46a425ec52c6"
  end

  resource "pyperclip" do
    url "https://files.pythonhosted.org/packages/a7/2c/4c64579f847bd5d539803c8b909e54ba087a79d01bb3aba433a95879a6c5/pyperclip-1.8.2.tar.gz"
    sha256 "105254a8b04934f0bc84e9c24eb360a591aaf6535c9def5f29d92af107a9bf57"
  end

  resource "setproctitle" do
    url "https://files.pythonhosted.org/packages/a1/7f/a1d4f4c7b66f0fc02f35dc5c85f45a8b4e4a7988357a29e61c14e725ef86/setproctitle-1.2.2.tar.gz"
    sha256 "7dfb472c8852403d34007e01d6e3c68c57eb66433fb8a5c77b13b89a160d97df"
  end

  resource "wcwidth" do
    url "https://files.pythonhosted.org/packages/89/38/459b727c381504f361832b9e5ace19966de1a235d73cdbdea91c771a1155/wcwidth-0.2.5.tar.gz"
    sha256 "c4d647b99872929fdb7bdcaa4fbe7f01413ed3d98077df798530e5b04f116c83"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match "4", shell_output("#{bin}/xonsh -c 2+2")
  end
end
