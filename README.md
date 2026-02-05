# PunchyAudio

A macOS menu bar audio visualizer that reacts to system audio in real time.

![macOS](https://img.shields.io/badge/macOS-13%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)

## Features

- **Menu bar visualizer** — live 6-bar mini spectrum directly in the macOS menu bar
- **Full-screen window** — four colorful visualization modes:
  - **Bars** — rainbow gradient frequency bars with glow
  - **Wave** — layered flowing bezier curves
  - **Circles** — concentric pulsing rings with radial bars
  - **Mirror** — symmetrical bars growing from center
- **System audio capture** — visualizes any app's audio (Spotify, browsers, etc.)
- **Auto-gain control** — automatically adjusts sensitivity for any volume level

## Requirements

- macOS 13 (Ventura) or later
- Swift 5.9+
- Screen Recording permission (required by ScreenCaptureKit for system audio)

## Installation

### Using .dmg file
Just open Releases, download newest dmg file and drag it into the Applications folder.

### Build from source

```bash
git clone <repo-url>
cd "Audio Visualizer"
chmod +x build.sh
./build.sh
```

### Run

```bash
open PunchyAudio.app
```

On first launch, macOS will prompt for **Screen Recording** permission. Grant it in **System Settings → Privacy & Security → Screen Recording**, then relaunch the app.

## License

MIT
