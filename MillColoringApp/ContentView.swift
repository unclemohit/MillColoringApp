//Calls all other views in one place

import SwiftUI
import AVKit

struct ContentView: View {
    @StateObject var talkToPy = TalkToPy() // Your processing logic object
    @State private var qualityResult: String = ""


    var body: some View {
        NavigationSplitView {
        
            FilePicker(inputVideoPath: $talkToPy.inputVideoPath)
                .navigationTitle("Video")
            
        }
        //these are bindings $talkToPy
        content: {
            ColorToggle(
                showBlue:       $talkToPy.showBlue,
                showPink:       $talkToPy.showPink,
                showWhite:      $talkToPy.showWhite,
                progressText:   $talkToPy.progressText,
                isProcessing:   $talkToPy.isProcessing,
                inputVideoPath: $talkToPy.inputVideoPath,
                qualityResult:  .constant(talkToPy.qualityParser.shortSummary),

                startProcessing: { talkToPy.startProcessing() }
            )
            .navigationTitle("MOLYCOP")
        }
        
        detail: {
            ColorCode(
                player: talkToPy.player,
                processedVideoURL: talkToPy.processedVideoURL
            )
            .navigationTitle("Preview")
        }
        .frame(minWidth: 800, minHeight: 600)
        .navigationSplitViewStyle(.balanced)
    }
}

#Preview {
    ContentView()
}
