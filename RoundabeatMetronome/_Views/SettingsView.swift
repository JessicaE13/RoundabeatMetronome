import SwiftUI

// MARK: - Settings View
struct SettingsView: View {
    @ObservedObject var metronome: MetronomeEngine
    @Environment(\.colorScheme) var currentColorScheme
    @State private var showingInfoPopup: InfoType? = nil
    
    enum InfoType: String, CaseIterable {
        case accentFirstBeat = "accent_first_beat"
        case emphasizeFirstBeat = "emphasize_first_beat"
        case fullScreenFlash = "full_screen_flash"
        case backgroundAudio = "background_audio"
        case pauseOnInterruption = "pause_on_interruption"
        case stayAwake = "stay_awake"
        
        var title: String {
            switch self {
            case .accentFirstBeat: return "Accent First Beat"
            case .emphasizeFirstBeat: return "Emphasize First Beat"
            case .fullScreenFlash: return "Flash Screen on First Beat"
            case .backgroundAudio: return "Background Audio"
            case .pauseOnInterruption: return "Pause on Interruption"
            case .stayAwake: return "Stay Awake"
            }
        }
        
        var description: String {
            switch self {
            case .accentFirstBeat:
                return "First beat plays with higher pitch"
            case .emphasizeFirstBeat:
                return "First beat shows solid, others outlined"
            case .fullScreenFlash:
                return "Screen flashes on first beat"
            case .backgroundAudio:
                return "Continues playing when app is in background"
            case .pauseOnInterruption:
                return "Stops for calls and other audio interruptions"
            case .stayAwake:
                return "Prevents screen from sleeping while playing"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Audio Settings Section
                Section("Sound Options") {
                    SettingsToggleRow(
                        title: "Higher Pitch on First Beat",
                        isOn: $metronome.accentFirstBeat,
                        infoType: .accentFirstBeat, // Set to nil to remove info button
                        showingInfoPopup: $showingInfoPopup
                    )
                }
                
                // Visual Settings Section
                Section("Visual Options") {
                    SettingsToggleRow(
                        title: "Flash Screen on First Beat",
                        isOn: $metronome.fullScreenFlashOnFirstBeat,
                        infoType: .fullScreenFlash, // Set to nil to remove info button
                        showingInfoPopup: $showingInfoPopup
                    )
                    SettingsToggleRow(
                    title: "Outline Offbeats",
                    isOn: $metronome.emphasizeFirstBeatOnly,
                    infoType: .emphasizeFirstBeat, // Set to nil to remove info button
                    showingInfoPopup: $showingInfoPopup
                )
                }
                
                // App Settings Section
                Section("App Settings") {
                    SettingsToggleRow(
                        title: "Background Audio",
                        isOn: $metronome.backgroundAudioEnabled,
                        infoType: .backgroundAudio, // Set to nil to remove info button
                        showingInfoPopup: $showingInfoPopup
                    )
                    
                    SettingsToggleRow(
                        title: "Pause on Interruption",
                        isOn: $metronome.pauseOnInterruption,
                        infoType: .pauseOnInterruption, // Set to nil to remove info button
                        showingInfoPopup: $showingInfoPopup
                    )
                    
                    SettingsToggleRow(
                        title: "Stay Awake",
                        isOn: $metronome.keepScreenAwake,
                        infoType: .stayAwake, // Set to nil to remove info button
                        showingInfoPopup: $showingInfoPopup
                    )
                }
                
                // Legal & Support Section
                Section("SUPPORT") {
                    Link(destination: URL(string: "mailto:hello@roundabeat.com")!) {
                        SettingsLinkRow(
                            title: "Suggest features & send feedback",
                            iconName: "envelope"
                        )
                    }

                    Link(destination: URL(string: "https://roundabeat.com/mobile-app-terms-of-use/")!) {
                        SettingsLinkRow(
                            title: "Terms of Use",
                            iconName: "arrow.up.right"
                        )
                    }
                    
                    Link(destination: URL(string: "https://roundabeat.com/mobile-app-privacy-policy/")!) {
                        SettingsLinkRow(
                            title: "Privacy Policy",
                            iconName: "arrow.up.right"
                        )
                    }
                }
                
                // App Info Section
                Section("App Info") {
                    HStack {
                        Text("App Version")
                            .font(.body)
                        Spacer()
                        Text("Roundabeat \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                    
                    // Audio Status Information (Read-only)
                    AudioStatusInfoView(metronome: metronome)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert(item: Binding<AlertItem?>(
                get: { showingInfoPopup.map { AlertItem(infoType: $0) } },
                set: { _ in showingInfoPopup = nil }
            )) { alertItem in
                Alert(
                    title: Text(alertItem.infoType.title),
                    message: Text(alertItem.infoType.description),
                    dismissButton: .default(Text("Got it"))
                )
            }
        }
        .preferredColorScheme(.dark)
        .navigationViewStyle(StackNavigationViewStyle())

    }
}

// MARK: - Alert Item for Info Popups
struct AlertItem: Identifiable {
    let id = UUID()
    let infoType: SettingsView.InfoType
}

// MARK: - Settings Toggle Row with Info Button
struct SettingsToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    let infoType: SettingsView.InfoType?
    @Binding var showingInfoPopup: SettingsView.InfoType?
    
    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.body)
                .lineLimit(1)
                .fixedSize(horizontal: false, vertical: true)
            
            if let infoType = infoType {
                Button(action: {
                    showingInfoPopup = infoType
                }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14))
                }
                .buttonStyle(PlainButtonStyle())
                .frame(width: 20, height: 20)
            }
            
            Spacer(minLength: 20)
            
            Toggle("", isOn: $isOn)
                .frame(width: 51) // Standard toggle width
                .toggleStyle(CustomToggleStyle())
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Custom Toggle Style with AccentColor Background
struct CustomToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            
            Spacer()
            
            RoundedRectangle(cornerRadius: 16)
                .fill(configuration.isOn ? Color("AccentColor") : Color.secondary.opacity(0.3))
                .frame(width: 51, height: 31)
                .overlay(
                    Circle()
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.15), radius: 1, x: 0, y: 1)
                        .frame(width: 27, height: 27)
                        .offset(x: configuration.isOn ? 10 : -10)
                        .animation(.easeInOut(duration: 0.2), value: configuration.isOn)
                )
                .onTapGesture {
                    configuration.isOn.toggle()
                }
        }
    }
}
// MARK: - Audio Status Information View
struct AudioStatusInfoView: View {
    @ObservedObject var metronome: MetronomeEngine
    
    var body: some View {
        VStack(spacing: 8) {
            // Current Audio Status
            HStack {
                Text("Current Audio Status")
                    .font(.body)
                    .fontWeight(.medium)
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
                        .foregroundColor(metronome.backgroundAudioEnabled ? Color("AccentColor") : .secondary)
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
    let iconName: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)
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
