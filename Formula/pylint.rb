class Pylint < Formula
  include Language::Python::Virtualenv

  desc "It's not just a linter that annoys you!"
  homepage "https://github.com/PyCQA/pylint"
  url "https://files.pythonhosted.org/packages/cc/67/c9cfda196db31390f0fb29f996f1393fd38217a531e1f3e057d86659b12c/pylint-2.12.1.tar.gz"
  sha256 "4f4a52b132c05b49094b28e109febcec6bfb7bc6961c7485a5ad0a0f961df289"
  license "GPL-2.0-or-later"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_monterey: "dcaeca058a04207952cb09b97dd1b938b2a46d9ddbbdded1d8ebce2ace416e32"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "37608d120d4730daff2e1f1c400b6bf3af3252f6709e26e18238f1fb641153e8"
    sha256 cellar: :any_skip_relocation, monterey:       "57a836f53dd81f939833dacc33726e10e76c5b1aa585134c306463856541cd5d"
    sha256 cellar: :any_skip_relocation, big_sur:        "61c8a6df5c11d21710883abaa6c4b558172a2088e0d87d23434bf99de5424ca5"
    sha256 cellar: :any_skip_relocation, catalina:       "20aeb0c7193edac6567f06966e8f57aeed9e4e80b9e13b7f02572074359b191a"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "7c90f91622fd3f6d958b0cc36af8657badac4ea97e5781b6b5a83e8ee24df3ea"
  end

  depends_on "python@3.10"

  resource "astroid" do
    url "https://files.pythonhosted.org/packages/ee/9b/b1d4515d1a969e96954d888df4e274d487c277812573ccbbb137109b066e/astroid-2.9.0.tar.gz"
    sha256 "5939cf55de24b92bda00345d4d0659d01b3c7dafb5055165c330bc7c568ba273"
  end

  resource "isort" do
    url "https://files.pythonhosted.org/packages/ab/e9/964cb0b2eedd80c92f5172f1f8ae0443781a9d461c1372a3ce5762489593/isort-5.10.1.tar.gz"
    sha256 "e8443a5e7a020e9d7f97f1d7d9cd17c88bcb3bc7e218bf9cf5095fe550be2951"
  end

  resource "lazy-object-proxy" do
    url "https://files.pythonhosted.org/packages/bb/f5/646893a04dcf10d4acddb61c632fd53abb3e942e791317dcdd57f5800108/lazy-object-proxy-1.6.0.tar.gz"
    sha256 "489000d368377571c6f982fba6497f2aa13c6d1facc40660963da62f5c379726"
  end

  resource "mccabe" do
    url "https://files.pythonhosted.org/packages/06/18/fa675aa501e11d6d6ca0ae73a101b2f3571a565e0f7d38e062eec18a91ee/mccabe-0.6.1.tar.gz"
    sha256 "dd8d182285a0fe56bace7f45b5e7d1a6ebcbf524e8f3bd87eb0f125271b8831f"
  end

  resource "platformdirs" do
    url "https://files.pythonhosted.org/packages/4b/96/d70b9462671fbeaacba4639ff866fb4e9e558580853fc5d6e698d0371ad4/platformdirs-2.4.0.tar.gz"
    sha256 "367a5e80b3d04d2428ffa76d33f124cf11e8fff2acdaa9b43d545f5c7d661ef2"
  end

  resource "toml" do
    url "https://files.pythonhosted.org/packages/be/ba/1f744cdc819428fc6b5084ec34d9b30660f6f9daaf70eead706e3203ec3c/toml-0.10.2.tar.gz"
    sha256 "b3bda1d108d5dd99f4a20d24d9c348e91c4db7ab1b749200bded2f839ccbe68f"
  end

  resource "wrapt" do
    url "https://files.pythonhosted.org/packages/eb/f6/d81ccf43ac2a3c80ddb6647653ac8b53ce2d65796029369923be06b815b8/wrapt-1.13.3.tar.gz"
    sha256 "1fea9cd438686e6682271d36f3481a9f3636195578bab9ca3382e2f5f01fc185"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    (testpath/"pylint_test.py").write <<~EOS
      print('Test file'
      )
    EOS
    system bin/"pylint", "--exit-zero", "pylint_test.py"
  end
end
