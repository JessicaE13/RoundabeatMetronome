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

// MARK: - Settings View
struct SettingsView: View {
    @Bindable var metronome: MetronomeEngine
    @State private var themeManager = ThemeManager()
    @Environment(\.deviceEnvironment) private var device
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Settings Title
            Text("Settings")
                .font(.system(size: device.deviceType.titleFontSize, weight: .bold, design: .default))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, device.deviceType.sectionPadding)
                .padding(.bottom, device.deviceType.sectionPadding)
            
            // Audio Settings Section
            VStack(alignment: .leading, spacing: device.deviceType.settingsSectionSpacing) {
                Text("Audio Settings")
                    .font(.system(size: device.deviceType.sectionHeaderFontSize, weight: .bold))
                    .padding(.bottom, device.deviceType.settingsItemSpacing)
                
                // Volume Control
                VStack(alignment: .leading, spacing: device.deviceType.settingsItemSpacing) {
                    HStack {
                        Text("Click Volume")
                            .font(.system(size: device.deviceType.mediumFontSize, weight: .medium))
                        Spacer()
                        Text("\(Int(metronome.clickVolume * 100))%")
                            .font(.system(size: device.deviceType.smallFontSize, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: $metronome.clickVolume, in: 0...1, step: 0.01)
                        .padding(.horizontal, device.deviceType.sliderPadding)
                }
                .padding(.bottom, device.deviceType.settingsGroupSpacing)
                
                // Accent First Beat Toggle
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Accent First Beat")
                            .font(.system(size: device.deviceType.mediumFontSize, weight: .medium))
                        Text("Higher pitch on beat 1")
                            .font(.system(size: device.deviceType.smallFontSize))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Toggle("", isOn: $metronome.accentFirstBeat)
                        .labelsHidden()
                }
            }
            .padding(.bottom, device.deviceType.sectionSpacing)
            
            Divider()
                .padding(.bottom, device.deviceType.sectionSpacing)
            
            // Visual Settings Section
            VStack(alignment: .leading, spacing: device.deviceType.settingsSectionSpacing) {
                Text("Visual Settings")
                    .font(.system(size: device.deviceType.sectionHeaderFontSize, weight: .bold))
                    .padding(.bottom, device.deviceType.settingsItemSpacing)
                
                // Theme Selection
                VStack(alignment: .leading, spacing: device.deviceType.settingsItemSpacing) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Appearance")
                                .font(.system(size: device.deviceType.mediumFontSize, weight: .medium))
                            Text("Choose light, dark, or system theme")
                                .font(.system(size: device.deviceType.smallFontSize))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(themeManager.displayName)
                            .font(.system(size: device.deviceType.smallFontSize, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: device.deviceType.buttonSpacing) {
                        // System Button
                        Button("System") {
                            themeManager.setSystemDefault()
                        }
                        .font(.system(size: device.deviceType.buttonFontSize, weight: .medium))
                        .foregroundColor(themeManager.isSystemDefault ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: device.deviceType.uniformButtonHeight)
                        .background(themeManager.isSystemDefault ? Color.accentColor : Color(.systemGray6))
                        .cornerRadius(8)
                        
                        // Light Button
                        Button("Light") {
                            themeManager.setLightMode()
                        }
                        .font(.system(size: device.deviceType.buttonFontSize, weight: .medium))
                        .foregroundColor(themeManager.isLightMode ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: device.deviceType.uniformButtonHeight)
                        .background(themeManager.isLightMode ? Color.accentColor : Color(.systemGray6))
                        .cornerRadius(8)
                        
                        // Dark Button
                        Button("Dark") {
                            themeManager.setDarkMode()
                        }
                        .font(.system(size: device.deviceType.buttonFontSize, weight: .medium))
                        .foregroundColor(themeManager.isDarkMode ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: device.deviceType.uniformButtonHeight)
                        .background(themeManager.isDarkMode ? Color.accentColor : Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
                .padding(.bottom, device.deviceType.settingsItemSpacing)
                
                // Visual Metronome Toggle
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Visual Metronome")
                            .font(.system(size: device.deviceType.mediumFontSize, weight: .medium))
                        Text("Show beat indicators")
                            .font(.system(size: device.deviceType.smallFontSize))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Toggle("", isOn: $metronome.visualMetronome)
                        .labelsHidden()
                }
                .padding(.bottom, device.deviceType.settingsItemSpacing)
                
                // Square Outline Toggle
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Square Outline")
                            .font(.system(size: device.deviceType.mediumFontSize, weight: .medium))
                        Text("Show blue square outline around beat indicator")
                            .font(.system(size: device.deviceType.smallFontSize))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Toggle("", isOn: $metronome.showSquareOutline)
                        .labelsHidden()
                }
            }
            .padding(.bottom, device.deviceType.sectionSpacing)
            
            Divider()
                .padding(.bottom, device.deviceType.sectionSpacing)
            
            // Info Section
            VStack(alignment: .leading, spacing: device.deviceType.settingsSectionSpacing) {
                Text("System Information")
                    .font(.system(size: device.deviceType.sectionHeaderFontSize, weight: .bold))
                    .padding(.bottom, device.deviceType.settingsItemSpacing)
                
                VStack(alignment: .leading, spacing: device.deviceType.settingsItemSpacing) {
                    InfoRow(title: "Audio Engine", value: "AVAudioSourceNode")
                    InfoRow(title: "Timing Method", value: "Sample-accurate")
                    InfoRow(title: "Precision", value: "±1 sample (~0.02ms)")
                    InfoRow(title: "Sample Rate", value: "48 kHz")
                    InfoRow(title: "Buffer Size", value: "2ms target")
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, device.deviceType.horizontalPadding)
        .preferredColorScheme(themeManager.colorScheme) // Apply the selected color scheme
    }
}

#Preview {
    SettingsView(metronome: MetronomeEngine())
        .deviceEnvironment(DeviceEnvironment())
}
