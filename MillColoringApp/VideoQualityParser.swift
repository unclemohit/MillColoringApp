import Foundation

class VideoQualityParser {
    var shortSummary: String = ""
    var fullLog: String = ""
    
    func parse(rawLog: String) {
        DispatchQueue.main.async {
            self.shortSummary = ""
            self.fullLog = rawLog
        }

        let lines = rawLog.components(separatedBy: .newlines)
        var summaryLines: [String] = []

        for line in lines {
            
            if line.contains("Detection skipped.") ||
               line.contains("Medium quality") ||
               line.contains("Good video") ||
               line.contains("Proceeding with detection.") {
                summaryLines.append(line)
            }


            if line.contains("Resolution") || line.contains("FPS") {
                summaryLines.append(line)
            }

            if line.contains("Consider recording at higher FPS") ||
               line.contains("Ultra-smooth source detected") ||
               line.contains("Low resolution") ||
               line.contains("Short video") {
                summaryLines.append(line)
            }
        }

        DispatchQueue.main.async {
            self.shortSummary = summaryLines.joined(separator: "\n")
        }
    }

    
    
}

