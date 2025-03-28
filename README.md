Mill Colouring App

Color-codes videos in a mill simulation to highlight internal processes.

Tech Stack

Python (OpenCV) for video analysis logic (pycodeforapp.py)
SwiftUI (macOS) for the app interface (3 View files and ContentView + TalkToPy.swift to bridge Python)
Usage
Clone both repos (Python logic + SwiftUI app).

	Mill-Colouring (Python repo)
	MillColoringApp (SwiftUI app)

Find pycodeforapp.py for the main logic
	pycodeforapp.py (mohit3 branch)

Setup Python environment
Install Anaconda
	conda create -n millcoloring python = 3.10
conda activate millcoloring
conda install -c conda-forge opencv
Run  which python3 and note the path

Open the SwiftUI project in Xcode
In TalkToPy.swift, update scriptPath to point to pycodeforapp.py.
Update pythonExec with the Python path from the Anaconda environment.

Build & Run in Xcode (cmd+R).

FAQ’s




