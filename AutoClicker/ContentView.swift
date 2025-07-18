import SwiftUI

struct ContentView: View {
    @ObservedObject var clickManager = ClickManager()
    
    var body: some View {
        VStack(spacing: 16) {
            Text(clickManager.isIntervalMode ? "every \(Int(clickManager.interval)) second(s)" : "\(Int(clickManager.clicksPerSecond)) per second")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            Button(clickManager.isRunning ? "Stop" : "Start") {
                clickManager.toggleClicking()
            }
            .font(.title)
            .frame(width: 120, height: 60)
            .background(clickManager.isRunning ? Color.red : Color.green)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            HStack(spacing: 12) {
                Button("-") {
                    clickManager.decreaseRate()
                }
                .font(.title)
                
                Text(clickManager.isIntervalMode ? "\(Int(clickManager.interval))" : "\(Int(clickManager.clicksPerSecond))")
                    .frame(width: 30)
                
                Button("+") {
                    clickManager.increaseRate()
                }
                .font(.title)
            }
            .padding(.bottom, 6)

            ProgressView(value: clickManager.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .frame(width: 120)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .frame(width: 200)
        .onTapGesture(count: 2) {
            clickManager.selectTargetPoint()
        }
    }
}
