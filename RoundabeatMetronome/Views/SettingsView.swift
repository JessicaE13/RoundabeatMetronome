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
                
//                Section(header: Text("Encourage Us")) {
//                    Link(destination: URL(string: "https://apps.apple.com/app/id[YOUR_APP_ID]?action=write-review")!) {
//                        HStack {
//                            Text("Leave a 5-Star Review")
//                                .foregroundColor(.primary)
//                            Spacer()
//                            HStack(spacing: 2) {
//                                ForEach(0..<5, id: \.self) { _ in
//                                    Image(systemName: "star.fill")
//                                        .foregroundColor(.yellow)
//                                        .font(.caption)
//                                }
//                            }
//                        }
//                    }
//                }
//                
                Section(header: Text("About")) {
                    HStack {
                        Text("App Information")
                        Spacer()
                        Text("RoundaBeat Metronome v1.0")
                            .foregroundColor(.gray)
                    }
                    
                    Link(destination: URL(string: "mailto:hello@roundabeat.com")!) {
                        HStack {
                            Text("Feedback")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "envelope")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Link(destination: URL(string: "http://roundabeat.com/mobile-app-privacy-policy/")!) {
                        HStack {
                            Text("Privacy Policy")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Link(destination: URL(string: "http://roundabeat.com/roundabeat-mobile-app-terms-of-use/")!) {
                        HStack {
                            Text("Terms of Use")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.gray)
                        }
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
