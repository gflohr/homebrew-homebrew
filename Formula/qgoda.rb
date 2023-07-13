class Qgoda < Formula
	desc "Static site generator with built-in multi-language support"
	homepage "https://www.qgoda.net"
	url "file:///Users/guidoflohr/perl/qgoda/Qgoda-v0.10.0.tar.gz"
	sha256 "6a6d896a5e1672a7981503a469b032b9ed5b31ef7ee8be26f564b0e570635483"
	license "GPL-3.0-or-later"

	depends_on "cpanminus" => :build
	depends_on "node" => :build
	depends_on "perl"

	def install
		# ENV.deparallelize	# if your formula fails when building in parallel
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
			system "cpanm", "--local-lib", "#{libexec}", "--notest", "--installdeps", "."
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

		bin.env_script_all_files(libexec/"bin", PERL5LIB: ENV["PERL5LIB"])
	end

	test do
		(testpath/"index.html").write("<h1>Hello, world!</h1")
		system "#{bin}/program", "--quiet", "build"
		assert_path_exists testpath/"_site/index.html"
		assert_path_exists testpath/"_timestamp"
	end
end
