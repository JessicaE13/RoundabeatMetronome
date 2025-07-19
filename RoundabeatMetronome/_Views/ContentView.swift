import SwiftUI
import AVFoundation

// MARK: - Navigation State (Updated - Removed Sounds)
enum NavigationTab: String, CaseIterable {
    case library = "Library"
    case metronome = "Metronome"
    case settings = "Settings"
    
    var iconName: String {
        switch self {
        case .library:
            return "rectangle.stack.badge.play.fill"
        case .metronome:
            return "metronome"
        case .settings:
            return "slider.vertical.3"
        }
    }
}

// MARK: - Bottom Navigation Bar
struct BottomNavigationBar: View {
    @Binding var selectedTab: NavigationTab
    

    private var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
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
                            .foregroundStyle(selectedTab == tab ?
                                             AnyShapeStyle(LinearGradient(
                                                gradient: Gradient(colors: [Color("AccentColor"), Color("AccentColor").opacity(0.7)]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                             )) :
                                                AnyShapeStyle(Color("Gray1"))
                            )
                        
                        Text(tab.rawValue)
                            .font(.system(size: isIPad ? 11 : 9, weight: .medium))
                            .foregroundStyle(selectedTab == tab ?
                                             AnyShapeStyle(LinearGradient(
                                                gradient: Gradient(colors: [Color("AccentColor"), Color("AccentColor").opacity(0.7)]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                             )) :
                                                AnyShapeStyle(Color.secondary)
                            )
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
            .allowsHitTesting(false)
    }
}

// MARK: - Main Content View (Updated - Removed Sounds case)
struct ContentView: View {
    @StateObject private var metronome = MetronomeEngine()
    @StateObject private var songManager = SongManager()
    @StateObject private var setlistManager = SetlistManager()
    @State private var selectedTab: NavigationTab = .metronome
    @State private var showBanner = false
    @State private var bannerIsVisible = false

    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                BackgroundView()
                
                VStack(spacing: 0) {
                    Group {
                        switch selectedTab {
                        case .library:
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
     
                    BottomNavigationBar(selectedTab: $selectedTab)
                    
                    // 👇 Banner appears here, above nav bar, after 2 seconds
                    BannerContentView(navigationTitle: "Banner")
                        .frame(height: bannerIsVisible ? nil : 0)
                        .clipped()
                        .opacity(bannerIsVisible ? 1 : 0)
                        .animation(.easeInOut(duration: 0.4), value: bannerIsVisible)

                    
     
                }
                
                FlashOverlay(isFlashing: metronome.isFlashing)
            }
            .preferredColorScheme(.dark)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    bannerIsVisible = true
                }

                if songManager.songs.isEmpty {
                    songManager.addSampleSongs()
                }
                if setlistManager.setlists.isEmpty {
                    setlistManager.createSampleSetlists(with: songManager)
                }
            }

            .onDisappear {
                metronome.isPlaying = false
            }
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .onChange(of: metronome.bpm) { _, _ in
            songManager.validateSelectedSongAgainstMetronome(metronome: metronome)
        }
        .onChange(of: metronome.beatsPerMeasure) { _, _ in
            songManager.validateSelectedSongAgainstMetronome(metronome: metronome)
        }
        .onChange(of: metronome.beatUnit) { _, _ in
            songManager.validateSelectedSongAgainstMetronome(metronome: metronome)
        }
    }
}

// MARK: - SwiftUI Preview
#Preview {
    ContentView()
}
