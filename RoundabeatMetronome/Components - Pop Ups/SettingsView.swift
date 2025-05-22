//
//  SettingsView.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 4/23/25.
//

import SwiftUI

// MARK: - Settings View
struct SettingsView: View {
    @State private var showColorPicker = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Sound Options")) {
                    Toggle("Enable Sound", isOn: .constant(true))
                    
                    NavigationLink(destination: Text("Sound Selection")) {
                        HStack {
                            Text("Click Sound")
                            Spacer()
                            Text("Bongo")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section(header: Text("Visual Options")) {
                    Toggle("Flash Screen on First Beat", isOn: .constant(true))
                    Toggle("Dark Mode", isOn: .constant(true))
                    
                    // Color Theme Selection
                    NavigationLink(destination: ThemeColorPicker()) {
                        HStack {
                            Text("Theme Color")
                            Spacer()
                            Circle()
                                .fill(AppTheme.backgroundColor)
                                .frame(width: 24, height: 24)
                            Text(AppTheme.selectedTheme)
                                .foregroundColor(.gray)
                        }
                    }
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

// MARK: - Theme Color Picker
struct ThemeColorPicker: View {
    // Local state that initializes from the AppTheme
    @State private var selectedTheme = AppTheme.selectedTheme
    
    // Color options
    let themeOptions: [ThemeColor] = [.blue, .gray, .green, .lavender, .red, .white, .yellow, .greige]
    
    // Grid layout
    let columns = [
        GridItem(.adaptive(minimum: 70), spacing: 15)
    ]
    
    var body: some View {
        VStack {
            Text("Select Theme Color")
                .font(.headline)
                .padding(.top)
            
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(themeOptions, id: \.self) { theme in
                    ColorCircleView(
                        color: Color("skin\(theme.rawValue)"),
                        isSelected: theme.rawValue == selectedTheme,
                        name: theme.rawValue
                    )
                    .onTapGesture {
                        selectedTheme = theme.rawValue
                        AppTheme.changeTheme(to: theme)
                    }
                }
            }
            .padding()
            
            Spacer()
        }
        .navigationTitle("Theme Color")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Color Circle View
struct ColorCircleView: View {
    let color: Color
    let isSelected: Bool
    let name: String
    
    var body: some View {
        VStack {
            ZStack {
                // Outer circle (selection indicator)
                Circle()
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
                    .frame(width: 60, height: 60)
                
                // Color circle
                Circle()
                    .fill(color)
                    .frame(width: 50, height: 50)
                    .shadow(radius: 2)
            }
            
            Text(name)
                .font(.caption)
                .foregroundColor(isSelected ? .primary : .secondary)
        }
    }
}

#Preview {
    SettingsView()
}
