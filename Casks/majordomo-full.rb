# Homebrew cask for Majordomo Full (built from this repo).
#
# `version` and `sha256` are managed by scripts/release-cask.sh — do not edit by
# hand. This file is the canonical copy; on release it is synced into the public
# `homebrew-majordomo` tap repo, alongside the plain `majordomo` cask built from
# the public repo (see docs/DISTRIBUTION.md).
cask "majordomo-full" do
  version "1.0.109"
  sha256 "4c516666e335524d904316874e3400fb2eb1afd9a446e8f1904b5518a03a4e8b"

  # Versioned filename on purpose: a stable URL lets Cloudflare serve the PREVIOUS
  # release from cache under the new checksum, which fails every install until the
  # edge expires. A fresh path per release cannot be stale.
  url "https://files.majordomo.pomr.uk/Majordomo-Full-#{version}.zip"
  name "Majordomo Full"
  desc "Local menu-bar Whisper speech-to-text (full edition)"
  homepage "https://majordomo.pomr.uk/"

  # Same app name and bundle id as the plain cask — two editions of one program,
  # not two programs. Pick one; Homebrew refuses the second.
  conflicts_with cask: "majordomo"
  depends_on arch: :arm64
  depends_on macos: :sequoia

  app "Majordomo.app"

  # Ad-hoc signed, not notarized. Homebrew quarantines installed apps by default,
  # which trips Gatekeeper's "could not verify… is free of malware" block. Strip
  # the quarantine flag so the app opens normally.
  # Homebrew 7: declarative steps, run in a sandbox — the app bundle must be named writable.
  postflight_steps do
    run "/usr/bin/xattr",
        args:           ["-dr", "com.apple.quarantine", "{{appdir}}/Majordomo.app"],
        must_succeed:   false,
        writable_paths: ["{{appdir}}/Majordomo.app"]
  end

  # The cask must not touch launchd. Launch-at-login is owned entirely by the app
  # (a user LaunchAgent it loads/unloads itself, no privileges). Homebrew's
  # `launchctl:` and `delete:` uninstall directives both escalate to `sudo`, so
  # either would prompt for a password on every upgrade. Just quit the app.
  uninstall quit: "pl.wild-matrix.majordomo"

  zap trash: [
    "~/Library/Application Support/pl.wild-matrix.majordomo",
    "~/Library/LaunchAgents/pl.wild-matrix.majordomo.plist",
    "~/Library/Preferences/pl.wild-matrix.majordomo.plist",
  ]

  caveats <<~EOS
    Majordomo needs Microphone and Accessibility permissions
    (System Settings → Privacy & Security) to record and insert text.

    Whisper models (~0.8–3 GB) download on first use into ~/.models and are
    NOT removed by `brew uninstall --zap`. Delete that folder manually if you
    want to reclaim the space.
  EOS
end
