import SwiftUI

// MARK: - Main Tab View
struct MainTabView: View {
    @StateObject private var metronome = MetronomeEngine()
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content area
            ZStack {
                switch selectedTab {
                case 0:
                    ContentView(metronome: metronome)
                case 1:
                    Text("Sounds View")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(AppTheme.backgroundColor)
                case 2:
                    ThemeColorPicker()
                case 3:
                    SettingsView()
                default:
                    ContentView(metronome: metronome)
                }
            }
            
            // Custom Capsule Tab Bar - Now with spacing between icons
            HStack(spacing: 8) { // Added spacing between tab buttons
                // Metronome Tab Button
                tabButton(imageName: "metronome", title: "Beat", tab: 0)
                
                Spacer().frame(width: 4) // Extra spacer for more separation
                
                // Sounds Tab Button
                tabButton(imageName: "speaker.wave.2", title: "Sounds", tab: 1)
                
                Spacer().frame(width: 4) // Extra spacer for more separation
                
                // Colors Tab Button
                tabButton(imageName: "paintpalette", title: "Theme", tab: 2)
                
                Spacer().frame(width: 4) // Extra spacer for more separation
                
                // Settings Tab Button
                tabButton(imageName: "gearshape", title: "Settings", tab: 3)
            }
            .frame(width: 320, height: 60) // Slightly wider to accommodate spacing
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.7))
                    .overlay(
                        Capsule()
                            .stroke(LinearGradient(
                                gradient: Gradient(colors: [Color.white.opacity(0.6), Color.white.opacity(0.3)]),
                                startPoint: .top,
                                endPoint: .bottom)
                            )
                            .shadow(color: Color.white.opacity(0.4), radius: 4, x: 0, y: 0)
                    )
                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
            )
            .padding(.bottom, 30)
        }
        .edgesIgnoringSafeArea(.bottom) // Allow the custom tab bar to extend to the bottom edge
    }
    
    // Helper function to create tab buttons
    private func tabButton(imageName: String, title: String, tab: Int) -> some View {
        Button(action: {
            selectedTab = tab
        }) {
            VStack(spacing: 3.5) { // Increased internal spacing between icon and text
                Image(systemName: imageName)
                    .font(.system(size: 16))
                    .foregroundColor(selectedTab == tab ? Color("colorGlow") : Color.white.opacity(0.6))
                
                Text(title)
                    .font(.system(size: 10))
                    .foregroundColor(selectedTab == tab ? Color("colorGlow") : Color.white.opacity(0.6))
            }
            .frame(width: 55, height: 50) // Slightly narrower to maintain overall width
        }
    }
}

// MARK: - Preview
#Preview {
    MainTabView()
        .preferredColorScheme(.dark) // Use dark mode for preview
}
