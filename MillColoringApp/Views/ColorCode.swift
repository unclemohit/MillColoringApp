//Displays the color coded video with a "Save" button.

import SwiftUI
import AVKit

struct ColorCode: View {
    
    //these ? imply that there might not be a video stored here
    var player: AVPlayer?
    var processedVideoURL: URL?

    var body: some View {
        
        VStack {
            if let player = player {
                VideoPlayer(player: player)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                    .onAppear { player.playImmediately(atRate: 1.0) }
            }
            else
            {
                Text("Processed video will appear here")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            if processedVideoURL != nil {
                Button("Save") {
                    saveProcessedVideo()
                }
                .font(.title2)
                    .buttonStyle(.borderedProminent)
                    .tint(.green)  
                    .padding(.top)
            }
        }
        .padding()
    }
    
    // Save video
    private func saveProcessedVideo() {
        //guard prevents running of the further if false
        guard let sourceURL = processedVideoURL else { return }
        let panel = NSSavePanel()
        panel.allowedFileTypes = ["mp4"]
        panel.nameFieldStringValue = sourceURL.lastPathComponent
        panel.begin { response in
            if response == .OK, let destinationURL = panel.url {
                do {
                    try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
                    print("Video saved to \(destinationURL.path)")
                } catch {
                    print("Error saving video: \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    ColorCode(player: nil, processedVideoURL: nil)
}


