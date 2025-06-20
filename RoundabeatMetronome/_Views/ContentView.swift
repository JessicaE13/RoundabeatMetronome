import SwiftUI
import AVFoundation

// MARK: - Navigation State
enum NavigationTab: String, CaseIterable {
    case sounds = "Sounds"
    case songs = "Songs"
    case metronome = "Metronome"
    case settings = "Settings"
    
    var iconName: String {
        switch self {
        case .sounds:
            return "speaker.wave.3"
        case .songs:
            return "music.note.list"
        case .metronome:
            return "metronome"
        case .settings:
            return "gear"
        }
    }
}

// MARK: - Bottom Navigation Bar
struct BottomNavigationBar: View {
    @Binding var selectedTab: NavigationTab
    
    // Get screen dimensions directly
    private var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    // Check if device is iPad
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        HStack {
            ForEach(NavigationTab.allCases, id: \.self) { tab in
                Button(action: {
                    selectedTab = tab
                }) {
                    VStack(spacing: isIPad ? 8 : 6) {
                        Image(systemName: tab.iconName)
                            .font(.system(size: isIPad ? 22 : 20, weight: .medium))
                            .foregroundColor(selectedTab == tab ? .accentColor : .secondary)
                        
                        Text(tab.rawValue)
                            .font(.system(size: isIPad ? 12 : 10, weight: .medium))
                            .foregroundColor(selectedTab == tab ? .accentColor : .secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, isIPad ? 20 : 16)
        .padding(.horizontal, sectionPadding)
        .background(
            Color(.systemBackground)
                .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: -1)
        )
    }
    
    // MARK: - Responsive Properties
    
    private var sectionPadding: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 32 :
                   screenWidth <= 834 ? 40 :
                   screenWidth <= 1024 ? 48 :
                   56
        } else {
            return screenWidth <= 320 ? 12 :
                   screenWidth <= 375 ? 16 :
                   screenWidth <= 393 ? 20 :
                   22
        }
    }
}

// MARK: - Flash Overlay View
struct FlashOverlay: View {
    let isFlashing: Bool
    
    var body: some View {
        Rectangle()
            .fill(Color.white)
            .opacity(isFlashing ? 0.8 : 0.0)
            .ignoresSafeArea()
            .allowsHitTesting(false) // Allow touches to pass through
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var metronome = MetronomeEngine()
    @State private var selectedTab: NavigationTab = .metronome
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                BackgroundView()
                
                VStack(spacing: 0) {
                    // Main content area - this will now always leave space for the navigation bar
                    Group {
                        switch selectedTab {
                        case .sounds:
                            SoundsView(metronome: metronome)
                        case .songs:
                            SongsView(metronome: metronome)
                        case .metronome:
                            MetronomeView(metronome: metronome)
                        case .settings:
                            SettingsView(metronome: metronome)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // Bottom navigation - always visible
                    BottomNavigationBar(selectedTab: $selectedTab)
                }
                
                // Flash overlay - appears on top of everything
                FlashOverlay(isFlashing: metronome.isFlashing)
            }
            .preferredColorScheme(.dark)
        }
        .onDisappear {
            metronome.isPlaying = false
        }
        .ignoresSafeArea(.container, edges: .bottom)
    }
}

// MARK: - SwiftUI Preview
#Preview {
    ContentView()
}
