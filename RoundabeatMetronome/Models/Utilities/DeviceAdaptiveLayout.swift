import SwiftUI
import UIKit

// MARK: - Device Type Detection
enum DeviceType {
    case iPhone
    case iPadMini
    case iPad
    case iPadPro
    
    static var current: DeviceType {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let screenSize = max(screenWidth, screenHeight)
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .iPhone
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
        case .iPhone:
            return false
        case .iPadMini, .iPad, .iPadPro:
            return true
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
    
    static let iPhone = FontScaleFactors(
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
    
    static let iPadMini = FontScaleFactors(
        tiny: 1.1,
        caption: 1.1,
        footnote: 1.15,
        subheadline: 1.2,
        callout: 1.2,
        body: 1.25,
        headline: 1.3,
        title3: 1.35,
        title2: 1.4,
        title: 1.45,
        largeTitle: 1.5,
        custom: 1.3
    )
    
    static let iPad = FontScaleFactors(
        tiny: 1.2,
        caption: 1.25,
        footnote: 1.3,
        subheadline: 1.4,
        callout: 1.45,
        body: 1.5,
        headline: 1.6,
        title3: 1.7,
        title2: 1.8,
        title: 1.9,
        largeTitle: 2.0,
        custom: 1.6
    )
    
    static let iPadPro = FontScaleFactors(
        tiny: 1.4,
        caption: 1.5,
        footnote: 1.6,
        subheadline: 1.7,
        callout: 1.8,
        body: 1.9,
        headline: 2.0,
        title3: 2.2,
        title2: 2.4,
        title: 2.6,
        largeTitle: 2.8,
        custom: 2.0
    )
    
    static var current: FontScaleFactors {
        switch DeviceType.current {
        case .iPhone:
            return .iPhone
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
        case .iPhone:
            scaleFactor = 1.0
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
            Text("Device: \(DeviceType.current)")
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
        }
        .padding(.all, AdaptiveSizing.current.padding(20))
    }
}

#Preview("iPhone") {
    AdaptiveTextExample()
        .preferredColorScheme(.dark)
}

#Preview("iPad") {
    AdaptiveTextExample()
        .preferredColorScheme(.dark)
}
