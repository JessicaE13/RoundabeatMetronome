import SwiftUI

// MARK: - Theme Manager
@Observable
class ThemeManager {
    var colorScheme: ColorScheme? = nil // nil = system default
    
    var isSystemDefault: Bool {
        return colorScheme == nil
    }
    
    var isDarkMode: Bool {
        return colorScheme == .dark
    }
    
    var isLightMode: Bool {
        return colorScheme == .light
    }
    
    func setSystemDefault() {
        colorScheme = nil
    }
    
    func setDarkMode() {
        colorScheme = .dark
    }
    
    func setLightMode() {
        colorScheme = .light
    }
    
    var displayName: String {
        switch colorScheme {
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        case nil:
            return "System"
        @unknown default:
            return "System"
        }
    }
}

// MARK: - Info Row Component
struct InfoRow: View {
    let title: String
    let value: String
    
    // Get screen dimensions directly
    private var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    // Check if device is iPad
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: mediumFontSize, weight: .medium))
            Spacer()
            Text(value)
                .font(.system(size: mediumFontSize, weight: .regular))
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Responsive Properties
    
    private var mediumFontSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 16 :
                   screenWidth <= 834 ? 18 :
                   screenWidth <= 1024 ? 20 :
                   22
        } else {
            return screenWidth <= 320 ? 12 :
                   screenWidth <= 375 ? 14 :
                   screenWidth <= 393 ? 16 :
                   17
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @ObservedObject var metronome: MetronomeEngine
    @Bindable var themeManager: ThemeManager
    
    // Get screen dimensions directly
    private var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    // Check if device is iPad
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Settings Title
                Text("Settings")
                    .font(.system(size: titleFontSize, weight: .bold, design: .default))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, sectionPadding)
                    .padding(.bottom, sectionPadding)
                
                // Audio Settings Section
                VStack(alignment: .leading, spacing: settingsSectionSpacing) {
                    Text("Audio Settings")
                        .font(.system(size: sectionHeaderFontSize, weight: .bold))
                        .padding(.bottom, settingsItemSpacing)
                    
                    // Volume Control
                    VStack(alignment: .leading, spacing: settingsItemSpacing) {
                        HStack {
                            Text("Click Volume")
                                .font(.system(size: mediumFontSize, weight: .medium))
                            Spacer()
                            Text("\(Int(metronome.clickVolume * 100))%")
                                .font(.system(size: smallFontSize, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $metronome.clickVolume, in: 0...1, step: 0.01)
                            .padding(.horizontal, sliderPadding)
                    }
                    .padding(.bottom, settingsGroupSpacing)
                    
                    // Accent First Beat Toggle
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Accent First Beat")
                                .font(.system(size: mediumFontSize, weight: .medium))
                            Text("Higher pitch on beat 1")
                                .font(.system(size: smallFontSize))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Toggle("", isOn: $metronome.accentFirstBeat)
                            .labelsHidden()
                    }
                }
                .padding(.bottom, sectionSpacing)
                
                Divider()
                    .padding(.bottom, sectionSpacing)
                
                // Visual Settings Section
                VStack(alignment: .leading, spacing: settingsSectionSpacing) {
                    Text("Visual Settings")
                        .font(.system(size: sectionHeaderFontSize, weight: .bold))
                        .padding(.bottom, settingsItemSpacing)
                    
                    // Theme Selection
                    VStack(alignment: .leading, spacing: settingsItemSpacing) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Appearance")
                                    .font(.system(size: mediumFontSize, weight: .medium))
                                Text("Choose light, dark, or system theme")
                                    .font(.system(size: smallFontSize))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(themeManager.displayName)
                                .font(.system(size: smallFontSize, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: buttonSpacing) {
                            // System Button
                            Button("System") {
                                themeManager.setSystemDefault()
                            }
                            .font(.system(size: buttonFontSize, weight: .medium))
                            .foregroundColor(themeManager.isSystemDefault ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: uniformButtonHeight)
                            .background(themeManager.isSystemDefault ? Color.accentColor : Color(.systemGray6))
                            .cornerRadius(8)
                            
                            // Light Button
                            Button("Light") {
                                themeManager.setLightMode()
                            }
                            .font(.system(size: buttonFontSize, weight: .medium))
                            .foregroundColor(themeManager.isLightMode ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: uniformButtonHeight)
                            .background(themeManager.isLightMode ? Color.accentColor : Color(.systemGray6))
                            .cornerRadius(8)
                            
                            // Dark Button
                            Button("Dark") {
                                themeManager.setDarkMode()
                            }
                            .font(.system(size: buttonFontSize, weight: .medium))
                            .foregroundColor(themeManager.isDarkMode ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: uniformButtonHeight)
                            .background(themeManager.isDarkMode ? Color.accentColor : Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.bottom, settingsItemSpacing)
                    
                    // Visual Metronome Toggle
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Visual Metronome")
                                .font(.system(size: mediumFontSize, weight: .medium))
                            Text("Show beat indicators")
                                .font(.system(size: smallFontSize))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Toggle("", isOn: $metronome.visualMetronome)
                            .labelsHidden()
                    }
                    .padding(.bottom, settingsItemSpacing)
                    
                    // Square Outline Toggle
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Square Outline")
                                .font(.system(size: mediumFontSize, weight: .medium))
                            Text("Show blue square outline around beat indicator")
                                .font(.system(size: smallFontSize))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Toggle("", isOn: $metronome.showSquareOutline)
                            .labelsHidden()
                    }
                }
                .padding(.bottom, sectionSpacing)
                
                Divider()
                    .padding(.bottom, sectionSpacing)
                
                // Info Section
                VStack(alignment: .leading, spacing: settingsSectionSpacing) {
                    Text("System Information")
                        .font(.system(size: sectionHeaderFontSize, weight: .bold))
                        .padding(.bottom, settingsItemSpacing)
                    
                    VStack(alignment: .leading, spacing: settingsItemSpacing) {
                        InfoRow(title: "Audio Engine", value: "AVAudioSourceNode")
                        InfoRow(title: "Timing Method", value: "Sample-accurate")
                        InfoRow(title: "Precision", value: "±1 sample (~0.02ms)")
                        InfoRow(title: "Sample Rate", value: "48 kHz")
                        InfoRow(title: "Buffer Size", value: "2ms target")
                    }
                }
                
                // Add extra padding at the bottom to account for the navigation bar
                Spacer()
                    .frame(height: isIPad ? 100 : 80)
            }
            .padding(.horizontal, horizontalPadding)
        }
    }
    
    // MARK: - Responsive Properties
    
    private var titleFontSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 32 :
                   screenWidth <= 834 ? 36 :
                   screenWidth <= 1024 ? 40 :
                   44
        } else {
            return screenWidth <= 320 ? 20 :
                   screenWidth <= 375 ? 24 :
                   screenWidth <= 393 ? 28 :
                   30
        }
    }
    
    private var sectionHeaderFontSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 26 :
                   screenWidth <= 834 ? 28 :
                   screenWidth <= 1024 ? 32 :
                   36
        } else {
            return screenWidth <= 320 ? 16 :
                   screenWidth <= 375 ? 18 :
                   screenWidth <= 393 ? 22 :
                   24
        }
    }
    
    private var mediumFontSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 16 :
                   screenWidth <= 834 ? 18 :
                   screenWidth <= 1024 ? 20 :
                   22
        } else {
            return screenWidth <= 320 ? 12 :
                   screenWidth <= 375 ? 14 :
                   screenWidth <= 393 ? 16 :
                   17
        }
    }
    
    private var smallFontSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 13 :
                   screenWidth <= 834 ? 14 :
                   screenWidth <= 1024 ? 15 :
                   16
        } else {
            return screenWidth <= 320 ? 10 :
                   screenWidth <= 375 ? 11 :
                   screenWidth <= 393 ? 12 :
                   13
        }
    }
    
    private var buttonFontSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 14 :
                   screenWidth <= 834 ? 16 :
                   screenWidth <= 1024 ? 18 :
                   20
        } else {
            return screenWidth <= 320 ? 10 :
                   screenWidth <= 375 ? 11 :
                   screenWidth <= 393 ? 12 :
                   13
        }
    }
    
    private var sectionPadding: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 32 :
                   screenWidth <= 834 ? 40 :
                   screenWidth <= 1024 ? 48 :
                   56
        } else {
            return screenWidth <= 320 ? 12 :
                   screenWidth <= 375 ? 16 :
                   screenWidth <= 393 ? 20 :
                   22
        }
    }
    
    private var horizontalPadding: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 48 :
                   screenWidth <= 834 ? 60 :
                   screenWidth <= 1024 ? 72 :
                   84
        } else {
            return screenWidth <= 320 ? 12 :
                   screenWidth <= 375 ? 16 :
                   screenWidth <= 393 ? 20 :
                   24
        }
    }
    
    private var settingsSectionSpacing: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 20 :
                   screenWidth <= 834 ? 24 :
                   screenWidth <= 1024 ? 28 :
                   32
        } else {
            return screenWidth <= 320 ? 12 :
                   screenWidth <= 375 ? 16 :
                   screenWidth <= 393 ? 18 :
                   20
        }
    }
    
    private var settingsItemSpacing: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 14 :
                   screenWidth <= 834 ? 16 :
                   screenWidth <= 1024 ? 18 :
                   20
        } else {
            return screenWidth <= 320 ? 8 :
                   screenWidth <= 375 ? 10 :
                   screenWidth <= 393 ? 12 :
                   14
        }
    }
    
    private var settingsGroupSpacing: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 10 :
                   screenWidth <= 834 ? 12 :
                   screenWidth <= 1024 ? 14 :
                   16
        } else {
            return screenWidth <= 320 ? 4 :
                   screenWidth <= 375 ? 6 :
                   screenWidth <= 393 ? 8 :
                   10
        }
    }
    
    private var sectionSpacing: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 30 :
                   screenWidth <= 834 ? 35 :
                   screenWidth <= 1024 ? 40 :
                   45
        } else {
            return screenWidth <= 320 ? 16 :
                   screenWidth <= 375 ? 20 :
                   screenWidth <= 393 ? 25 :
                   28
        }
    }
    
    private var sliderPadding: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 16 :
                   screenWidth <= 834 ? 20 :
                   screenWidth <= 1024 ? 24 :
                   28
        } else {
            return screenWidth <= 320 ? 6 :
                   screenWidth <= 375 ? 8 :
                   screenWidth <= 393 ? 10 :
                   12
        }
    }
    
    private var buttonSpacing: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 16 :
                   screenWidth <= 834 ? 20 :
                   screenWidth <= 1024 ? 24 :
                   28
        } else {
            return screenWidth <= 320 ? 6 :
                   screenWidth <= 375 ? 8 :
                   screenWidth <= 393 ? 10 :
                   12
        }
    }
    
    private var uniformButtonHeight: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 40 :
                   screenWidth <= 834 ? 44 :
                   screenWidth <= 1024 ? 48 :
                   52
        } else {
            return screenWidth <= 320 ? 28 :
                   screenWidth <= 375 ? 32 :
                   screenWidth <= 393 ? 36 :
                   38
        }
    }
}

#Preview {
    SettingsView(metronome: MetronomeEngine(), themeManager: ThemeManager())
}
