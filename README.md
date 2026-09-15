<p align="center">
    <img src=".github/caffeinate.png" alt="caffeinate" width="40%" />
</p>
<p align="center">
    <b>caffeinate</b>
</p>
<p align="center">
    A tiny macOS menu bar app that keeps your Mac awake, built around the<br/>
    <code>/usr/bin/caffeinate</code> tool that already ships with the system.
</p>

## Motivation

macOS has been able to stay awake for years — `caffeinate` is right there in
`/usr/bin`. What is missing is a switch. That is the whole app.

- **One job.** Keep the Mac awake, and nothing else. No window, no preferences,
  no onboarding, no updater, no account.
- **No background work.** The app *is* the switch: `caffeinate` runs exactly as
  long as the app runs, and quitting the app ends it in the same moment. No
  daemon, no helper, nothing left behind.
- **Native and small.** Plain AppKit around a tool you already have: a 4 MB app
  with no bundled runtime and no network access.

## Install

### Homebrew

```sh
brew tap evg4b/tap
brew install --cask caffeinate
xattr -dr com.apple.quarantine /Applications/caffeinate.app
```

Homebrew quarantines everything it downloads, and since Homebrew 7 there is no
`--no-quarantine` flag to opt out. The app is signed ad-hoc rather than with a
Developer ID, so macOS refuses to open it until that flag is cleared.

Later, `brew upgrade --cask caffeinate` updates it and `brew uninstall --cask
caffeinate` removes it (add `--zap` to drop the saved options too).

### From the releases page

Download `caffeinate.zip` from the
[latest release](https://github.com/evg4b/caffeinate/releases/latest), unzip it
and drag `caffeinate.app` into `/Applications`. Then clear the quarantine flag
macOS puts on every download:

```sh
xattr -dr com.apple.quarantine /Applications/caffeinate.app
```

The Finder route works too: open the app, let macOS block it, then allow it
under System Settings → Privacy & Security → Open Anyway.

### From source

```sh
xcodebuild -project caffeinate.xcodeproj \
    -scheme caffeinate \
    -configuration Release \
    -derivedDataPath build \
    build
cp -R build/Build/Products/Release/caffeinate.app /Applications/
```

Locally built apps are never quarantined, so this one just opens.

### After installing

On first launch macOS asks once whether the app may send notifications. To keep
it running after every login, add it under System Settings → General → Login
Items & Extensions.

To uninstall a copy that Homebrew did not install:

```sh
rm -rf /Applications/caffeinate.app
defaults delete evg4b.caffeinate
```

## Usage

**Left click** the menu bar icon to quit. **Right click** it to pick what to
keep awake — the choice is remembered between launches.

| Menu item                          | `caffeinate` flag |
| ---------------------------------- | ----------------- |
| Prevent display sleep              | `-d`              |
| Prevent system idle sleep          | `-i`              |
| Prevent disk idle sleep            | `-m`              |
| Prevent system sleep (on AC power) | `-s`              |

Display and idle sleep are on by default; with nothing ticked `caffeinate` still
runs on its own default of no idle sleep. A banner appears when it starts and
when it stops. The menu follows the system language, in 30 of them.
