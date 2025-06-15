//import SwiftUI
//
//// MARK: - Device Type Enum
//enum DeviceType: CaseIterable {
//    // iPhone sizes
//    case iPhoneSE        // iPhone SE 1st/2nd/3rd gen (width = 320)
//    case iPhoneMini      // iPhone 12/13/14/15/16 mini (width = 360)
//    case iPhoneCompact   // iPhone 6/7/8, SE (width = 375)
//    case iPhoneStandard  // iPhone 12/13/14/15/16, 11, XR (width = 390-393)
//    case iPhonePro       // iPhone 12/13/14/15/16 Pro, X, XS (width = 393)
//    case iPhoneProMax    // iPhone 12/13/14/15/16 Pro Max, 11 Pro Max, XS Max (width = 430)
//    case iPhonePlus      // iPhone 6/7/8 Plus (width = 414)
//    
//    // iPad sizes
//    case iPadMini        // iPad mini (width ≈ 744-768)
//    case iPadStandard    // iPad 9th/10th gen (width ≈ 810-820)
//    case iPadAir         // iPad Air (width ≈ 820-834)
//    case iPadPro11       // iPad Pro 11-inch (width ≈ 834)
//    case iPadPro129      // iPad Pro 12.9-inch (width ≈ 1024-1194)
//    
//    var isIPad: Bool {
//        switch self {
//        case .iPadMini, .iPadStandard, .iPadAir, .iPadPro11, .iPadPro129:
//            return true
//        default:
//            return false
//        }
//    }
//    
//    var isCompactPhone: Bool {
//        switch self {
//        case .iPhoneSE, .iPhoneMini, .iPhoneCompact:
//            return true
//        default:
//            return false
//        }
//    }
//    
//    var isRegularPhone: Bool {
//        switch self {
//        case .iPhoneStandard, .iPhonePro, .iPhoneProMax, .iPhonePlus:
//            return true
//        default:
//            return false
//        }
//    }
//    
//    var isPhone: Bool {
//        return !isIPad
//    }
//    
//    // New computed properties for more specific categorization
//    var isMiniDevice: Bool {
//        switch self {
//        case .iPhoneSE, .iPhoneMini, .iPadMini:
//            return true
//        default:
//            return false
//        }
//    }
//    
//    var isProDevice: Bool {
//        switch self {
//        case .iPhonePro, .iPhoneProMax, .iPadPro11, .iPadPro129:
//            return true
//        default:
//            return false
//        }
//    }
//    
//    var isLargeScreen: Bool {
//        switch self {
//        case .iPhoneProMax, .iPhonePlus, .iPadPro129:
//            return true
//        default:
//            return false
//        }
//    }
//}
//
//// MARK: - Device Environment
//@Observable
//class DeviceEnvironment {
//    var deviceType: DeviceType = .iPhoneStandard
//    var screenWidth: CGFloat = 390
//    var screenHeight: CGFloat = 844
//    
//    func updateDevice(width: CGFloat, height: CGFloat) {
//        screenWidth = width
//        screenHeight = height
//        
//        // More precise device detection based on width
//        if width > 1000 {
//            deviceType = .iPadPro129
//        } else if width > 830 {
//            if width > 850 {
//                deviceType = .iPadAir
//            } else {
//                deviceType = .iPadPro11
//            }
//        } else if width > 800 {
//            deviceType = .iPadStandard
//        } else if width > 740 {
//            deviceType = .iPadMini
//        } else if width > 425 {
//            deviceType = .iPhoneProMax
//        } else if width > 410 {
//            deviceType = .iPhonePlus
//        } else if width > 385 {
//            deviceType = .iPhonePro
//        } else if width > 380 {
//            deviceType = .iPhoneStandard
//        } else if width > 370 {
//            deviceType = .iPhoneCompact
//        } else if width > 350 {
//            deviceType = .iPhoneMini
//        } else {
//            deviceType = .iPhoneSE
//        }
//    }
//}
//
//// MARK: - Sizing Extensions
//extension DeviceType {
//    
//    // MARK: - Font Sizes
//    var largeFontSize: CGFloat {
//        switch self {
//        case .iPhoneSE:
//            return 65
//        case .iPhoneMini, .iPhoneCompact:
//            return 75
//        case .iPhoneStandard, .iPhonePro:
//            return 90
//        case .iPhoneProMax, .iPhonePlus:
//            return 95
//        case .iPadMini:
//            return 100
//        case .iPadStandard, .iPadAir:
//            return 120
//        case .iPadPro11:
//            return 130
//        case .iPadPro129:
//            return 150
//        }
//    }
//    
//    var mediumFontSize: CGFloat {
//        switch self {
//        case .iPhoneSE:
//            return 12
//        case .iPhoneMini, .iPhoneCompact:
//            return 14
//        case .iPhoneStandard, .iPhonePro:
//            return 16
//        case .iPhoneProMax, .iPhonePlus:
//            return 17
//        case .iPadMini:
//            return 16
//        case .iPadStandard, .iPadAir:
//            return 18
//        case .iPadPro11:
//            return 20
//        case .iPadPro129:
//            return 22
//        }
//    }
//    
//    var smallFontSize: CGFloat {
//        switch self {
//        case .iPhoneSE:
//            return 10
//        case .iPhoneMini, .iPhoneCompact:
//            return 11
//        case .iPhoneStandard, .iPhonePro:
//            return 12
//        case .iPhoneProMax, .iPhonePlus:
//            return 13
//        case .iPadMini:
//            return 13
//        case .iPadStandard, .iPadAir:
//            return 14
//        case .iPadPro11:
//            return 15
//        case .iPadPro129:
//            return 16
//        }
//    }
//    
//    var tinyFontSize: CGFloat {
//        switch self {
//        case .iPhoneSE:
//            return 8
//        case .iPhoneMini, .iPhoneCompact:
//            return 9
//        case .iPhoneStandard, .iPhonePro:
//            return 10
//        case .iPhoneProMax, .iPhonePlus:
//            return 11
//        case .iPadMini:
//            return 11
//        case .iPadStandard, .iPadAir:
//            return 12
//        case .iPadPro11:
//            return 13
//        case .iPadPro129:
//            return 14
//        }
//    }
//    
//    var buttonFontSize: CGFloat {
//        switch self {
//        case .iPhoneSE:
//            return 10
//        case .iPhoneMini, .iPhoneCompact:
//            return 11
//        case .iPhoneStandard, .iPhonePro:
//            return 12
//        case .iPhoneProMax, .iPhonePlus:
//            return 13
//        case .iPadMini:
//            return 14
//        case .iPadStandard, .iPadAir:
//            return 16
//        case .iPadPro11:
//            return 18
//        case .iPadPro129:
//            return 20
//        }
//    }
//    
//    var titleFontSize: CGFloat {
//        switch self {
//        case .iPhoneSE:
//            return 20
//        case .iPhoneMini, .iPhoneCompact:
//            return 24
//        case .iPhoneStandard, .iPhonePro:
//            return 28
//        case .iPhoneProMax, .iPhonePlus:
//            return 30
//        case .iPadMini:
//            return 32
//        case .iPadStandard, .iPadAir:
//            return 36
//        case .iPadPro11:
//            return 40
//        case .iPadPro129:
//            return 44
//        }
//    }
//    
//    var sectionHeaderFontSize: CGFloat {
//        switch self {
//        case .iPhoneSE:
//            return 16
//        case .iPhoneMini, .iPhoneCompact:
//            return 18
//        case .iPhoneStandard, .iPhonePro:
//            return 22
//        case .iPhoneProMax, .iPhonePlus:
//            return 24
//        case .iPadMini:
//            return 26
//        case .iPadStandard, .iPadAir:
//            return 28
//        case .iPadPro11:
//            return 32
//        case .iPadPro129:
//            return 36
//        }
//    }
//    
//    // MARK: - Component Heights
//    var tempoScrollHeight: CGFloat {
//        switch self {
//        case .iPhoneSE:
//            return 45
//        case .iPhoneMini, .iPhoneCompact:
//            return 50
//        case .iPhoneStandard, .iPhonePro:
//            return 60
//        case .iPhoneProMax, .iPhonePlus:
//            return 65
//        case .iPadMini:
//            return 70
//        case .iPadStandard, .iPadAir:
//            return 80
//        case .iPadPro11:
//            return 85
//        case .iPadPro129:
//            return 90
//        }
//    }
//    
//    var bpmViewHeight: CGFloat {
//        switch self {
//        case .iPhoneSE:
//            return 75
//        case .iPhoneMini, .iPhoneCompact:
//            return 85
//        case .iPhoneStandard, .iPhonePro:
//            return 90
//        case .iPhoneProMax, .iPhonePlus:
//            return 95
//        case .iPadMini:
//            return 130
//        case .iPadStandard, .iPadAir:
//            return 150
//        case .iPadPro11:
//            return 160
//        case .iPadPro129:
//            return 180
//        }
//    }
//    
//    var uniformButtonHeight: CGFloat {
//        switch self {
//        case .iPhoneSE:
//            return 28
//        case .iPhoneMini, .iPhoneCompact:
//            return 32
//        case .iPhoneStandard, .iPhonePro:
//            return 36
//        case .iPhoneProMax, .iPhonePlus:
//            return 38
//        case .iPadMini:
//            return 40
//        case .iPadStandard, .iPadAir:
//            return 44
//        case .iPadPro11:
//            return 48
//        case .iPadPro129:
//            return 52
//        }
//    }
//    
//    var uniformButtonWidth: CGFloat {
//        switch self {
//        case .iPhoneSE:
//            return 75
//        case .iPhoneMini, .iPhoneCompact:
//            return 85
//        case .iPhoneStandard, .iPhonePro:
//            return 95
//        case .iPhoneProMax, .iPhonePlus:
//            return 105
//        case .iPadMini:
//            return 110
//        case .iPadStandard, .iPadAir:
//            return 120
//        case .iPadPro11:
//            return 130
//        case .iPadPro129:
//            return 140
//        }
//    }
//    
//    var logoHeight: CGFloat {
//        switch self {
//        case .iPhoneSE:
//            return 16
//        case .iPhoneMini, .iPhoneCompact:
//            return 18
//        case .iPhoneStandard, .iPhonePro:
//            return 25
//        case .iPhoneProMax, .iPhonePlus:
//            return 28
//        case .iPadMini:
//            return 30
//        case .iPadStandard, .iPadAir:
//            return 35
//        case .iPadPro11:
//            return 40
//        case .iPadPro129:
//            return 45
//        }
//    }
//    
//    var tempoMarkingHeight: CGFloat {
//        switch self {
//        case .iPhoneSE:
//            return 32
//        case .iPhoneMini, .iPhoneCompact:
//            return 36
//        case .iPhoneStandard, .iPhonePro:
//            return 40
//        case .iPhoneProMax, .iPhonePlus:
//            return 42
//        case .iPadMini:
//            return 45
//        case .iPadStandard, .iPadAir:
//            return 50
//        case .iPadPro11:
//            return 55
//        case .iPadPro129:
//            return 60
//        }
//    }
//    
//    // MARK: - Spacing
//    var verticalSpacing: CGFloat {
//        switch self {
//        case .iPhoneSE:
//            return 6
//        case .iPhoneMini, .iPhoneCompact:
//            return 8
//        case .iPhoneStandard, .iPhonePro:
//            return 12
//        case .iPhoneProMax, .iPhonePlus:
//            return 14
//        case .iPadMini:
//            return 16
//        case .iPadStandard, .iPadAir:
//            return 20
//        case .iPadPro11:
//            return 24
//        case .iPadPro129:
//            return 28
//        }
//    }
//    
//    var horizontalSpacing: CGFloat {
//        switch self {
//        case .iPhoneSE:
//            return 6
//        case .iPhoneMini, .iPhoneCompact:
//            return 8
//        case .iPhoneStandard, .iPhonePro:
//            return 12
//        case .iPhoneProMax, .iPhonePlus:
//            return 14
//        case .iPadMini:
//            return 16
//        case .iPadStandard, .iPadAir:
//            return 20
//        case .iPadPro11:
//            return 24
//        case .iPadPro129:
//            return 28
//        }
//    }
//    
//    var buttonSpacing: CGFloat {
//        switch self {
//        case .iPhoneSE:
//            return 6
//        case .iPhoneMini, .iPhoneCompact:
//            return 8
//        case .iPhoneStandard, .iPhonePro:
//            return 10
//        case .iPhoneProMax, .iPhonePlus:
//            return 12
//        case .iPadMini:
//            return 16
//        case .iPadStandard, .iPadAir:
//            return 20
//        case .iPadPro11:
//            return 24
//        case .iPadPro129:
//            return 28
//        }
//    }
//    
//    var sectionPadding: CGFloat {
//        switch self {
//        case .iPhoneSE:
//            return 12
//        case .iPhoneMini, .iPhoneCompact:
//            return 16
//        case .iPhoneStandard, .iPhonePro:
//            return 20
//        case .iPhoneProMax, .iPhonePlus:
//            return 22
//        case .iPadMini:
//            return 32
//        case .iPadStandard, .iPadAir:
//            return 40
//        case .iPadPro11:
//            return 48
//        case .iPadPro129:
//            return 56
//        }
//    }
//    
//    var horizontalPadding: CGFloat {
//        switch self {
//        case .iPhoneSE:
//            return 12
//        case .iPhoneMini, .iPhoneCompact:
//            return 16
//        case .iPhoneStandard, .iPhonePro:
//            return 20
//        case .iPhoneProMax, .iPhonePlus:
//            return 24
//        case .iPadMini:
//            return 48
//        case .iPadStandard, .iPadAir:
//            return 60
//        case .iPadPro11:
//            return 72
//        case .iPadPro129:
//            return 84
//        }
//    }
//    
//    // MARK: - Settings-Specific Spacing
//    var settingsSectionSpacing: CGFloat {
//        switch self {
//        case .iPhoneSE:
//            return 12
//        case .iPhoneMini, .iPhoneCompact:
//            return 16
//        case .iPhoneStandard, .iPhonePro:
//            return 18
//        case .iPhoneProMax, .iPhonePlus:
//            return 20
//        case .iPadMini:
//            return 20
//        case .iPadStandard, .iPadAir:
//            return 24
//        case .iPadPro11:
//            return 28
//        case .iPadPro129:
//            return 32
//        }
//    }
//    
//    var settingsItemSpacing: CGFloat {
//        switch self {
//        case .iPhoneSE:
//            return 8
//        case .iPhoneMini, .iPhoneCompact:
//            return 10
//        case .iPhoneStandard, .iPhonePro:
//            return 12
//        case .iPhoneProMax, .iPhonePlus:
//            return 14
//        case .iPadMini:
//            return 14
//        case .iPadStandard, .iPadAir:
//            return 16
//        case .iPadPro11:
//            return 18
//        case .iPadPro129:
//            return 20
//        }
//    }
//    
//    var settingsGroupSpacing: CGFloat {
//        switch self {
//        case .iPhoneSE:
//            return 4
//        case .iPhoneMini, .iPhoneCompact:
//            return 6
//        case .iPhoneStandard, .iPhonePro:
//            return 8
//        case .iPhoneProMax, .iPhonePlus:
//            return 10
//        case .iPadMini:
//            return 10
//        case .iPadStandard, .iPadAir:
//            return 12
//        case .iPadPro11:
//            return 14
//        case .iPadPro129:
//            return 16
//        }
//    }
//    
//    var sectionSpacing: CGFloat {
//        switch self {
//        case .iPhoneSE:
//            return 16
//        case .iPhoneMini, .iPhoneCompact:
//            return 20
//        case .iPhoneStandard, .iPhonePro:
//            return 25
//        case .iPhoneProMax, .iPhonePlus:
//            return 28
//        case .iPadMini:
//            return 30
//        case .iPadStandard, .iPadAir:
//            return 35
//        case .iPadPro11:
//            return 40
//        case .iPadPro129:
//            return 45
//        }
//    }
//    
//    var sliderPadding: CGFloat {
//        switch self {
//        case .iPhoneSE:
//            return 6
//        case .iPhoneMini, .iPhoneCompact:
//            return 8
//        case .iPhoneStandard, .iPhonePro:
//            return 10
//        case .iPhoneProMax, .iPhonePlus:
//            return 12
//        case .iPadMini:
//            return 16
//        case .iPadStandard, .iPadAir:
//            return 20
//        case .iPadPro11:
//            return 24
//        case .iPadPro129:
//            return 28
//        }
//    }
//    
//    // MARK: - BPM Button Sizes
//    var bpmButtonWidth: CGFloat {
//        switch self {
//        case .iPhoneSE:
//            return 32
//        case .iPhoneMini, .iPhoneCompact:
//            return 38
//        case .iPhoneStandard, .iPhonePro:
//            return 45
//        case .iPhoneProMax, .iPhonePlus:
//            return 50
//        case .iPadMini:
//            return 70
//        case .iPadStandard, .iPadAir:
//            return 80
//        case .iPadPro11:
//            return 90
//        case .iPadPro129:
//            return 100
//        }
//    }
//    
//    var bpmButtonHeight: CGFloat {
//        switch self {
//        case .iPhoneSE:
//            return 28
//        case .iPhoneMini, .iPhoneCompact:
//            return 32
//        case .iPhoneStandard, .iPhonePro:
//            return 36
//        case .iPhoneProMax, .iPhonePlus:
//            return 40
//        case .iPadMini:
//            return 45
//        case .iPadStandard, .iPadAir:
//            return 50
//        case .iPadPro11:
//            return 55
//        case .iPadPro129:
//            return 60
//        }
//    }
//    
//    var bpmDisplayMinWidth: CGFloat {
//        switch self {
//        case .iPhoneSE:
//            return 140
//        case .iPhoneMini, .iPhoneCompact:
//            return 160
//        case .iPhoneStandard, .iPhonePro:
//            return 180
//        case .iPhoneProMax, .iPhonePlus:
//            return 200
//        case .iPadMini:
//            return 240
//        case .iPadStandard, .iPadAir:
//            return 280
//        case .iPadPro11:
//            return 320
//        case .iPadPro129:
//            return 360
//        }
//    }
//    
//    // MARK: - Dial Sizing
//    var dialArcSize: CGFloat {
//        switch self {
//        case .iPhoneSE:
//            return 200
//        case .iPhoneMini, .iPhoneCompact:
//            return 240
//        case .iPhoneStandard, .iPhonePro:
//            return 300
//        case .iPhoneProMax, .iPhonePlus:
//            return 340
//        case .iPadMini:
//            return 400
//        case .iPadStandard, .iPadAir:
//            return 600
//        case .iPadPro11:
//            return 650
//        case .iPadPro129:
//            return 700
//        }
//    }
//}
//
//// MARK: - Environment Key
//struct DeviceEnvironmentKey: EnvironmentKey {
//    static let defaultValue = DeviceEnvironment()
//}
//
//extension EnvironmentValues {
//    var deviceEnvironment: DeviceEnvironment {
//        get { self[DeviceEnvironmentKey.self] }
//        set { self[DeviceEnvironmentKey.self] = newValue }
//    }
//}
//
//// MARK: - View Extension for Easy Access
//extension View {
//    func deviceEnvironment(_ environment: DeviceEnvironment) -> some View {
//        self.environment(\.deviceEnvironment, environment)
//    }
//}
