//
//  SettingsView.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 4/23/25.
//

import SwiftUI

// MARK: - Settings View
struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Sound Options")) {
                    Toggle("Enable Sound", isOn: .constant(true))
                    
                    NavigationLink(destination: Text("Sound Selection")) {
                        HStack {
                            Text("Click Sound")
                            Spacer()
                            Text("Woodblock")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section(header: Text("Visual Options")) {
                    Toggle("Flash Screen on First Beat", isOn: .constant(true))
                    Toggle("Dark Mode", isOn: .constant(true))
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
    SettingsView()
}
