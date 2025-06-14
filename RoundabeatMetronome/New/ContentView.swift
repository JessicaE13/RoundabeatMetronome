import SwiftUI
import AVFoundation

// MARK: - Navigation State
enum NavigationTab: String, CaseIterable {
    case metronome = "Metronome"
    case settings = "Settings"
    
    var iconName: String {
        switch self {
        case .metronome:
            return "metronome"
        case .settings:
            return "gear"
        }
    }
}

// MARK: - Info Row Component
struct InfoRow: View {
    let title: String
    let value: String
    @Environment(\.deviceEnvironment) private var device
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: device.deviceType.mediumFontSize, weight: .medium))
            Spacer()
            Text(value)
                .font(.system(size: device.deviceType.mediumFontSize, weight: .regular))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Bottom Navigation Bar
struct BottomNavigationBar: View {
    @Binding var selectedTab: NavigationTab
    @Environment(\.deviceEnvironment) private var device
    
    var body: some View {
        HStack {
            ForEach(NavigationTab.allCases, id: \.self) { tab in
                Button(action: {
                    selectedTab = tab
                }) {
                    VStack(spacing: device.deviceType.isIPad ? 8 : 6) {
                        Image(systemName: tab.iconName)
                            .font(.system(size: device.deviceType.isIPad ? 22 : 20, weight: .medium))
                            .foregroundColor(selectedTab == tab ? .accentColor : .secondary)
                        
                        Text(tab.rawValue)
                            .font(.system(size: device.deviceType.isIPad ? 12 : 10, weight: .medium))
                            .foregroundColor(selectedTab == tab ? .accentColor : .secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, device.deviceType.isIPad ? 20 : 16)
        .padding(.horizontal, device.deviceType.sectionPadding)
        .background(
            Color(.systemBackground)
                .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: -1)
        )
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var metronome = MetronomeEngine()
    @State private var selectedTab: NavigationTab = .metronome
    @State private var deviceEnvironment = DeviceEnvironment()
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
            .deviceEnvironment(deviceEnvironment)
            .onAppear {
                deviceEnvironment.updateDevice(width: geometry.size.width, height: geometry.size.height)
            }
            .onChange(of: geometry.size) { _, newSize in
                deviceEnvironment.updateDevice(width: newSize.width, height: newSize.height)
            }
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
