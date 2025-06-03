//
//  DeviceUtilities.swift
//  RoundabeatMetronome
//
//  Device-specific utilities for adaptive layout
//

import SwiftUI
import UIKit

// MARK: - Device Detection Extensions
extension UIDevice {
    static var isIPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isIPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    static var screenSize: CGSize {
        return UIScreen.main.bounds.size
    }
    
    static var isLargeScreen: Bool {
        let screenWidth = UIScreen.main.bounds.width
        return screenWidth >= 768 // iPad size threshold
    }
}

// MARK: - Adaptive Layout Constants
struct DeviceConstants {
    
    // MARK: - Spacing
    struct Spacing {
        static let small: CGFloat = UIDevice.isIPad ? 12 : 8
        static let medium: CGFloat = UIDevice.isIPad ? 24 : 16
        static let large: CGFloat = UIDevice.isIPad ? 40 : 24
        static let extraLarge: CGFloat = UIDevice.isIPad ? 60 : 40
    }
    
    // MARK: - Padding
    struct Padding {
        static let horizontal: CGFloat = UIDevice.isIPad ? 40 : 24
        static let vertical: CGFloat = UIDevice.isIPad ? 32 : 20
        static let content: CGFloat = UIDevice.isIPad ? 60 : 40
    }
    
    // MARK: - Font Sizes
    struct FontSize {
        static let caption: CGFloat = UIDevice.isIPad ? 14 : 10
        static let body: CGFloat = UIDevice.isIPad ? 18 : 14
        static let title: CGFloat = UIDevice.isIPad ? 24 : 18
        static let largeTitle: CGFloat = UIDevice.isIPad ? 32 : 24
        static let bpm: CGFloat = UIDevice.isIPad ? 120 : 90
    }
    
    // MARK: - Component Sizes
    struct ComponentSize {
        static let buttonHeight: CGFloat = UIDevice.isIPad ? 60 : 44
        static let iconSize: CGFloat = UIDevice.isIPad ? 28 : 20
        static let dialSize: CGFloat = UIDevice.isIPad ? 280 : 220
        static let knobSize: CGFloat = UIDevice.isIPad ? 120 : 90
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = UIDevice.isIPad ? 12 : 8
        static let medium: CGFloat = UIDevice.isIPad ? 20 : 15
        static let large: CGFloat = UIDevice.isIPad ? 30 : 25
    }
}

// MARK: - Adaptive Layout Helpers
extension View {
    /// Apply device-appropriate padding
    func adaptivePadding(_ edges: Edge.Set = .all) -> some View {
        self.padding(edges, DeviceConstants.Padding.horizontal)
    }
    
    /// Apply device-appropriate spacing
    func adaptiveSpacing(_ size: DeviceConstants.Spacing.Type) -> some View {
        self.padding(.vertical, DeviceConstants.Spacing.medium)
    }
    
    /// Limit content width on larger screens
    func adaptiveContentWidth() -> some View {
        Group {
            if UIDevice.isIPad {
                self.frame(maxWidth: min(700, UIScreen.main.bounds.width * 0.8))
            } else {
                self
            }
        }
    }
}

// MARK: - Responsive Grid Helper
struct AdaptiveGrid<Content: View>: View {
    let items: [GridItem]
    let spacing: CGFloat
    let content: () -> Content
    
    init(
        minimumItemWidth: CGFloat = 150,
        spacing: CGFloat = DeviceConstants.Spacing.medium,
        @ViewBuilder content: @escaping () -> Content
    ) {
        let screenWidth = UIScreen.main.bounds.width
        let availableWidth = screenWidth - (DeviceConstants.Padding.horizontal * 2)
        let itemCount = max(1, Int(availableWidth / minimumItemWidth))
        
        self.items = Array(repeating: GridItem(.flexible(), spacing: spacing), count: itemCount)
        self.spacing = spacing
        self.content = content
    }
    
    var body: some View {
        LazyVGrid(columns: items, spacing: spacing) {
            content()
        }
    }
}

// MARK: - Safe Area Helper
extension View {
    func adaptiveSafeAreaPadding() -> some View {
        GeometryReader { geometry in
            self.padding(.top, geometry.safeAreaInsets.top + DeviceConstants.Spacing.large)
                .padding(.bottom, geometry.safeAreaInsets.bottom + DeviceConstants.Spacing.medium)
        }
    }
}

// MARK: - Haptic Feedback Helper
struct HapticManager {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium, intensity: CGFloat = 1.0) {
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.impactOccurred(intensity: intensity)
        }
    }
    
    static func selection() {
        if #available(iOS 10.0, *) {
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
    
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        if #available(iOS 10.0, *) {
            UINotificationFeedbackGenerator().notificationOccurred(type)
        }
    }
}

// MARK: - Animation Presets
struct AdaptiveAnimations {
    static let quickSpring = Animation.spring(response: 0.3, dampingFraction: 0.8)
    static let smoothSpring = Animation.spring(response: 0.5, dampingFraction: 0.9)
    static let easeInOut = Animation.easeInOut(duration: UIDevice.isIPad ? 0.4 : 0.3)
    static let fastEase = Animation.easeInOut(duration: UIDevice.isIPad ? 0.25 : 0.2)
}

// MARK: - Color Extensions for Better Accessibility
extension Color {
    static let adaptiveBackground = Color(UIColor.systemBackground)
    static let adaptiveSecondaryBackground = Color(UIColor.secondarySystemBackground)
    static let adaptiveLabel = Color(UIColor.label)
    static let adaptiveSecondaryLabel = Color(UIColor.secondaryLabel)
}

// MARK: - Orientation Detection
extension UIDevice {
    static var isLandscape: Bool {
        return UIDevice.current.orientation.isLandscape
    }
    
    static var isPortrait: Bool {
        return UIDevice.current.orientation.isPortrait
    }
}

// MARK: - Screen Size Categories
enum ScreenSizeCategory {
    case compact      // iPhone SE, iPhone 8
    case regular      // iPhone 12, iPhone 13
    case large        // iPhone 12 Pro Max, iPhone 13 Pro Max
    case extraLarge   // iPad Mini
    case huge         // iPad Pro
    
    static var current: ScreenSizeCategory {
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        let minDimension = min(width, height)
        
        switch minDimension {
        case 0..<375:
            return .compact
        case 375..<390:
            return .regular
        case 390..<430:
            return .large
        case 430..<768:
            return .extraLarge
        default:
            return .huge
        }
    }
}

// MARK: - Adaptive Component Builder
struct AdaptiveComponent {
    static func button(
        title: String,
        action: @escaping () -> Void,
        style: ButtonStyle = .primary
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: DeviceConstants.FontSize.body, weight: .medium))
                .foregroundColor(.white)
                .frame(height: DeviceConstants.ComponentSize.buttonHeight)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: DeviceConstants.CornerRadius.medium)
                        .fill(style.backgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: DeviceConstants.CornerRadius.medium)
                                .stroke(style.borderColor, lineWidth: 1)
                        )
                )
        }
    }
    
    enum ButtonStyle {
        case primary
        case secondary
        case destructive
        
        var backgroundColor: Color {
            switch self {
            case .primary:
                return Color.white.opacity(0.15)
            case .secondary:
                return Color.white.opacity(0.05)
            case .destructive:
                return Color.red.opacity(0.15)
            }
        }
        
        var borderColor: Color {
            switch self {
            case .primary:
                return Color.white.opacity(0.25)
            case .secondary:
                return Color.white.opacity(0.1)
            case .destructive:
                return Color.red.opacity(0.25)
            }
        }
    }
}

// MARK: - Preview Helper
#if DEBUG
struct DevicePreviewHelper {
    static func iPhonePreview<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .previewDevice("iPhone 14")
            .previewDisplayName("iPhone")
    }
    
    static func iPadPreview<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
            .previewDisplayName("iPad Pro")
    }
    
    static func multiDevicePreview<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        Group {
            iPhonePreview(content: content)
            iPadPreview(content: content)
        }
    }
}
#endif
