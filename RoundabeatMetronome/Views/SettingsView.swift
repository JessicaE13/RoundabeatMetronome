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
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        GeometryReader { geometry in
            
            ZStack {
                BackgroundView()
                
                VStack(spacing: 0) {
                    // Custom header
                    customHeaderView()
                        .padding(.top, geometry.safeAreaInsets.top + 20)
                    
                    // Settings content
                    settingsContent(geometry: geometry)
                    
                }
            }
        }
        .ignoresSafeArea(.all, edges: [.top, .leading, .trailing]) // Don't ignore bottom for tab bar
    }
    
    private func customHeaderView() -> some View {
        VStack(spacing: 8) {
            Text("SETTINGS")
                .font(.system(size: 12, weight: .medium))
                .kerning(1.5)
                .foregroundColor(Color.white.opacity(0.4))
            
            Text("Customize Your Metronome")
                .font(.system(size: 14, weight: .medium))
                .kerning(0.5)
                .foregroundColor(Color.white.opacity(0.9))
                .padding(.bottom, 16)
        }
    }
    
    private func settingsContent(geometry: GeometryProxy) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                
                // Sound Options Section
                settingsSection(
                    title: "Sound Options"
                ) {
                    VStack(spacing: 12) {
                        // Enable Sound Toggle
                        settingsRow(
                            title: "Enable Sound"
                        ) {
                            Toggle("", isOn: .constant(true))
                                .toggleStyle(SwitchToggleStyle(tint: Color.accentColor))
                        }
                        
                        // Click Sound Selection
                        NavigationLink(destination: SoundsView(metronome: metronome)) {
                            settingsRowContent(
                                title: "Click Sound",
                                subtitle: metronome.selectedSoundName,
                                icon: "speaker.wave.2"
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                // Visual Options Section
                settingsSection(
                    title: "Visual Options"
                ) {
                    settingsRow(
                        title: "Highlight First Beat",
                        subtitle: "Emphasize the first beat of each measure"
                        
                    ) {
                        Toggle("", isOn: $metronome.highlightFirstBeat)
                            .toggleStyle(SwitchToggleStyle(tint: Color.accentColor))
                    }
                }
                
                // About Section
                settingsSection(
                    title: "About"
                ) {
                    VStack(spacing: 12) {
                        // App Information
                        settingsRowContent(
                            title: "App Information",
                            subtitle: "RoundaBeat Metronome v1.0",
                            icon: "info.circle"
                        )
                        
                        // Feedback
                        Link(destination: URL(string: "mailto:hello@roundabeat.com")!) {
                            settingsRowContent(
                                title: "Send Feedback",
                                subtitle: "hello@roundabeat.com",
                                icon: "envelope",
                                showArrow: true
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Privacy Policy
                        Link(destination: URL(string: "http://roundabeat.com/mobile-app-privacy-policy/")!) {
                            settingsRowContent(
                                title: "Privacy Policy",
                                subtitle: "View our privacy policy",
                                icon: "hand.raised",
                                showArrow: true
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Terms of Use
                        Link(destination: URL(string: "http://roundabeat.com/roundabeat-mobile-app-terms-of-use/")!) {
                            settingsRowContent(
                                title: "Terms of Use",
                                subtitle: "View terms and conditions",
                                icon: "doc.text",
                                showArrow: true
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                // Bottom spacing to account for tab bar
                Spacer()
                    .frame(height: 20)
            }
            .padding(.horizontal, 20)
            .frame(minHeight: geometry.size.height - 140) // Account for header
        }
    }
    
    // MARK: - Helper Views
    
    private func settingsSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .medium))
                .kerning(1)
                .foregroundColor(Color.white.opacity(0.4))
                .padding(.horizontal, 2)
            
            VStack(spacing: 0) {
                content()
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
    
    private func settingsRow<Content: View>(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder trailing: () -> Content
    ) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(Color.white.opacity(0.9))
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(Color.white.opacity(0.5))
                }
            }
            
            Spacer()
            
            trailing()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private func settingsRowContent(
        title: String,
        subtitle: String,
        icon: String,
        showArrow: Bool = false
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.white.opacity(0.6))
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(Color.white.opacity(0.9))
                
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(Color.white.opacity(0.5))
            }
            
            Spacer()
            
            if showArrow {
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.4))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical,  12)
        .contentShape(Rectangle())
    }
}

#Preview {
    SettingsView(metronome: MetronomeEngine())
}
