//
//  MainTabView.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 4/23/25.
//

import SwiftUI

// MARK: - Main Tab View
struct MainTabView: View {
    @StateObject private var metronome = MetronomeEngine()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Metronome Tab
            ContentView(metronome: metronome)
                .tabItem {
                    Image(systemName: "metronome")
                    Text("Metronome")
                }
                .tag(0)
            
            // Settings Tab
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
                .tag(1)
        }
        .accentColor(Color("colorGlow"))
    }
}

#Preview {
    MainTabView()
}
