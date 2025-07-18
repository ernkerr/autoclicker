import SwiftUI

struct ContentView: View {
    @ObservedObject var clickController = ClickController.shared
    
    // Custom colors
    let darkGrey = Color(white: 0.2)      // dark grey text
    let lightGrey = Color(white: 0.6)     // lighter grey text
    
    var body: some View {
        VStack(spacing: 16) {
            // 🎯 Target selector with tooltip
            HStack {
                Button(action: {
                    clickController.selectTarget()
                }) {
                    Image(systemName: "scope")
                        .font(.title2)
                        .foregroundColor(.white)
                        .help("Select a target")
                        .contentShape(Rectangle()) // easier to hover on small icon
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)

            // Mode Label (main info)
            Text(clickController.isIntervalMode ?
                 "every \(Int(clickController.interval)) second(s)" :
                 "\(Int(clickController.clicksPerSecond)) per second"
            )
            .font(.caption)
            .foregroundColor(darkGrey)
            
            // Start/Stop button (plain text)
            Button(clickController.isRunning ? "Stop" : "Start") {
                clickController.toggleClicking()
            }
            .font(.title2)
            .foregroundColor(clickController.isRunning ? .red : .green)
            .buttonStyle(PlainButtonStyle())  // remove any button background / border
            
            // Rate controls
            HStack(spacing: 12) {
                Button("-") {
                    clickController.decreaseRate()
                }
                .font(.title2)
                .foregroundColor(darkGrey)

                Text(clickController.isIntervalMode ?
                     "\(Int(clickController.interval))" :
                     "\(Int(clickController.clicksPerSecond))"
                )
                .frame(width: 30)
                .foregroundColor(lightGrey)

                Button("+") {
                    clickController.increaseRate()
                }
                .font(.title2)
                .foregroundColor(darkGrey)
            }
            .padding(.bottom, 6)
            
            // Progress bar
            ProgressView(value: clickController.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: darkGrey))
                .frame(width: 120)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .frame(width: 200)
    }
}
