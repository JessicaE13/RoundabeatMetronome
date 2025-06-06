import SwiftUI

// MARK: - Main Tab View with Device-Adaptive Layout
struct MainTabView: View {
    @StateObject private var metronome = MetronomeEngine()
    @State private var selectedTab = 1 // Always start on metronome tab
    
    var body: some View {
        GeometryReader { geometry in
           
            let tabBarHeight: CGFloat = 70 // Calculate tab bar height
            
            ZStack {
                // Content area
                VStack(spacing: 0) {
                    // Main content with proper bottom padding for tab bar
                    ZStack {
                        switch selectedTab {
                        case 0:
                            SoundsView(metronome: metronome)
                                .padding(.bottom, tabBarHeight) // Add padding to prevent overlap
                           
                        case 1:
                            MetronomeView(metronome: metronome)
                                .padding(.bottom, tabBarHeight) // Add padding to prevent overlap
                            
                        case 2:
                            SettingsView(metronome: metronome)
                                .padding(.bottom, tabBarHeight) // Add padding to prevent overlap
                            
                        default:
                            MetronomeView(metronome: metronome)
                              //  .padding(.bottom, tabBarHeight) // Add padding to prevent overlap
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                 //   Spacer() // Push tab bar to bottom
                }
                
                // Bottom Tab Bar - positioned at bottom with proper safe area handling
                VStack {
                    Spacer() // Push to bottom
                    bottomTabBar(geometry: geometry)
                }
            }
        }
      //  .ignoresSafeArea(.all, edges: [.top, .leading, .trailing]) // Only ignore top, leading, trailing - preserve bottom safe area
        .onAppear {
            // Always start on the metronome tab
            selectedTab = 1
            print("📱 App launched - always starting on Metronome tab")
        }
    }
    
    private func bottomTabBar(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            // Consistent top border that works in both light and dark mode
            Rectangle()
                .fill(Color(red: 0.3, green: 0.3, blue: 0.3))
                .frame(height: 0.5)
            
            HStack(spacing: 0) {
                // Sounds Tab Button
                tabButton(
                    imageName: "speaker.wave.2",
                    title: "Sounds",
                    tab: 0
                )
                
                // Metronome Tab Button
                tabButton(
                    imageName: "metronome",
                    title: "Metronome",
                    tab: 1
                )
                
                // Settings Tab Button
                tabButton(
                    imageName: "gearshape",
                    title: "Settings",
                    tab: 2
                )
            }
            .padding(.top, 8)
            .padding(.bottom, max(geometry.safeAreaInsets.bottom, 8)) // Respect safe area
            .background(
                // Dark background matching the app theme
                LinearGradient(
                    colors: [
                        Color(red: 15/255, green: 15/255, blue: 15/255),
                        Color(red: 5/255, green: 5/255, blue: 5/255)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
    
    // Helper function to create adaptive tab buttons
    private func tabButton(imageName: String, title: String, tab: Int) -> some View {
        Button(action: {
            selectedTab = tab // Switch tabs but don't persist
            
            // Add haptic feedback
            if #available(iOS 10.0, *) {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.5)
            }
            
            print("📱 Switched to tab \(tab) (\(title))")
        }) {
            VStack(spacing: 4) {
                Group {
                    if selectedTab == tab {
                        Image(systemName: imageName)
                            .font(.system(size: 20, weight: .medium))
                            .glowingAccent(intensity: 0.4)
                    } else {
                        Image(systemName: imageName)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.5))
                    }
                }
                .shadow(color: Color.white.opacity(0.1), radius: 0.5, x: 0, y: 0)
                
                Text(title)
                    .font(.system(size: 10))
                    .kerning(0.5)
                    .foregroundColor(selectedTab == tab ? Color.white.opacity(0.8) : Color.white.opacity(0.9))
            }
            .frame(maxWidth: .infinity, maxHeight: 50)
            .contentShape(Rectangle())
        }
        .scaleEffect(selectedTab == tab ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: selectedTab)
    }
}

// MARK: - Preview
#Preview {
    MainTabView()
        .preferredColorScheme(.dark)
}
