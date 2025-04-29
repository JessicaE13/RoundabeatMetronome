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
                    SettingsView()
                default:
                    ContentView(metronome: metronome)
                }
            }
            
            // Custom Capsule Tab Bar
            HStack {
                Spacer()
                
                // Metronome Tab Button
                Button(action: {
                    selectedTab = 0
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "metronome")
                            .font(.system(size: 20))
                            .foregroundColor(selectedTab == 0 ? Color("colorGlow") : Color.white.opacity(0.6))
                        
                        Text("Metronome")
                            .font(.system(size: 12))
                            .foregroundColor(selectedTab == 0 ? Color("colorGlow") : Color.white.opacity(0.6))
                    }
                    .frame(width: 100, height: 56)
                }
                
                Spacer()
                
                // Settings Tab Button
                Button(action: {
                    selectedTab = 1
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 20))
                            .foregroundColor(selectedTab == 1 ? Color("colorGlow") : Color.white.opacity(0.6))
                        
                        Text("Settings")
                            .font(.system(size: 12))
                            .foregroundColor(selectedTab == 1 ? Color("colorGlow") : Color.white.opacity(0.6))
                    }
                    .frame(width: 100, height: 56)
                }
                
                Spacer()
            }
            .frame(width: 280, height: 70)
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
}

// MARK: - Preview
#Preview {
    MainTabView()
        .preferredColorScheme(.dark) // Use dark mode for preview
}
