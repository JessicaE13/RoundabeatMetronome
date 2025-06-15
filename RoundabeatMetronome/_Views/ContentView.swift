import SwiftUI
import AVFoundation

// MARK: - Navigation State
enum NavigationTab: String, CaseIterable {
    case metronome = "Metronome"
    case sounds = "Sounds"
    case settings = "Settings"
    
    var iconName: String {
        switch self {
        case .metronome:
            return "metronome"
        case .sounds:
            return "speaker.wave.2"
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

// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var metronome = MetronomeEngine()
    @State private var selectedTab: NavigationTab = .metronome
    @State private var themeManager = ThemeManager()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                BackgroundView()
                
                VStack(spacing: 0) {
                    // Main content area - this will now always leave space for the navigation bar
                    Group {
                        switch selectedTab {
                        case .metronome:
                            MetronomeView(metronome: metronome)
                        case .sounds:
                            SoundsView(metronome: metronome)
                        case .settings:
                            SettingsView(metronome: metronome, themeManager: themeManager)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // Bottom navigation - always visible
                    BottomNavigationBar(selectedTab: $selectedTab)
                }
            }
            .preferredColorScheme(themeManager.colorScheme)
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
