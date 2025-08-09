import SwiftUI

struct ContentView: View {
    @ObservedObject var clickController = ClickController.shared
    @State private var showSettings = false
    @State private var showingErrorMessage = false



    var body: some View {
        VStack(spacing: 16) {
            // 🎯 Target selector (grey, no background)
            HStack {
                Button(action: {
                    clickController.selectTarget()
                    showingErrorMessage = false

                }) {
                    Image(systemName: "scope")
                        .font(.title2)
                        .foregroundColor(Color.gray) // make target icon grey
                        .padding(6)
                }
                .buttonStyle(.plain) // remove button background/highlight

                Spacer()

                
                Button(action: {
                    showSettings = true
                }) {
                    Image(systemName: "gearshape")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .padding(6)
                }
                .buttonStyle(.plain)
                .sheet(isPresented: $showSettings) {
                    SettingsView(clickController: clickController)
                }

            }
            .frame(maxWidth: .infinity)

            // ▶️ Start/Stop with filled rectangle button
            Button(clickController.isRunning ? "Stop" : "Start") {
                clickController.toggleClicking()
            }
            .font(.title)
            .frame(width: 120, height: 60)
            .background(clickController.isRunning ? Color.red : Color.green)
            .foregroundColor(.white) // white text on colored background
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .buttonStyle(.plain) // prevent default system button styles from interfering
            
            if clickController.isRunning {
                VStack(spacing: 0) {
                    Text("Control + Option + Command + Q")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Text("to stop clicking")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .multilineTextAlignment(.center) // Center-align text inside VStack
                .frame(maxWidth: .infinity)      // Make VStack take full width
            }


            // ➕➖ Rate controls
            HStack(spacing: 12) {
                Button("-") {
                    clickController.decreaseRate()
                }
                .font(.title)
                .foregroundColor(Color.gray)
                

                Text(clickController.isIntervalMode ?
                     "\(Int(clickController.interval))" :
                     "\(Int(clickController.clicksPerSecond))"
                )
                .frame(width: 30)
                .foregroundColor(Color.gray)

                Button("+") {
                    clickController.increaseRate()
                }
                .font(.title)
                .foregroundColor(Color.gray)
            }
            .padding(.bottom, 6)
            
            
            // ⏱️ Mode Label
    
            let value = Int(clickController.isIntervalMode ? clickController.interval : clickController.clicksPerSecond)

            Text(
                clickController.isIntervalMode
                    ? "every \(value) \(value == 1 ? "second" : "seconds")"
                    : "\(value) \(value == 1 ? "per second" : "per second")"
            )
            .font(.caption)
            .foregroundColor(Color.gray.opacity(0.85))
            
            if let error = clickController.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }


            // 📊 Progress bar
            ProgressView(value: clickController.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .frame(width: 120)
        }
        .padding()
        .background(Color.white) // white background
        .cornerRadius(20)
        .frame(width: 200)
        .foregroundColor(Color.gray) // default text color grey
    }
}
