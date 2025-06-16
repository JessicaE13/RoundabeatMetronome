import SwiftUI

// MARK: - Theme Manager
@Observable
class ThemeManager {
    var colorScheme: ColorScheme? = .dark
    
    var isSystemDefault: Bool {
        return colorScheme == nil
    }
    
    var isDarkMode: Bool {
        return colorScheme == .dark
    }
    
    var isLightMode: Bool {
        return colorScheme == .light
    }
    
    func setSystemDefault() {
        colorScheme = nil
    }
    
    func setDarkMode() {
        colorScheme = .dark
    }
    
    func setLightMode() {
        colorScheme = .light
    }
    
    var displayName: String {
        switch colorScheme {
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        case nil:
            return "System"
        @unknown default:
            return "System"
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @ObservedObject var metronome: MetronomeEngine
    @Bindable var themeManager: ThemeManager
    @Environment(\.colorScheme) var currentColorScheme
    
    var body: some View {
        NavigationView {
            Form {
                // Audio Settings Section
                Section("Sound Options") {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Accent First Beat")
                                .font(.body)
                            Text("Higher pitch on beat 1")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Toggle("", isOn: $metronome.accentFirstBeat)
                    }
                    .padding(.vertical, 4)
                }
                
                // Visual Settings Section
                Section("Visual Options") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Appearance")
                                    .font(.body)
                                Text("Choose light, dark, or system theme")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        
                        // Theme Selection Picker
                        Picker("Appearance", selection: Binding(
                            get: {
                                if themeManager.isSystemDefault { return 0 }
                                else if themeManager.isLightMode { return 1 }
                                else { return 2 }
                            },
                            set: { value in
                                switch value {
                                case 0: themeManager.setSystemDefault()
                                case 1: themeManager.setLightMode()
                                case 2: themeManager.setDarkMode()
                                default: themeManager.setSystemDefault()
                                }
                            }
                        )) {
                            Text("System").tag(0)
                            Text("Light").tag(1)
                            Text("Dark").tag(2)
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.vertical, 4)
                }
                
                // Legal & Support Section
                Section("About") {
                    Link(destination: URL(string: "mailto:hello@roundabeat.com")!) {
                        SettingsLinkRow(
                            title: "Email",
                            subtitle: "Get help with the app"
                        )
                    }

                    Link(destination: URL(string: "https://roundabeat.com/roundabeat-mobile-app-terms-of-use/")!) {
                        SettingsLinkRow(
                            title: "Terms of Use",
                            subtitle: "View our terms and conditions"
                        )
                    }
                    
                    Link(destination: URL(string: "https://roundabeat.com/mobile-app-privacy-policy/")!) {
                        SettingsLinkRow(
                            title: "Privacy Policy",
                            subtitle: "How we handle your data"
                        )
                    }
                    
                }
                
                // System Information Section
//                Section("System Information") {
//                    SettingsInfoRow(title: "Audio Engine", value: "AVAudioSourceNode")
//                    SettingsInfoRow(title: "Timing Method", value: "Sample-accurate")
//                    SettingsInfoRow(title: "Precision", value: "±1 sample (~0.02ms)")
//                    SettingsInfoRow(title: "Sample Rate", value: "48 kHz")
//                    SettingsInfoRow(title: "Buffer Size", value: "2ms target")
//                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Prevents split view on iPad
    }
}

// MARK: - Supporting Views
struct SettingsInfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

struct SettingsLinkRow: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "arrow.up.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    SettingsView(metronome: MetronomeEngine(), themeManager: ThemeManager())
}
