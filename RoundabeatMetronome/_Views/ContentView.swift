import SwiftUI
import AVFoundation

// MARK: - Navigation State (Updated)
enum NavigationTab: String, CaseIterable {
    case sounds = "Sounds"
    case library = "Library"  // Combined Songs + Setlists
    case metronome = "Metronome"
    case settings = "Settings"
    
    var iconName: String {
        switch self {
        case .sounds:
            return "speaker.wave.3"
        case .library:
            return "books.vertical"  // New icon for combined library
        case .metronome:
            return "metronome"
        case .settings:
            return "gear"
        }
    }
}

// MARK: - Bottom Navigation Bar (Updated)
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
                    VStack(spacing: isIPad ? 6 : 4) {
                        Image(systemName: tab.iconName)
                            .font(.system(size: isIPad ? 20 : 18, weight: .medium))
                            .foregroundColor(selectedTab == tab ? .accentColor : .secondary)
                        
                        Text(tab.rawValue)
                            .font(.system(size: isIPad ? 11 : 9, weight: .medium))
                            .foregroundColor(selectedTab == tab ? .accentColor : .secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, isIPad ? 18 : 14)
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

// MARK: - Flash Overlay View (Unchanged)
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

// MARK: - Main Content View (Updated)
struct ContentView: View {
    @StateObject private var metronome = MetronomeEngine()
    @StateObject private var songManager = SongManager()
    @StateObject private var setlistManager = SetlistManager()
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
                        case .library:  // Updated case
                            LibraryView(
                                metronome: metronome,
                                songManager: songManager,
                                setlistManager: setlistManager
                            )
                        case .metronome:
                            MetronomeView(metronome: metronome, songManager: songManager)
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
        .onAppear {
            // Initialize sample data if none exists
            if songManager.songs.isEmpty {
                songManager.addSampleSongs()
            }
            if setlistManager.setlists.isEmpty {
                setlistManager.createSampleSetlists(with: songManager)
            }
        }
        // Monitor metronome changes and validate selected song
        .onChange(of: metronome.bpm) { oldValue, newValue in
            songManager.validateSelectedSongAgainstMetronome(metronome: metronome)
        }
        .onChange(of: metronome.beatsPerMeasure) { oldValue, newValue in
            songManager.validateSelectedSongAgainstMetronome(metronome: metronome)
        }
        .onChange(of: metronome.beatUnit) { oldValue, newValue in
            songManager.validateSelectedSongAgainstMetronome(metronome: metronome)
        }
    }
}

// MARK: - SwiftUI Preview
#Preview {
    ContentView()
}
