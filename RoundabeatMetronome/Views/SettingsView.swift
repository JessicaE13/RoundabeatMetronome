//
//  SettingsView.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 4/23/25.
//

import SwiftUI

// MARK: - Settings View
struct SettingsView: View {
    @ObservedObject var metronome: MetronomeEngine
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Sound Options")) {
                    Toggle("Enable Sound", isOn: .constant(true))
                    
                    NavigationLink(destination: SoundsView(metronome: metronome)) {
                        HStack {
                            Text("Click Sound")
                            Spacer()
                            Text(metronome.selectedSoundName)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section(header: Text("Visual Options")) {
                    Toggle("Highlight First Beat", isOn: $metronome.highlightFirstBeat)
                }
                
                Section(header: Text("About")) {
                    NavigationLink(destination: Text("RoundaBeat Metronome\nVersion 1.0")) {
                        Text("App Information")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView(metronome: MetronomeEngine())
}
