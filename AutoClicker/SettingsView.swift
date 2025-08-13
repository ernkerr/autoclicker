import SwiftUI

struct SettingsView: View {
    @ObservedObject var clickController: ClickController
    @Environment(\.presentationMode) var presentationMode

    @State private var isClickModesExpanded = true
    @State private var isClickLimitExpanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(.plain)

                Text("Settings")
                    .font(.title2)
                    .foregroundColor(.white)
                    .bold()

                Spacer()
            }

            // Click Modes Group
            DisclosureGroup("Click Modes", isExpanded: $isClickModesExpanded) {
                VStack(alignment: .leading, spacing: 18) {
                    settingRow(title: "Double Click Mode", binding: $clickController.isDoubleClickEnabled)
                    settingRow(title: "Smart Delay", binding: $clickController.isSmartDelayEnabled)
                }
                .padding(.top, 6)
            }
            .foregroundColor(.white)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
            )


            // Click Limit Group
            DisclosureGroup("Click Limit", isExpanded: $isClickLimitExpanded) {
                VStack(alignment: .leading, spacing: 18) {
                    settingRow(title: "Enable Limit", binding: $clickController.isClickLimitEnabled)

                    if isClickLimitExpanded && clickController.isClickLimitEnabled {
                                           Stepper("Max Clicks: \(clickController.maxClicks)", value: $clickController.maxClicks, in: 1...10_000)
                                               .font(.body)
                                               .foregroundColor(.white)
                                               .padding(.leading, 4)
                                               .padding(.top, 4)
                                       }
                                   }
                                   .padding(.top, 6)
                               }
                               .foregroundColor(.white)
                               .padding()
                               .background(
                                   RoundedRectangle(cornerRadius: 12)
                                       .fill(.ultraThinMaterial)
                                       .overlay(
                                           RoundedRectangle(cornerRadius: 12)
                                               .stroke(.white.opacity(0.2), lineWidth: 1)
                                       )
                               )

                               Spacer()
        }
        .padding()
        .frame(width: 300)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.thinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.3), lineWidth: 1)
                )
        )
        .background(Color.clear) // Ensure transparent background
    }

    // Reusable setting toggle row
    private func settingRow(title: String, binding: Binding<Bool>) -> some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.white)
            Spacer()
            Toggle("", isOn: binding)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: .cyan)) // Match glassmorphism theme
        }
    }
}
