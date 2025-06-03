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
            let isIPad = UIDevice.current.isIPad
            
            ZStack {
                BackgroundView()
                
                // Use NavigationView only when presented as sheet, otherwise use plain content
                if UIDevice.current.isIPad {
                    // iPad - use NavigationView for better presentation
                    NavigationView {
                        settingsContent(geometry: geometry, isIPad: isIPad)
                            .navigationTitle("Settings")
                            .navigationBarTitleDisplayMode(.large)
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                } else {
                    // iPhone - use custom header to avoid double navigation
                    VStack(spacing: 0) {
                        // Custom header
                        customHeaderView(isIPad: isIPad)
                            .padding(.top, geometry.safeAreaInsets.top + 20)
                        
                        // Settings content
                        settingsContent(geometry: geometry, isIPad: isIPad)
                    }
                }
            }
        }
        .ignoresSafeArea(.all, edges: [.top, .leading, .trailing]) // Don't ignore bottom for tab bar
    }
    
    private func customHeaderView(isIPad: Bool) -> some View {
        VStack(spacing: isIPad ? 12 : 8) {
            Text("SETTINGS")
                .font(.system(size: isIPad ? 16 : 12, weight: .medium))
                .kerning(1.5)
                .foregroundColor(Color.white.opacity(0.4))
            
            Text("Customize Your Metronome")
                .font(.system(size: isIPad ? 18 : 14, weight: .medium))
                .kerning(0.5)
                .foregroundColor(Color.white.opacity(0.9))
                .padding(.bottom, isIPad ? 20 : 16)
        }
    }
    
    private func settingsContent(geometry: GeometryProxy, isIPad: Bool) -> some View {
        ScrollView {
            VStack(spacing: isIPad ? 24 : 16) {
                
                // Sound Options Section
                settingsSection(
                    title: "Sound Options",
                    isIPad: isIPad
                ) {
                    VStack(spacing: isIPad ? 16 : 12) {
                        // Enable Sound Toggle
                        settingsRow(
                            title: "Enable Sound",
                            isIPad: isIPad
                        ) {
                            Toggle("", isOn: .constant(true))
                                .toggleStyle(SwitchToggleStyle(tint: Color.accentColor))
                        }
                        
                        // Click Sound Selection
                        NavigationLink(destination: SoundsView(metronome: metronome)) {
                            settingsRowContent(
                                title: "Click Sound",
                                subtitle: metronome.selectedSoundName,
                                icon: "speaker.wave.2",
                                isIPad: isIPad
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                // Visual Options Section
                settingsSection(
                    title: "Visual Options",
                    isIPad: isIPad
                ) {
                    settingsRow(
                        title: "Highlight First Beat",
                        subtitle: "Emphasize the first beat of each measure",
                        isIPad: isIPad
                    ) {
                        Toggle("", isOn: $metronome.highlightFirstBeat)
                            .toggleStyle(SwitchToggleStyle(tint: Color.accentColor))
                    }
                }
                
                // About Section
                settingsSection(
                    title: "About",
                    isIPad: isIPad
                ) {
                    VStack(spacing: isIPad ? 16 : 12) {
                        // App Information
                        settingsRowContent(
                            title: "App Information",
                            subtitle: "RoundaBeat Metronome v1.0",
                            icon: "info.circle",
                            isIPad: isIPad
                        )
                        
                        // Feedback
                        Link(destination: URL(string: "mailto:hello@roundabeat.com")!) {
                            settingsRowContent(
                                title: "Send Feedback",
                                subtitle: "hello@roundabeat.com",
                                icon: "envelope",
                                isIPad: isIPad,
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
                                isIPad: isIPad,
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
                                isIPad: isIPad,
                                showArrow: true
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                // Bottom spacing to account for tab bar
                Spacer()
                    .frame(height: isIPad ? 30 : 20)
            }
            .padding(.horizontal, isIPad ? 40 : 20)
            .frame(minHeight: geometry.size.height - 140) // Account for header
        }
    }
    
    // MARK: - Helper Views
    
    private func settingsSection<Content: View>(
        title: String,
        isIPad: Bool,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: isIPad ? 16 : 12) {
            Text(title.uppercased())
                .font(.system(size: isIPad ? 14 : 12, weight: .medium))
                .kerning(1)
                .foregroundColor(Color.white.opacity(0.4))
                .padding(.horizontal, isIPad ? 4 : 2)
            
            VStack(spacing: 0) {
                content()
            }
            .background(
                RoundedRectangle(cornerRadius: isIPad ? 20 : 16)
                    .fill(Color.black.opacity(0.4))
                    .overlay(
                        RoundedRectangle(cornerRadius: isIPad ? 20 : 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
    
    private func settingsRow<Content: View>(
        title: String,
        subtitle: String? = nil,
        isIPad: Bool,
        @ViewBuilder trailing: () -> Content
    ) -> some View {
        HStack(spacing: isIPad ? 16 : 12) {
            VStack(alignment: .leading, spacing: isIPad ? 4 : 2) {
                Text(title)
                    .font(.system(size: isIPad ? 18 : 16))
                    .foregroundColor(Color.white.opacity(0.9))
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: isIPad ? 14 : 12))
                        .foregroundColor(Color.white.opacity(0.5))
                }
            }
            
            Spacer()
            
            trailing()
        }
        .padding(.horizontal, isIPad ? 20 : 16)
        .padding(.vertical, isIPad ? 16 : 12)
    }
    
    private func settingsRowContent(
        title: String,
        subtitle: String,
        icon: String,
        isIPad: Bool,
        showArrow: Bool = false
    ) -> some View {
        HStack(spacing: isIPad ? 16 : 12) {
            Image(systemName: icon)
                .font(.system(size: isIPad ? 20 : 16, weight: .medium))
                .foregroundColor(Color.white.opacity(0.6))
                .frame(width: isIPad ? 24 : 20)
            
            VStack(alignment: .leading, spacing: isIPad ? 4 : 2) {
                Text(title)
                    .font(.system(size: isIPad ? 18 : 16))
                    .foregroundColor(Color.white.opacity(0.9))
                
                Text(subtitle)
                    .font(.system(size: isIPad ? 14 : 12))
                    .foregroundColor(Color.white.opacity(0.5))
            }
            
            Spacer()
            
            if showArrow {
                Image(systemName: "arrow.up.right")
                    .font(.system(size: isIPad ? 16 : 14, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.4))
            }
        }
        .padding(.horizontal, isIPad ? 20 : 16)
        .padding(.vertical, isIPad ? 16 : 12)
        .contentShape(Rectangle())
    }
}

#Preview {
    SettingsView(metronome: MetronomeEngine())
}
