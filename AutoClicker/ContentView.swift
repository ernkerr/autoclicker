import SwiftUI

struct ContentView: View {
    @ObservedObject var clickController = ClickController.shared

    var body: some View {
        VStack(spacing: 16) {
            // 🎯 Target selector (grey, no background)
            HStack {
                Button(action: {
                    clickController.selectTarget()
                }) {
                    Image(systemName: "scope")
                        .font(.title2)
                        .foregroundColor(Color.gray) // make target icon grey
                        .padding(6)
                }
                .buttonStyle(.plain) // remove button background/highlight

                Spacer()

                VStack(alignment: .leading, spacing: 6) {
                    Toggle("Double Click Mode", isOn: $clickController.isDoubleClickEnabled)
                        .toggleStyle(.switch)
                    Toggle("Smart Delay", isOn: $clickController.isSmartDelayEnabled)
                        .toggleStyle(.switch)
                }
                .padding()
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

            // ⏱️ Mode Label
            Text(clickController.isIntervalMode ?
                 "every \(Int(clickController.interval)) second(s)" :
                 "\(Int(clickController.clicksPerSecond)) per second"
            )
            .font(.caption)
            .foregroundColor(Color.gray.opacity(0.85))

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
