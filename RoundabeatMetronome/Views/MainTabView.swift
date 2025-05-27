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
            .frame(maxHeight: .infinity)
            
            // Custom Tab Bar with NumberPadView styling
            HStack(spacing: 12) {
                // Metronome Tab Button
                tabButton(imageName: "metronome", title: "Beat", tab: 0)
                
                Spacer().frame(width: 8)
                
                // Sounds Tab Button
                tabButton(imageName: "speaker.wave.2", title: "Sounds", tab: 1)
                
                Spacer().frame(width: 8)
                
                // Colors Tab Button
                tabButton(imageName: "paintpalette", title: "Theme", tab: 2)
                
                Spacer().frame(width: 8)
                
                // Settings Tab Button
                tabButton(imageName: "gearshape", title: "Settings", tab: 3)
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 15)
            .background(
                // Base shape with black fill matching NumberPadView
                RoundedRectangle(cornerRadius: 35)
                    .fill(Color.black.opacity(0.95))
                    .overlay(
                        // Outer stroke with gradient matching NumberPadView
                        RoundedRectangle(cornerRadius: 35)
                            .inset(by: 0.5)
                            .stroke(LinearGradient(
                                gradient: Gradient(colors: [Color.white.opacity(0.2), Color.white.opacity(0.15)]),
                                startPoint: .top,
                                endPoint: .bottomTrailing)
                            )
                    )
            )
            .frame(maxWidth: 340, maxHeight: 80)
            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
            .padding(.bottom, 30)
            .padding(.horizontal, 20)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    // Helper function to create tab buttons with NumberPadView styling
    private func tabButton(imageName: String, title: String, tab: Int) -> some View {
        Button(action: {
            selectedTab = tab
            
            // Add haptic feedback like NumberPadView
            if #available(iOS 10.0, *) {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.5)
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: imageName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(selectedTab == tab ? Color.white.opacity(0.9) : Color.white.opacity(0.6))
                    .shadow(color: Color.white.opacity(0.1), radius: 0.5, x: 0, y: 0)
                
                Text(title)
                    .font(.custom("Kanit-Medium", size: 11))
                    .kerning(0.5)
                    .foregroundColor(selectedTab == tab ? Color.white.opacity(0.8) : Color.white.opacity(0.5))
            }
            .frame(width: 60, height: 50)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(selectedTab == tab ? Color.white.opacity(0.15) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(
                                selectedTab == tab ?
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                ) :
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0.15), Color.white.opacity(0.05)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1
                            )
                    )
            )
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
