//Provides a video selection button

import SwiftUI

struct FilePicker: View {
    @Binding var inputVideoPath: String

    var body: some View {
        GroupBox {
            Button("Choose Video") {
                pickFile { selected in
                    if let s = selected {
                        inputVideoPath = s
                    }
                }
            }
            .font(.title2)
            .buttonStyle(.borderedProminent)
           
            if !inputVideoPath.isEmpty {
                Text("Selected: \(URL(fileURLWithPath: inputVideoPath).lastPathComponent)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
    
    // File picker function using NSOpenPanel 
    func pickFile(completion: @escaping (String?) -> Void) {
        let panel = NSOpenPanel()
        panel.allowedFileTypes = ["mov", "mp4", "m4v"]
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.begin { response in
            completion(response == .OK ? panel.url?.path : nil)
        }
    }
}

#Preview {
    FilePicker(inputVideoPath: .constant("example.mov"))
}
