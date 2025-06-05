//
//  SimpleAdaptiveLayout.swift
//  RoundabeatMetronome
//
//  Simple, safe adaptive layout that won't break existing code
//

import SwiftUI
import UIKit

// MARK: - Simple Device Detection
extension UIDevice {
    static var isCompactDevice: Bool {
        // iPhone SE and smaller devices
        return UIScreen.main.bounds.width <= 375
    }
    
    static var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    static var adaptiveScale: CGFloat {
        let width = UIScreen.main.bounds.width
        switch width {
        case 0..<375:     // iPhone SE
            return 0.85
        case 375..<390:   // iPhone 12/13
            return 1.0
        case 390..<430:   // iPhone 12/13 Pro Max
            return 1.1
        default:          // iPad
            return 1.2
        }
    }
}

// MARK: - Simple Adaptive Values
struct AdaptiveValues {
    static var bpmFontSize: CGFloat {
        if UIDevice.isCompactDevice {
            return 70  // Smaller for iPhone SE
        } else if UIDevice.current.isIPad {
            return 120
        } else {
            return 90  // Standard iPhone
        }
    }
    
    static var dialSize: CGFloat {
        if UIDevice.isCompactDevice {
            return 200  // Bigger dial for iPhone SE
        } else if UIDevice.current.isIPad {
            return 280
        } else {
            return 220  // Standard iPhone
        }
    }
    
    static var horizontalPadding: CGFloat {
        if UIDevice.isCompactDevice {
            return 16   // Less padding on iPhone SE
        } else if UIDevice.current.isIPad {
            return 40
        } else {
            return 24   // Standard iPhone
        }
    }
    
    static var sectionSpacing: CGFloat {
        if UIDevice.isCompactDevice {
            return 8    // Tighter spacing on iPhone SE
        } else if UIDevice.current.isIPad {
            return 24
        } else {
            return 12   // Standard iPhone
        }
    }
    
    static var componentSpacing: CGFloat {
        if UIDevice.isCompactDevice {
            return 6    // Tighter spacing on iPhone SE
        } else if UIDevice.current.isIPad {
            return 20
        } else {
            return 12   // Standard iPhone
        }
    }
    
    static var chevronSize: CGFloat {
        if UIDevice.isCompactDevice {
            return 14   // Smaller chevrons on iPhone SE
        } else if UIDevice.current.isIPad {
            return 24
        } else {
            return 18   // Standard iPhone
        }
    }
    
    static var chevronFrameSize: CGFloat {
        if UIDevice.isCompactDevice {
            return 24   // Smaller touch targets on iPhone SE
        } else if UIDevice.current.isIPad {
            return 50
        } else {
            return 30   // Standard iPhone
        }
    }
}

// MARK: - Simple Adaptive View Modifier
struct AdaptiveFont: ViewModifier {
    let baseSize: CGFloat
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: baseSize * UIDevice.adaptiveScale))
    }
}

extension View {
    func adaptiveFont(size: CGFloat) -> some View {
        modifier(AdaptiveFont(baseSize: size))
    }
    
    func adaptivePadding() -> some View {
        self.padding(.horizontal, AdaptiveValues.horizontalPadding)
    }
}
