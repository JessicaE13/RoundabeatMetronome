import SwiftUI

// MARK: - Theme Manager
@Observable
class ThemeManager {
    var colorScheme: ColorScheme? = .dark // Default to dark mode
    
    var isDarkMode: Bool {
        get { return colorScheme == .dark }
        set { colorScheme = newValue ? .dark : .light }
    }
    
    var displayName: String {
        return isDarkMode ? "Dark" : "Light"
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
                    // Dark Mode Toggle
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Dark Mode")
                                .font(.body)
                            Text("Use dark appearance")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Toggle("", isOn: $themeManager.isDarkMode)
                    }
                    .padding(.vertical, 4)
                    
                    // Visual Metronome Toggle
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Visual Metronome")
                                .font(.body)
                            Text("Show visual beat indicators")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Toggle("", isOn: $metronome.visualMetronome)
                    }
                    .padding(.vertical, 4)
                    
                    // Emphasize First Beat Only Toggle
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Emphasize First Beat Only")
                                .font(.body)
                            Text("Only highlight beat 1 visually")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Toggle("", isOn: $metronome.emphasizeFirstBeatOnly)
                    }
                    .padding(.vertical, 4)
                    
                    // Full Screen Flash Toggle
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Full Screen Flash on First Beat")
                                .font(.body)
                            Text("Flash entire screen on beat 1")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Toggle("", isOn: $metronome.fullScreenFlashOnFirstBeat)
                    }
                    .padding(.vertical, 4)
                }
                
                // Legal & Support Section
                Section("About") {
                    Link(destination: URL(string: "mailto:hello@roundabeat.com")!) {
                        SettingsLinkRow(
                            title: "Email",
                            subtitle: "Get help with the app",
                            iconName: "envelope"
                        )
                    }

                    Link(destination: URL(string: "https://roundabeat.com/roundabeat-mobile-app-terms-of-use/")!) {
                        SettingsLinkRow(
                            title: "Terms of Use",
                            subtitle: "View our terms and conditions",
                            iconName: "arrow.up.right"
                        )
                    }
                    
                    Link(destination: URL(string: "https://roundabeat.com/mobile-app-privacy-policy/")!) {
                        SettingsLinkRow(
                            title: "Privacy Policy",
                            subtitle: "How we handle your data",
                            iconName: "arrow.up.right"
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
    let iconName: String
    
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
            Image(systemName: iconName)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    SettingsView(metronome: MetronomeEngine(), themeManager: ThemeManager())
}
