class Cppcheck < Formula
  desc "Static analysis of C and C++ code"
  homepage "https://sourceforge.net/projects/cppcheck/"
  url "https://github.com/danmar/cppcheck/archive/2.6.2.tar.gz"
  sha256 "a11602c15bf951ba5bb67655ca6c06986ec64770d8004759a8c53db013286a5e"
  license "GPL-3.0-or-later"
  head "https://github.com/danmar/cppcheck.git", branch: "main"

  bottle do
    sha256 arm64_monterey: "418c14f59b8d49cd92a2de7b5c4b0e893e76a2597bd8789a50c6a7a5e4ff5d69"
    sha256 arm64_big_sur:  "1a3052dacdf2a1df70b1114d938a31fda279e1d612d6b6b5d086551d4d4a26e7"
    sha256 monterey:       "accad7769ff41bdeeb72cac7b9ba1f569c8aa41739865b10ae0a0996a81218ef"
    sha256 big_sur:        "34cb3e3f3ffa98d28f44f1e9d45d5b11318d4e0cabf9edc3e2a0b0b29ca4a62e"
    sha256 catalina:       "185448ec2623f7025ed897171b861ac7404c2fe645f63c3898512de457a7493c"
    sha256 x86_64_linux:   "a1eb6e452a5b90850394c773e53ebe8974644d9dfa9e978a95f90154e38bf6dd"
  end

  depends_on "cmake" => :build
  depends_on "python@3.9" => [:build, :test]
  depends_on "pcre"
  depends_on "tinyxml2"

  uses_from_macos "libxml2"

  def install
    args = std_cmake_args + %W[
      -DHAVE_RULES=ON
      -DUSE_MATCHCOMPILER=ON
      -DUSE_BUNDLED_TINYXML2=OFF
      -DENABLE_OSS_FUZZ=OFF
      -DPYTHON_EXECUTABLE=#{Formula["python@3.9"].opt_bin}/python3
    ]
    system "cmake", "-S", ".", "-B", "build", *args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    # Move the python addons to the cppcheck pkgshare folder
    (pkgshare/"addons").install Dir.glob("addons/*.py")
  end

  test do
    # Execution test with an input .cpp file
    test_cpp_file = testpath/"test.cpp"
    test_cpp_file.write <<~EOS
      #include <iostream>
      using namespace std;

      int main()
      {
        cout << "Hello World!" << endl;
        return 0;
      }

      class Example
      {
        public:
          int GetNumber() const;
          explicit Example(int initialNumber);
        private:
          int number;
      };

      Example::Example(int initialNumber)
      {
        number = initialNumber;
      }
    EOS
    system "#{bin}/cppcheck", test_cpp_file

    # Test the "out of bounds" check
    test_cpp_file_check = testpath/"testcheck.cpp"
    test_cpp_file_check.write <<~EOS
      int main()
      {
      char a[10];
      a[10] = 0;
      return 0;
      }
    EOS
    output = shell_output("#{bin}/cppcheck #{test_cpp_file_check} 2>&1")
    assert_match "out of bounds", output

    # Test the addon functionality: sampleaddon.py imports the cppcheckdata python
    # module and uses it to parse a cppcheck dump into an OOP structure. We then
    # check the correct number of detected tokens and function names.
    addons_dir = pkgshare/"addons"
    cppcheck_module = "#{name}data"
    expect_token_count = 55
    expect_function_names = "main,GetNumber,Example"
    assert_parse_message = "Error: sampleaddon.py: failed: can't parse the #{name} dump."

    sample_addon_file = testpath/"sampleaddon.py"
    sample_addon_file.write <<~EOS
      #!/usr/bin/env #{Formula["python@3.9"].opt_bin}/python3
      """A simple test addon for #{name}, prints function names and token count"""
      import sys
      from importlib import machinery, util
      # Manually import the '#{cppcheck_module}' module
      spec = machinery.PathFinder().find_spec("#{cppcheck_module}", ["#{addons_dir}"])
      cpp_check_data = util.module_from_spec(spec)
      spec.loader.exec_module(cpp_check_data)

      for arg in sys.argv[1:]:
          # Parse the dump file generated by #{name}
          configKlass = cpp_check_data.parsedump(arg)
          if len(configKlass.configurations) == 0:
              sys.exit("#{assert_parse_message}") # Parse failure
          fConfig = configKlass.configurations[0]
          # Pick and join the function names in a string, separated by ','
          detected_functions = ','.join(fn.name for fn in fConfig.functions)
          detected_token_count = len(fConfig.tokenlist)
          # Print the function names on the first line and the token count on the second
          print("%s\\n%s" %(detected_functions, detected_token_count))
    EOS

    system "#{bin}/cppcheck", "--dump", test_cpp_file
    test_cpp_file_dump = "#{test_cpp_file}.dump"
    assert_predicate testpath/test_cpp_file_dump, :exist?
    output = shell_output(Formula["python@3.9"].opt_bin/"python3 #{sample_addon_file} #{test_cpp_file_dump}")
    assert_match "#{expect_function_names}\n#{expect_token_count}", output
  end
end
