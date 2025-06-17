import SwiftUI

// MARK: - Settings View
struct SettingsView: View {
    @ObservedObject var metronome: MetronomeEngine
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
                                .fixedSize(horizontal: true, vertical: false) // Prevents wrapping
                        }
                        
                        Spacer()
                        Toggle("", isOn: $metronome.accentFirstBeat)
                    }
                    .padding(.vertical, 4)
                }
                
                // Visual Settings Section - Moved up
                Section("Visual Options") {
                    
                    // Emphasize First Beat Only Toggle
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Emphasize First Beat")
                                .font(.body)
                            Text("Beat 1 is solid, others are outlined")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: true, vertical: false) // Prevents wrapping
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
                                .fixedSize(horizontal: true, vertical: false)
                            Text("Flash entire screen on beat 1")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: true, vertical: false) // Prevents wrapping
                        }
                        Spacer()
                        Toggle("", isOn: $metronome.fullScreenFlashOnFirstBeat)
                    }
                    .padding(.vertical, 4)
                    

                }
                
                // Audio Session Settings Section - Title changed and headphones disconnect section removed
                Section("App Settings") {
                    // Background Audio Toggle
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Background Audio")
                                .font(.body)
                            Text("Continue playing when app is in background")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: true, vertical: false)
                        }
                        Spacer()
                        Toggle("", isOn: $metronome.backgroundAudioEnabled)
                    }
                    .padding(.vertical, 4)
                    
                    // Pause on Interruption Toggle
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Pause on Interruption")
                                .font(.body)
                            Text("Stop when phone calls or other apps interrupt")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: true, vertical: false)
                        }
                        Spacer()
                        Toggle("", isOn: $metronome.pauseOnInterruption)
                    }
                    .padding(.vertical, 4)
                    
                    // Keep Screen Awake Toggle
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Stay Awake")
                                .font(.body)
                            Text("Prevent phone from sleeping while playing")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: true, vertical: false) // Prevents wrapping
                        }
                        Spacer()
                        Toggle("", isOn: $metronome.keepScreenAwake)
                    }
                    .padding(.vertical, 4)
                    
                
                }
   
                
                // Legal & Support Section
                Section("SUPPORT") {
                    Link(destination: URL(string: "mailto:hello@roundabeat.com")!) {
                        SettingsLinkRow(
                            title: "Feedback",
                            subtitle: "Suggest features & ask questions",
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
                
                // App Info Section
                Section("App Info") {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("App Version")
                                .font(.body)
                            Text("Roundabeat \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        
                    }
                    .padding(.vertical, 4)
                    // Audio Status Information (Read-only)
                    AudioStatusInfoView(metronome: metronome)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)


        }
        .navigationViewStyle(StackNavigationViewStyle()) // Prevents split view on iPad


    }
    
}


// MARK: - Audio Status Information View
struct AudioStatusInfoView: View {
    @ObservedObject var metronome: MetronomeEngine
    
    var body: some View {
        VStack(spacing: 8) {
            // Current Audio Status
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Current Audio Status")
                        .font(.body)
                        .fontWeight(.medium)
                    Text("Real-time audio session information")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            // Status indicators
            VStack(spacing: 4) {
                // External Audio Status
                HStack {
                    Image(systemName: metronome.isUsingExternalAudio ? "headphones" : "speaker.wave.2")
                        .foregroundColor(metronome.isUsingExternalAudio ? .blue : .secondary)
                        .font(.caption)
                    
                    Text(metronome.isUsingExternalAudio ? "External Audio Connected" : "Using Built-in Speaker")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                
                // Interruption Status
                if metronome.isAudioInterrupted {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.orange)
                            .font(.caption)
                        
                        Text("Audio Session Interrupted")
                            .font(.caption)
                            .foregroundColor(.orange)
                        
                        Spacer()
                        
                        // Resume button if interrupted and not auto-resuming
                        if metronome.pauseOnInterruption {
                            Button("Resume") {
                                metronome.resumeAfterInterruption()
                            }
                            .font(.caption)
                            .buttonStyle(.bordered)
                            .controlSize(.mini)
                        }
                    }
                }
                
                // Background Audio Status
                HStack {
                    Image(systemName: metronome.backgroundAudioEnabled ? "music.note" : "music.note.tv")
                        .foregroundColor(metronome.backgroundAudioEnabled ? .green : .secondary)
                        .font(.caption)
                    
                    Text(metronome.backgroundAudioEnabled ? "Background Audio Enabled" : "Foreground Only")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                
                // Screen Awake Status
                HStack {
                    Image(systemName: metronome.keepScreenAwake ? "sun.max" : "moon")
                        .foregroundColor(metronome.keepScreenAwake ? .yellow : .secondary)
                        .font(.caption)
                    
                    Text(metronome.keepScreenAwake ? "Screen Stays Awake While Playing" : "Normal Sleep Behavior")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
            .padding(.leading, 16)
        }
        .padding(.vertical, 4)
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
                    .fixedSize(horizontal: true, vertical: false) // Prevents wrapping
            }
            Spacer()
            Image(systemName: iconName)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    SettingsView(metronome: MetronomeEngine())
}
