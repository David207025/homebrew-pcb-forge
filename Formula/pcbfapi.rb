class Pcbfapi < Formula
  desc "Background API service for PCB Forge KiCad integration"
  homepage "https://github.com/David207025/PCB-Forge.git"
  version "0.3.0"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/David207025/PCB-Forge/releases/download/v0.3.0/pcbfapi-aarch64-apple-darwin.tar.xz"
      sha256 "f913fed6b3c54c4828c6c223243f457783424726fa81386ca4d178fda94c0e09"
    end
    if Hardware::CPU.intel?
      url "https://github.com/David207025/PCB-Forge/releases/download/v0.3.0/pcbfapi-x86_64-apple-darwin.tar.xz"
      sha256 "028febdb10b5859111a7865e5b3a06d01eb351aca73acfe811d75cb5b66d9a4b"
    end
  end

  BINARY_ALIASES = {
    "aarch64-apple-darwin":  {},
    "x86_64-apple-darwin":   {},
    "x86_64-pc-windows-gnu": {},
  }.freeze

  def target_triple
    cpu = Hardware::CPU.arm? ? "aarch64" : "x86_64"
    os = OS.mac? ? "apple-darwin" : "unknown-linux-gnu"

    "#{cpu}-#{os}"
  end

  def install_binary_aliases!
    BINARY_ALIASES[target_triple.to_sym].each do |source, dests|
      dests.each do |dest|
        bin.install_symlink bin/source.to_s => dest
      end
    end
  end

  def install
    if OS.mac? && Hardware::CPU.arm?
      bin.install "pcbfapi"
    end
    if OS.mac? && Hardware::CPU.intel?
      bin.install "pcbfapi"
    end

    install_binary_aliases!

    # Homebrew will automatically install these, so we don't need to do that
    doc_files = Dir["README.*", "readme.*", "LICENSE", "LICENSE.*", "CHANGELOG.*"]
    leftover_contents = Dir["*"] - doc_files

    # Install any leftover files in pkgshare; these are probably config or
    # sample files.
    pkgshare.install(*leftover_contents) unless leftover_contents.empty?
  end

  service do
    run [opt_bin/"pcbfapi", "run"]
    keep_alive true
    run_type :immediate
    environment_variables PATH: std_service_path_env
    error_log_path var/"log/pcbfapi.err.log"
    log_path var/"log/pcbfapi.log"
    working_dir var
  end

  def caveats
    <<~EOS
      pcbfapi runs as a persistent background daemon service.
      It starts automatically at boot/login.

      To manage with brew services:
        brew services start pcbfapi
        brew services stop pcbfapi
        brew services restart pcbfapi

      To verify KiCad file and CLI access:
        pcbfapi check-access
    EOS
  end

  test do
    assert_predicate bin/"pcbfapi", :executable?
  end
end
