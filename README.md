# PunchyAudio

A macOS menu bar audio visualizer that reacts to system audio in real time.

![macOS](https://img.shields.io/badge/macOS-13%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)

<img width="279" height="277" alt="Screenshot 2026-02-06 at 00 10 45" src="https://github.com/user-attachments/assets/e8d47995-ee3e-44a3-ae4a-051ef7c15770" />
<img width="279" height="288" alt="Screenshot 2026-02-06 at 00 11 06" src="https://github.com/user-attachments/assets/2cc9debb-af65-49f1-84d6-87a7f3e22a53" />
<img width="279" height="288" alt="Screenshot 2026-02-06 at 00 11 14" src="https://github.com/user-attachments/assets/46aa6bb1-f145-450a-b7a1-46635732d747" />

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
