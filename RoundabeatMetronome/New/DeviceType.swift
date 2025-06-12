

import SwiftUI

// MARK: - Device Type Enum
enum DeviceType: CaseIterable {
    case compactPhone    // iPhone SE, 12 mini, 13 mini (width ≤ 375)
    case regularPhone    // Standard iPhones (width > 375, ≤ 700)
    case iPad           // iPads (width > 700)
    
    var isIPad: Bool {
        return self == .iPad
    }
    
    var isCompactPhone: Bool {
        return self == .compactPhone
    }
    
    var isRegularPhone: Bool {
        return self == .regularPhone
    }
    
    var isPhone: Bool {
        return self == .compactPhone || self == .regularPhone
    }
}

// MARK: - Device Environment
@Observable
class DeviceEnvironment {
    var deviceType: DeviceType = .regularPhone
    var screenWidth: CGFloat = 390
    var screenHeight: CGFloat = 844
    
    func updateDevice(width: CGFloat, height: CGFloat) {
        screenWidth = width
        screenHeight = height
        
        if width > 700 {
            deviceType = .iPad
        } else if width <= 375 {
            deviceType = .compactPhone
        } else {
            deviceType = .regularPhone
        }
    }
}

// MARK: - Sizing Extensions
extension DeviceType {
    
    // MARK: - Font Sizes
    var largeFontSize: CGFloat {
        switch self {
        case .compactPhone: return 75
        case .regularPhone: return 90
        case .iPad: return 120
        }
    }
    
    var mediumFontSize: CGFloat {
        switch self {
        case .compactPhone: return 14
        case .regularPhone: return 16
        case .iPad: return 18
        }
    }
    
    var smallFontSize: CGFloat {
        switch self {
        case .compactPhone: return 11
        case .regularPhone: return 12
        case .iPad: return 14
        }
    }
    
    var tinyFontSize: CGFloat {
        switch self {
        case .compactPhone: return 9
        case .regularPhone: return 10
        case .iPad: return 12
        }
    }
    
    var buttonFontSize: CGFloat {
        switch self {
        case .compactPhone: return 11
        case .regularPhone: return 12
        case .iPad: return 16
        }
    }
    
    var titleFontSize: CGFloat {
        switch self {
        case .compactPhone: return 24
        case .regularPhone: return 28
        case .iPad: return 36
        }
    }
    
    var sectionHeaderFontSize: CGFloat {
        switch self {
        case .compactPhone: return 18
        case .regularPhone: return 22
        case .iPad: return 28
        }
    }
    
    // MARK: - Component Heights
    var tempoScrollHeight: CGFloat {
        switch self {
        case .compactPhone: return 55
        case .regularPhone: return 65
        case .iPad: return 80
        }
    }
    
    var bpmViewHeight: CGFloat {
        switch self {
        case .compactPhone: return 85
        case .regularPhone: return 90
        case .iPad: return 120
        }
    }
    
    var uniformButtonHeight: CGFloat {
        switch self {
        case .compactPhone: return 32
        case .regularPhone: return 36
        case .iPad: return 44
        }
    }
    
    var uniformButtonWidth: CGFloat {
        switch self {
        case .compactPhone: return 85
        case .regularPhone: return 95
        case .iPad: return 120
        }
    }
    
    var logoHeight: CGFloat {
        switch self {
        case .compactPhone: return 18
        case .regularPhone: return 25
        case .iPad: return 35
        }
    }
    
    var tempoMarkingHeight: CGFloat {
        switch self {
        case .compactPhone: return 36
        case .regularPhone: return 40
        case .iPad: return 50
        }
    }
    
    // MARK: - Spacing
    var verticalSpacing: CGFloat {
        switch self {
        case .compactPhone: return 8
        case .regularPhone: return 12
        case .iPad: return 20
        }
    }
    
    var horizontalSpacing: CGFloat {
        switch self {
        case .compactPhone: return 8
        case .regularPhone: return 12
        case .iPad: return 20
        }
    }
    
    var buttonSpacing: CGFloat {
        switch self {
        case .compactPhone: return 8
        case .regularPhone: return 10
        case .iPad: return 20
        }
    }
    
    var sectionPadding: CGFloat {
        switch self {
        case .compactPhone: return 16
        case .regularPhone: return 20
        case .iPad: return 40
        }
    }
    
    var horizontalPadding: CGFloat {
        switch self {
        case .compactPhone: return 16
        case .regularPhone: return 20
        case .iPad: return 60
        }
    }
    
    // MARK: - Settings-Specific Spacing
    var settingsSectionSpacing: CGFloat {
        switch self {
        case .compactPhone: return 16
        case .regularPhone: return 18
        case .iPad: return 24
        }
    }
    
    var settingsItemSpacing: CGFloat {
        switch self {
        case .compactPhone: return 10
        case .regularPhone: return 12
        case .iPad: return 16
        }
    }
    
    var settingsGroupSpacing: CGFloat {
        switch self {
        case .compactPhone: return 6
        case .regularPhone: return 8
        case .iPad: return 12
        }
    }
    
    var sectionSpacing: CGFloat {
        switch self {
        case .compactPhone: return 20
        case .regularPhone: return 25
        case .iPad: return 35
        }
    }
    
    var sliderPadding: CGFloat {
        switch self {
        case .compactPhone: return 8
        case .regularPhone: return 10
        case .iPad: return 20
        }
    }
    
    // MARK: - BPM Button Sizes
    var bpmButtonWidth: CGFloat {
        switch self {
        case .compactPhone: return 38
        case .regularPhone: return 45
        case .iPad: return 80
        }
    }
    
    var bpmButtonHeight: CGFloat {
        switch self {
        case .compactPhone: return 32
        case .regularPhone: return 36
        case .iPad: return 50
        }
    }
    
    var bpmDisplayMinWidth: CGFloat {
        switch self {
        case .compactPhone: return 160
        case .regularPhone: return 180
        case .iPad: return 220
        }
    }
    
    // MARK: - Dial Sizing
    var dialArcSize: CGFloat {
        switch self {
        case .compactPhone: return 240
        case .regularPhone: return 300
        case .iPad: return 500
        }
    }
}

// MARK: - Environment Key
struct DeviceEnvironmentKey: EnvironmentKey {
    static let defaultValue = DeviceEnvironment()
}

extension EnvironmentValues {
    var deviceEnvironment: DeviceEnvironment {
        get { self[DeviceEnvironmentKey.self] }
        set { self[DeviceEnvironmentKey.self] = newValue }
    }
}

// MARK: - View Extension for Easy Access
extension View {
    func deviceEnvironment(_ environment: DeviceEnvironment) -> some View {
        self.environment(\.deviceEnvironment, environment)
    }
}
