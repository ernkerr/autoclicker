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
                        .padding(8)
                }

                Text("Settings")
                    .font(.title2)
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

            // Click Limit Group
            DisclosureGroup("Click Limit", isExpanded: $isClickLimitExpanded) {
                VStack(alignment: .leading, spacing: 18) {
                    settingRow(title: "Enable Limit", binding: $clickController.isClickLimitEnabled)

                    if isClickLimitExpanded && clickController.isClickLimitEnabled {
                        Stepper("Max Clicks: \(clickController.maxClicks)", value: $clickController.maxClicks, in: 1...10_000)
                            .font(.body)
                            .padding(.leading, 4)
                            .padding(.top, 4)
                    }
                }
                .padding(.top, 6)
            }

            Spacer()
        }
        .padding()
        .frame(width: 300)
    }

    // Reusable setting toggle row
    private func settingRow(title: String, binding: Binding<Bool>) -> some View {
        HStack {
            Text(title)
                .font(.body)
            Spacer()
            Toggle("", isOn: binding)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: .blue))
        }
    }
}
