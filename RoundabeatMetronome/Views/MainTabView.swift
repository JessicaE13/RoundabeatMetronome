import SwiftUI

// MARK: - Main Tab View with Persistence
struct MainTabView: View {
    @StateObject private var metronome = MetronomeEngine()
    @State private var selectedTab = 1 // Always start on metronome tab
    
    var body: some View {
        ZStack {
            // Content area
            VStack(spacing: 0) {
                // Main content
                ZStack {
                    switch selectedTab {
                    case 0:
                        SoundsView(metronome: metronome)
                       
                    case 1:
                        ContentView(metronome: metronome)
                        
                    case 2:
                        SettingsView(metronome: metronome)
                        
                    default:
                        ContentView(metronome: metronome) // Also ensure default case shows ContentView
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Bottom Tab Bar - fixed to bottom
                bottomTabBar
            }
        }
        .ignoresSafeArea(.all, edges: .all)
        .onAppear {
            // Always start on the metronome tab
            selectedTab = 1
            print("📱 App launched - always starting on Metronome tab")
        }
    }
    
    private var bottomTabBar: some View {
        VStack(spacing: 0) {
            // Subtle top border
            Rectangle()
                .fill(Color.white.opacity(0.25))
                .frame(height: 0.5)
            
            HStack(spacing: 0) {
    
                
                // Sounds Tab Button
                tabButton(imageName: "speaker.wave.2", title: "Sounds", tab: 0)
                
                // Metronome Tab Button
                tabButton(imageName: "metronome", title: "Metronome", tab: 1)
                
                // Settings Tab Button
                tabButton(imageName: "gearshape", title: "Settings", tab: 2)
            }
            .padding(.top, 8)
            .padding(.bottom, 8)
            .background(
                // Dark background matching the app theme
                LinearGradient(
                    colors: [
                        Color(red: 28/255, green: 28/255, blue: 29/255),
                        Color(red: 24/255, green: 24/255, blue: 25/255)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
    
    // Helper function to create tab buttons
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
                Image(systemName: imageName)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(selectedTab == tab ? Color.white.opacity(0.9) : Color.white.opacity(0.5))
                    .shadow(color: Color.white.opacity(0.1), radius: 0.5, x: 0, y: 0)
                
                Text(title)
                    .font(.custom("Kanit-Medium", size: 10))
                    .kerning(0.5)
                    .foregroundColor(selectedTab == tab ? Color.white.opacity(0.8) : Color.white.opacity(0.4))
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
