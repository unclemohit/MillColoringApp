// Contains toggle options, shows progress text and a progress bar,
// and includes the "Color code" button.

import SwiftUI

struct ColorToggle: View {
    
    //Binding changes to the data automatically update the view
    @Binding var showBlue: Bool
    @Binding var showPink: Bool
    @Binding var showWhite: Bool
    @Binding var progressText: String
    @Binding var isProcessing: Bool
    @Binding var inputVideoPath: String
    
    @Binding var qualityResult: String  

    
    //This view simply calls startProcessing() when the user taps a button.
    //It doesn't care what exactly that function does; it just knows that it should trigger some processing.
    var startProcessing: () -> Void

    @State private var showDetails: Bool = false  // ← toggle for full log

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            GroupBox(label: Text("Select Colors to Process")
                .font(.title3)
                .bold()
            ) {
                VStack(alignment: .leading, spacing: 10) {
                    
                    // Row 1: Show Blue
                    HStack {
                        Text("Select Blue")
                            .font(.headline)
                        Spacer()
                        Toggle("", isOn: $showBlue)
                            .toggleStyle(SwitchToggleStyle(tint: .green))
                    }
                    
                    // Row 2: Show Pink
                    HStack {
                        Text("Select Pink")
                            .font(.headline)
                        Spacer()
                        Toggle("", isOn: $showPink)
                            .toggleStyle(SwitchToggleStyle(tint: .green))
                    }
                    
                    // Row 3: Show White...no show, should be select eh!
                    HStack {
                        Text("Select White")
                            .font(.headline)
                        Spacer()
                        Toggle("", isOn: $showWhite)
                            .toggleStyle(SwitchToggleStyle(tint: .green))
                    }
                }
                .padding()
            }
            .padding(.vertical, 8)


            
            Divider()
            
            
          

            
            // Only show the progress text and bar when processing is running.
            if isProcessing {
                VStack(alignment: .leading, spacing: 8) {
                    Text(progressText)
                        .font(.title2) // You can change this to .headline, .title2, etc.
                        .foregroundColor(.primary)
                    
                    //call to helper fn below
                    if let progressValue = extractProgress(from: progressText) {
                        
                        //ProgressView is a built-in swiftui view that displays a progress bar
                        ProgressView(value: progressValue)
                            .progressViewStyle(LinearProgressViewStyle())
                    }
                }
            }
            
            if !qualityResult.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Video Quality Check:")
                        .font(.headline)
                    ScrollView {
                        Text(qualityResult)
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(.secondary)
                            .padding(6)
                    }
                    .frame(maxHeight: 150)
                    .background(Color(.systemGray))
                    .cornerRadius(8)
                }
            }



            
            
            
            HStack {
                Spacer()
                Button(isProcessing ? "Processing..." : "Color Code") {
                    startProcessing()
                }
                .font(.title2)
                .buttonStyle(.borderedProminent)
                .tint(.blue)  // Choose a prominent color for the primary action.
                .disabled(isProcessing || inputVideoPath.isEmpty)
                Spacer()
            }
        }
        .padding()
    }
    
    // optional double here if it cant parse correctly
    func extractProgress(from text: String) -> Double? {
        // Split the text by newline and use the first line.
        
        //?? text part is a fallback: if for some reason there is no newline in the text
        //(and the array is empty), it will use the original text itself.
        
        let firstLine = text.components(separatedBy: "\n").first ?? text
        let components = firstLine.components(separatedBy: " ")
        
        //This is important because we expect the first element to be a label (e.g., "Progress:")
        //and the second element to be the percentage value (e.g., "45%").
        if components.count >= 2 {
            
            let percentageString = components[1].trimmingCharacters(in: CharacterSet(charactersIn: "%"))
            if let percent = Double(percentageString) {
                // Convert to an integer to remove any decimals.
                return Double(Int(percent)) / 100.0
            }
        }
        return nil
    }//this is what it parses from "Progress: 45% | Time Remaining: 54s"

}

#Preview {
    ColorToggle(
        showBlue: .constant(true),
        showPink: .constant(true),
        showWhite: .constant(true),
        progressText: .constant("Progress: 45%"),
        isProcessing: .constant(true),
        inputVideoPath: .constant("example.mov"),
        qualityResult: .constant("quality"),
        startProcessing: {}
    )
}
