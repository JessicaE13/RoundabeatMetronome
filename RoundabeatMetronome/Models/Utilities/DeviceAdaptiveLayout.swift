import SwiftUI
import UIKit

// MARK: - Device Type Detection
enum DeviceType {
    case iPhoneSmall     // iPhone SE, iPhone 8 and smaller
    case iPhoneRegular   // iPhone 12 mini, iPhone 13 mini, iPhone 14, iPhone 15
    case iPhoneLarge     // iPhone 12, iPhone 13, iPhone 14 Plus, iPhone 15 Plus
    case iPhoneXL        // iPhone 12 Pro Max, iPhone 13 Pro Max, iPhone 14 Pro Max, iPhone 15 Pro Max
    case iPadMini
    case iPad
    case iPadPro
    
    static var current: DeviceType {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let screenSize = max(screenWidth, screenHeight)
        let minScreenSize = min(screenWidth, screenHeight)
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            // iPhone detection based on screen size
            // iPhone SE (1st, 2nd, 3rd gen), iPhone 8 and smaller
            if screenSize <= 667 {
                return .iPhoneSmall
            }
            // iPhone 12 mini, iPhone 13 mini (2340×1080)
            else if screenSize <= 812 && minScreenSize <= 375 {
                return .iPhoneRegular
            }
            // iPhone 14, iPhone 15 (standard sizes) (2556×1179)
            else if screenSize <= 852 {
                return .iPhoneRegular
            }
            // iPhone 14 Plus, iPhone 15 Plus (2796×1290)
            else if screenSize <= 932 {
                return .iPhoneLarge
            }
            // iPhone Pro Max models (2778×1284 and larger)
            else {
                return .iPhoneXL
            }
        } else {
            // iPad detection based on screen size
            if screenSize <= 1080 {
                return .iPadMini  // iPad Mini
            } else if screenSize <= 1194 {
                return .iPad      // Standard iPad
            } else {
                return .iPadPro   // iPad Pro (11" and 12.9")
            }
        }
    }
    
    var isIPad: Bool {
        switch self {
        case .iPhoneSmall, .iPhoneRegular, .iPhoneLarge, .iPhoneXL:
            return false
        case .iPadMini, .iPad, .iPadPro:
            return true
        }
    }
    
    var isIPhone: Bool {
        return !isIPad
    }
    
    var displayName: String {
        switch self {
        case .iPhoneSmall:
            return "iPhone Small"
        case .iPhoneRegular:
            return "iPhone Regular"
        case .iPhoneLarge:
            return "iPhone Large"
        case .iPhoneXL:
            return "iPhone XL"
        case .iPadMini:
            return "iPad Mini"
        case .iPad:
            return "iPad"
        case .iPadPro:
            return "iPad Pro"
        }
    }
}

// MARK: - Font Scale Factors
struct FontScaleFactors {
    let tiny: CGFloat
    let caption: CGFloat
    let footnote: CGFloat
    let subheadline: CGFloat
    let callout: CGFloat
    let body: CGFloat
    let headline: CGFloat
    let title3: CGFloat
    let title2: CGFloat
    let title: CGFloat
    let largeTitle: CGFloat
    let custom: CGFloat
    
    static let iPhoneSmall = FontScaleFactors(
        tiny: 0.85,
        caption: 0.85,
        footnote: 0.9,
        subheadline: 0.9,
        callout: 0.95,
        body: 0.95,
        headline: 0.95,
        title3: 0.95,
        title2: 0.95,
        title: 0.95,
        largeTitle: 1.0,
        custom: 0.85
    )
    
    static let iPhoneRegular = FontScaleFactors(
        tiny: 1.0,
        caption: 1.0,
        footnote: 1.0,
        subheadline: 1.0,
        callout: 1.0,
        body: 1.0,
        headline: 1.0,
        title3: 1.0,
        title2: 1.0,
        title: 1.0,
        largeTitle: 1.0,
        custom: 1.0
    )
    
    static let iPhoneLarge = FontScaleFactors(
        tiny: 1.05,
        caption: 1.05,
        footnote: 1.05,
        subheadline: 1.05,
        callout: 1.05,
        body: 1.05,
        headline: 1.05,
        title3: 1.05,
        title2: 1.05,
        title: 1.05,
        largeTitle: 1.1,
        custom: 1.05
    )
    
    static let iPhoneXL = FontScaleFactors(
        tiny: 1.1,
        caption: 1.1,
        footnote: 1.1,
        subheadline: 1.1,
        callout: 1.1,
        body: 1.1,
        headline: 1.1,
        title3: 1.1,
        title2: 1.1,
        title: 1.1,
        largeTitle: 1.15,
        custom: 1.1
    )
    
    static let iPadMini = FontScaleFactors(
        tiny: 1.0,
        caption: 1.0,
        footnote: 1.05,
        subheadline: 1.1,
        callout: 1.1,
        body: 1.15,
        headline: 1.2,
        title3: 1.25,
        title2: 1.3,
        title: 1.35,
        largeTitle: 1.4,
        custom: 1.2
    )
    
    static let iPad = FontScaleFactors(
        tiny: 1.1,
        caption: 1.15,
        footnote: 1.2,
        subheadline: 1.25,
        callout: 1.3,
        body: 1.35,
        headline: 1.4,
        title3: 1.5,
        title2: 1.6,
        title: 1.7,
        largeTitle: 1.8,
        custom: 1.4
    )
    
    static let iPadPro = FontScaleFactors(
        tiny: 1.2,
        caption: 1.3,
        footnote: 1.4,
        subheadline: 1.5,
        callout: 1.6,
        body: 1.7,
        headline: 1.8,
        title3: 2.0,
        title2: 2.2,
        title: 2.4,
        largeTitle: 2.6,
        custom: 1.8
    )
    
    static var current: FontScaleFactors {
        switch DeviceType.current {
        case .iPhoneSmall:
            return .iPhoneSmall
        case .iPhoneRegular:
            return .iPhoneRegular
        case .iPhoneLarge:
            return .iPhoneLarge
        case .iPhoneXL:
            return .iPhoneXL
        case .iPadMini:
            return .iPadMini
        case .iPad:
            return .iPad
        case .iPadPro:
            return .iPadPro
        }
    }
}

// MARK: - Custom Font Extension
extension Font {
    
    // System font sizes adapted for device
    static func adaptiveSystem(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        let scaleFactor = FontScaleFactors.current
        
        let baseSize: CGFloat
        switch style {
        case .caption2:
            baseSize = 11 * scaleFactor.tiny
        case .caption:
            baseSize = 12 * scaleFactor.caption
        case .footnote:
            baseSize = 13 * scaleFactor.footnote
        case .subheadline:
            baseSize = 15 * scaleFactor.subheadline
        case .callout:
            baseSize = 16 * scaleFactor.callout
        case .body:
            baseSize = 17 * scaleFactor.body
        case .headline:
            baseSize = 17 * scaleFactor.headline
        case .title3:
            baseSize = 20 * scaleFactor.title3
        case .title2:
            baseSize = 22 * scaleFactor.title2
        case .title:
            baseSize = 28 * scaleFactor.title
        case .largeTitle:
            baseSize = 34 * scaleFactor.largeTitle
        @unknown default:
            baseSize = 17 * scaleFactor.body
        }
        
        return .system(size: baseSize, weight: weight)
    }
    
    // Custom font sizes adapted for device
    static func adaptiveCustom(_ fontName: String, size: CGFloat) -> Font {
        let scaleFactor = FontScaleFactors.current.custom
        return .custom(fontName, size: size * scaleFactor)
    }
    
    // Simple size adaptation
    static func adaptiveSize(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let scaleFactor = FontScaleFactors.current.custom
        return .system(size: size * scaleFactor, weight: weight)
    }
}

// MARK: - View Extension for Adaptive Text
extension View {
    
    /// Apply adaptive font sizing based on device type
    /// - Parameters:
    ///   - style: The text style to adapt
    ///   - weight: Font weight
    /// - Returns: View with adaptive font
    func adaptiveFont(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> some View {
        self.font(.adaptiveSystem(style, weight: weight))
    }
    
    /// Apply adaptive custom font sizing based on device type
    /// - Parameters:
    ///   - fontName: Custom font name
    ///   - size: Base font size (will be scaled)
    /// - Returns: View with adaptive custom font
    func adaptiveCustomFont(_ fontName: String, size: CGFloat) -> some View {
        self.font(.adaptiveCustom(fontName, size: size))
    }
    
    /// Apply adaptive font size based on device type
    /// - Parameters:
    ///   - size: Base font size (will be scaled)
    ///   - weight: Font weight
    /// - Returns: View with adaptive font size
    func adaptiveFontSize(_ size: CGFloat, weight: Font.Weight = .regular) -> some View {
        self.font(.adaptiveSize(size, weight: weight))
    }
}

// MARK: - Adaptive Spacing and Sizing
struct AdaptiveSizing {
    static var current: AdaptiveSizing {
        AdaptiveSizing()
    }
    
    private let scaleFactor: CGFloat
    
    init() {
        switch DeviceType.current {
        case .iPhoneSmall:
            scaleFactor = 0.85
        case .iPhoneRegular:
            scaleFactor = 1.0
        case .iPhoneLarge:
            scaleFactor = 1.05
        case .iPhoneXL:
            scaleFactor = 1.1
        case .iPadMini:
            scaleFactor = 1.3
        case .iPad:
            scaleFactor = 1.6
        case .iPadPro:
            scaleFactor = 2.0
        }
    }
    
    func spacing(_ baseSpacing: CGFloat) -> CGFloat {
        return baseSpacing * scaleFactor
    }
    
    func padding(_ basePadding: CGFloat) -> CGFloat {
        return basePadding * scaleFactor
    }
    
    func size(_ baseSize: CGFloat) -> CGFloat {
        return baseSize * scaleFactor
    }
    
    func cornerRadius(_ baseRadius: CGFloat) -> CGFloat {
        return baseRadius * scaleFactor
    }
    
    func lineWidth(_ baseWidth: CGFloat) -> CGFloat {
        return baseWidth * scaleFactor
    }
    
    // Add device-specific adjustments for special cases
    func adjustedSize(_ baseSize: CGFloat, forDeviceType deviceType: DeviceType? = nil) -> CGFloat {
        let targetDevice = deviceType ?? DeviceType.current
        
        switch targetDevice {
        case .iPhoneSmall:
            return baseSize * 0.85
        case .iPhoneRegular:
            return baseSize * 1.0
        case .iPhoneLarge:
            return baseSize * 1.05
        case .iPhoneXL:
            return baseSize * 1.1
        case .iPadMini:
            return baseSize * 1.3
        case .iPad:
            return baseSize * 1.6
        case .iPadPro:
            return baseSize * 2.0
        }
    }
}

// MARK: - View Extension for Adaptive Sizing
extension View {
    
    /// Apply adaptive padding based on device type
    func adaptivePadding(_ baseEdges: Edge.Set = .all, _ basePadding: CGFloat) -> some View {
        self.padding(baseEdges, AdaptiveSizing.current.padding(basePadding))
    }
    
    /// Apply adaptive padding to all edges based on device type
    func adaptivePadding(_ basePadding: CGFloat) -> some View {
        self.padding(.all, AdaptiveSizing.current.padding(basePadding))
    }
    
    /// Apply adaptive frame size based on device type
    func adaptiveFrame(width: CGFloat? = nil, height: CGFloat? = nil, alignment: Alignment = .center) -> some View {
        let sizing = AdaptiveSizing.current
        return self.frame(
            width: width.map { sizing.size($0) },
            height: height.map { sizing.size($0) },
            alignment: alignment
        )
    }
    
    /// Apply adaptive corner radius based on device type
    func adaptiveCornerRadius(_ baseRadius: CGFloat) -> some View {
        self.cornerRadius(AdaptiveSizing.current.cornerRadius(baseRadius))
    }
}

// MARK: - Example Usage and Preview
struct AdaptiveTextExample: View {
    var body: some View {
        VStack(spacing: AdaptiveSizing.current.spacing(20)) {
            Text("Device: \(DeviceType.current.displayName)")
                .adaptiveFont(.headline)
            
            Text("Large BPM Number")
                .adaptiveCustomFont("Kanit-SemiBold", size: 90)
            
            Text("Subtitle Text")
                .adaptiveFont(.subheadline)
            
            Text("Body Text")
                .adaptiveFont(.body)
            
            Text("Caption Text")
                .adaptiveFont(.caption)
                
            Button("Button Text") {
                // Action
            }
            .adaptiveFont(.callout, weight: .medium)
            .adaptivePadding(.horizontal, 20)
            .adaptivePadding(.vertical, 12)
            .background(Color.blue)
            .adaptiveCornerRadius(8)
            .foregroundColor(.white)
            
            // TimeSignature-style button for testing
            HStack(spacing: AdaptiveSizing.current.spacing(2)) {
                Text("TIME  ")
                    .adaptiveFont(.subheadline, weight: .medium)
                    .kerning(AdaptiveSizing.current.spacing(1.2))
                    .foregroundColor(Color.white.opacity(0.6))
                
                Text("4")
                    .adaptiveCustomFont("Kanit-Regular", size: 14)
                    .kerning(AdaptiveSizing.current.spacing(0.8))
                
                Text("/")
                    .adaptiveCustomFont("Kanit-Regular", size: 14)
                    .kerning(AdaptiveSizing.current.spacing(0.8))
                
                Text("4")
                    .adaptiveCustomFont("Kanit-Regular", size: 14)
                    .kerning(AdaptiveSizing.current.spacing(0.8))
            }
            .frame(maxWidth: .infinity, minHeight: AdaptiveSizing.current.size(38))
            .background(
                RoundedRectangle(cornerRadius: AdaptiveSizing.current.cornerRadius(12))
                    .fill(Color.black.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: AdaptiveSizing.current.cornerRadius(12))
                            .stroke(Color.white.opacity(0.25), lineWidth: AdaptiveSizing.current.lineWidth(1))
                    )
            )
        }
        .padding(.all, AdaptiveSizing.current.padding(20))
    }
}

#Preview("iPhone Small") {
    AdaptiveTextExample()
        .preferredColorScheme(.dark)
}

#Preview("iPad") {
    AdaptiveTextExample()
        .preferredColorScheme(.dark)
}
