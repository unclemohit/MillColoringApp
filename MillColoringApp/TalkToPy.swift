//Contains all processing logic

import Foundation
import AVKit
import Combine

//this class conform to ObservableObject protocol which means
//published properties can be observed by swiftui views
class TalkToPy: ObservableObject {
    @Published var inputVideoPath: String = ""
    @Published var showBlue: Bool = true
    @Published var showPink: Bool = true
    @Published var showWhite: Bool = true
    @Published var progressText: String = "Progress: 0%"
    @Published var isProcessing: Bool = false
    @Published var processedVideoURL: URL? = nil
    @Published var player: AVPlayer? = nil

    private let scriptPath: String = "/Users/mohitsingh/Desktop/mill-coloring/Mill-Colouring/pycodeforapp.py"
    private let pythonExec: String = "/opt/anaconda3/envs/millcoloring/bin/python3"
    private var outputVideoPath: String = ""

    //remmber you call this from 2nd screen that is ColorToggle
    func startProcessing() {
        guard !inputVideoPath.isEmpty else {
            progressText = "Error: no video selected."
            return
        }
        
        progressText = "Progress: 0%"
        isProcessing = true
        
        // Generate a random output video name in a temporary directory.
        let randomName = UUID().uuidString + ".mp4"
        let tempDir = NSTemporaryDirectory()
        outputVideoPath = (tempDir as NSString).appendingPathComponent(randomName)
        
        // Build command-line arguments.
        let arguments = [
            scriptPath,
            inputVideoPath,
            outputVideoPath,
            "--enable-blue", showBlue ? "true" : "false",
            "--enable-pink", showPink ? "true" : "false",
            "--enable-white", showWhite ? "true" : "false"
        ]
        
        //Process setup
        //Setting the executable to the py interpreter
        //Assigning the above constructed arguments to the process
        let task = Process()
        task.executableURL = URL(fileURLWithPath: pythonExec)
        task.arguments = arguments
        
        //Pipe for capturing output
        //Assigning  pipe to both standardOutput and standardError so that all output is handled the same way
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        var outputLog = ""
        
        //it reads the data and converts it to a string.
        //trims any extra whitespace
        //checks if the line starts with "Progress:"
        pipe.fileHandleForReading.readabilityHandler = { fileHandle in
            let data = fileHandle.availableData
            if data.isEmpty { return }
            if let line = String(data: data, encoding: .utf8) {
                let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                
                if trimmed.hasPrefix("Progress:") {
                    // helper function to format progress and time as integers.
                    let cleaned = self.parseProgressLine(trimmed)
                    DispatchQueue.main.async {
                        self.progressText = cleaned
                    }
                }
                else if
                    trimmed.hasPrefix("Estimated processing time:") ||
                          trimmed.hasPrefix("Processing Complete:") ||
                          trimmed.hasPrefix("Error:") {
                    DispatchQueue.main.async {
                        self.progressText = trimmed
                    }
                }
                else {
                    print("Python output: \(trimmed)")
                }
                outputLog.append(trimmed + "\n")
            }
        }
        
        //this is closure
        //on the main thread, it sets isProcessing to false
        //it creates a URL from the output video path
        //inits AVPlayer with 1.0 speed
        task.terminationHandler = { [weak self] _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isProcessing = false
                if outputLog.isEmpty {
                    self.progressText = "Processing complete."
                }
                let videoURL = URL(fileURLWithPath: self.outputVideoPath)
                self.processedVideoURL = videoURL
                self.player = AVPlayer(url: videoURL)
                self.player?.playImmediately(atRate: 1.0)
            }
        }
        
        do {
            try task.run()
        } catch {
            DispatchQueue.main.async {
                self.progressText = "Error starting Python script: \(error.localizedDescription)"
                self.isProcessing = false
            }
        }
    }
    
    //Parses a line like "Progress: 16.87% | Time Remaining: 53.81s"
    // to "Progress: 17% | Time Remaining: 54s"
    private func parseProgressLine(_ line: String) -> String {
        // split the line on the pipe symbol to separate progress and time.
        let parts = line.components(separatedBy: "|")
        var finalText = ""
        
        // process the progress part
        if let progressPart = parts.first
        {
            // Remove the "Progress:" label and "%" symbol.
            let cleaned = progressPart
                .replacingOccurrences(of: "Progress:", with: "")
                .replacingOccurrences(of: "%", with: "")
                .trimmingCharacters(in: .whitespaces)
            
            if let progressDouble = Double(cleaned)
            {
                let intProgress = Int(progressDouble.rounded())
                finalText = "Progress: \(intProgress)%"
            }
            else
            {
                finalText = "Progress: --%"
            }
        }
        
        // process the time
        if parts.count > 1
        {
            let timePart = parts[1].trimmingCharacters(in: .whitespaces)
            // expecting something like "Time Remaining: 53.81s"
            let timeComponents = timePart.components(separatedBy: " ")
            if timeComponents.count >= 3
            {
                let timeString = timeComponents[2].replacingOccurrences(of: "s", with: "")
                if let timeDouble = Double(timeString)
                {
                    let intTime = Int(timeDouble.rounded())
                    // Append time on a new line.
                    finalText += "\nTime Remaining: \(intTime)s"
                }
                else
                {
                    finalText += "\nTime Remaining: --s"
                }
            }
        }
        return finalText
    }

}
