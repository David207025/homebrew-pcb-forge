class Pcbfapi < Formula
  desc "PCBF API is the background task used by the PCB-Forge VS-Code extension. This API manages the PDF creation and BOM storage/generation"
  homepage "https://github.com/David207025/PCB-Forge.git"
  version "0.3.0"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/David207025/PCB-Forge/releases/download/v0.3.0/pcbfapi-aarch64-apple-darwin.tar.xz"
      sha256 "b6d253cdaae1c0a955d09c00644fe7e094f1539a29ff071bc728090c4a13b469"
    end
    if Hardware::CPU.intel?
      url "https://github.com/David207025/PCB-Forge/releases/download/v0.3.0/pcbfapi-x86_64-apple-darwin.tar.xz"
      sha256 "ee4aaaac522f02c4f1529af0df0503239ffb5ae8bd15ba66ff61b81affe5fa49"
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

  def post_install
    (var/"log").mkpath
    begin
      system "#{opt_bin}/pcbfapi", "service", "install"
    rescue
      nil
    end
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
end
