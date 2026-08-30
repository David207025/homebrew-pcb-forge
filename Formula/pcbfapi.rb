class Pcbfapi < Formula
  desc "PCBF API is the background task used by the PCB-Forge VS-Code extension. This API manages the PDF creation and BOM storage/generation"
  homepage "https://github.com/David207025/PCB-Forge.git"
  version "0.3.0"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/David207025/PCB-Forge/releases/download/v0.3.0/pcbfapi-aarch64-apple-darwin.tar.xz"
      sha256 "feab77132cb0528e463693ef3099a3eb2792ce107e2907d56d7a10319b7ee1bf"
    end
    if Hardware::CPU.intel?
      url "https://github.com/David207025/PCB-Forge/releases/download/v0.3.0/pcbfapi-x86_64-apple-darwin.tar.xz"
      sha256 "775d727fcade3dd17d32858d5e61e6d8d3da038ad156a980db39fde09ee835fa"
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
end
