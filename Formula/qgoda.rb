class Qgoda < Formula
  desc "Static site generator with built-in multi-language support"
  homepage "https://www.qgoda.net"
  url "https://github.com/gflohr/qgoda/archive/refs/tags/v0.10.1.tar.gz"
  sha256 "aa965da037f1f6be1708204de7d8fa2e22aa124cc7668dae4bce6d13314efea1"
  license "GPL-3.0-or-later"
  revision 2

  depends_on "cpanminus" => :build
  depends_on "node" => :build
  depends_on "perl"

  def install
    # ENV.deparallelize  # if your formula fails when building in parallel
    ENV.prepend_create_path "PERL5LIB", libexec/"lib/perl5"
    ENV.prepend_path "PERL5LIB", libexec/"lib"

    # The HEAD of the main branch contains is okay here.
    system "git", "clone", "https://github.com/gflohr/JavaScript-Duktape-XS.git"
    chdir "JavaScript-Duktape-XS" do
      system "perl", "Makefile.PL",
        "INSTALL_BASE=#{libexec}",
        "INSTALLSITEMAN1DIR=#{man1}",
        "INSTALLSITEMAN3DIR=#{man3}"
      system "make"
      system "make", "install"
    end
    system "rm", "-rf", "JavaScript-Duktape-XS"

    # And here.
    system "git", "clone", "https://github.com/gflohr/AnyEvent-Filesys-Watcher.git"
    chdir "AnyEvent-Filesys-Watcher" do
      system "cpanm", "--local-lib", "#{libexec}", "--notest", "."
    end
    system "rm", "-rf", "AnyEvent-Filesys-Watcher"

    ENV["QGODA_PACKAGE_MANAGER"] = Formula["npm"].libexec/"bin/npm"
    system "cpanm", "--local-lib", "#{libexec}", "--notest", "--installdeps", "."

    system "perl", "Makefile.PL",
      "INSTALL_BASE=#{libexec}",
      "INSTALLSITEMAN1DIR=#{man1}",
      "INSTALLSITEMAN3DIR=#{man3}"
    system "make"
    system "make", "install"

    bin.install "bin/qgoda"
    bin.env_script_all_files(libexec/"bin", PERL5LIB: ENV["PERL5LIB"])
  end

  test do
    (testpath/"index.html").write("<h1>Hello, world!</h1")
    system "#{bin}/program", "--quiet", "build"
    assert_path_exists testpath/"_site/index.html"
    assert_path_exists testpath/"_timestamp"
  end
end
