import SwiftUI

struct SettingsView: View {
    @ObservedObject var clickController: ClickController
    @Environment(\.presentationMode) var presentationMode

    @State private var isClickModesExpanded = true
    @State private var isClickLimitExpanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with consistent styling
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.primary) // Apple's adaptive gray
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.thickMaterial) // Same as ContentView buttons
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(.white.opacity(0.3), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                }
                .buttonStyle(.plain)

                Text("Settings")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.primary) // Apple's adaptive gray

                Spacer()
            }

            // Click Modes Group with ContentView styling
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: isClickModesExpanded ? "chevron.down" : "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Click Modes")
                        .font(.headline.weight(.medium))
                        .foregroundColor(.primary)
                }
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isClickModesExpanded.toggle()
                    }
                }
                
                if isClickModesExpanded {
                    VStack(alignment: .leading, spacing: 12) {
                        settingRow(title: "Double Click Mode", binding: $clickController.isDoubleClickEnabled)
                        settingRow(title: "Smart Delay", binding: $clickController.isSmartDelayEnabled)
                    }
                    .padding(.leading, 16)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.thickMaterial) // Same as ContentView
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
            )

            // Click Limit Group with ContentView styling
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: isClickLimitExpanded ? "chevron.down" : "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Click Limit")
                        .font(.headline.weight(.medium))
                        .foregroundColor(.primary)
                }
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isClickLimitExpanded.toggle()
                    }
                }
                
                if isClickLimitExpanded {
                    VStack(alignment: .leading, spacing: 12) {
                        settingRow(title: "Enable Limit", binding: $clickController.isClickLimitEnabled)

                        if clickController.isClickLimitEnabled {
                            HStack {
                                Text("Max Clicks")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                HStack(spacing: 8) {
                                    Button("-") {
                                        if clickController.maxClicks > 1 {
                                            clickController.maxClicks -= 1
                                        }
                                    }
                                    .font(.title3)
                                    .foregroundColor(.primary)
                                    .padding(6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(.regularMaterial)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(.white.opacity(0.2), lineWidth: 1)
                                            )
                                    )
                                    .buttonStyle(.plain)
                                    
                                    Text("\(clickController.maxClicks)")
                                        .font(.body.weight(.medium))
                                        .foregroundColor(.primary)
                                        .frame(minWidth: 40)
                                    
                                    Button("+") {
                                        if clickController.maxClicks < 10000 {
                                            clickController.maxClicks += 1
                                        }
                                    }
                                    .font(.title3)
                                    .foregroundColor(.primary)
                                    .padding(6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(.regularMaterial)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(.white.opacity(0.2), lineWidth: 1)
                                            )
                                    )
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.leading, 16)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.thickMaterial) // Same as ContentView
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
            )

            Spacer()
        }
        .padding(20) // Same padding as ContentView
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.thickMaterial) // Same as ContentView background
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 8)
        )
        .frame(width: 280) // Slightly wider for better content fit
        .foregroundColor(.primary) // Apple's adaptive gray as default
//        .background(Color.clear)
    }

    // Reusable setting toggle row with ContentView styling
    private func settingRow(title: String, binding: Binding<Bool>) -> some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.primary) // Apple's adaptive gray
            Spacer()
            Toggle("", isOn: binding)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: .accentColor)) // Use system accent color
        }
    }
}
