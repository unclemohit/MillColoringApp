
# MillColoringApp

A macOS desktop application that analyzes videos of round beads inside a rotating industrial mill.  
It detects bead sizes and colors, then generates a color-coded video overlay to visualize and track bead movement.

---

## 🚀 Tech Stack

- **Python (OpenCV)** — Video analysis logic (`pycodeforapp.py`)
- **SwiftUI (macOS)** — User interface with:
  - `ContentView` and 3 additional view files
- **Python–Swift Bridge** — `TalkToPy.swift` handles calling Python from Swift

---

## 🛠 Usage

### Clone the repository

```bash
git clone https://github.com/yourusername/MillColoringApp.git
cd MillColoringApp
```

### Build & Run in Xcode

- Open `MillColoringApp.xcodeproj` in Xcode.
- Press `Cmd + R` to build and run.

**OR**

- In Xcode, go to `Product > Show Build Folder in Finder`.
- Locate the generated `.app` file and double-click to run.

---

## ⚙️ Environment

✅ **No extra setup needed.**  
Python and all required packages are bundled with the app.

---

## 📂 Project Structure

```
MillColoringApp/
├── MillColoringApp/
│   ├── Preview Content/
│   ├── Views/
│   │   ├── ColorCode.swift
│   │   ├── ColorToggle.swift
│   │   └── FilePicker.swift
│   ├── Assets.xcassets
│   ├── ContentView.swift
│   ├── MillColoringApp.swift
│   ├── TalkToPy.swift
│   └── VideoQualityParser.swift
├── env/
│   ├── bin/
│   ├── lib/
│   └── scripts/
│       ├── pycodeforapp.py
│       └── video_quality_checker.py
├── .gitignore
└── README.md
```

---

## ✨ Features

- Detects and classifies bead sizes and colors in mill videos.
- Overlays color-coded highlights on processed video frames.
- Simple macOS GUI to select and process videos.

---

## ✅ Notes

- Currently tested on macOS with Xcode 14+.
- If you encounter any issues, please open an issue or PR.

---

## 🚀 License

MIT License. See `LICENSE` for details.

---

### 🙌 Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you’d like to change.



