//
//  AppTheme.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 4/23/25.
//

import SwiftUI

enum ThemeColor: String, CaseIterable, Identifiable {
    case blue = "Blue"
    case gray = "Gray"
    case green = "Green"
    case lavender = "Lavender"
    case red = "Red"
    case white = "White"
    case yellow = "Yellow"
    
    var id: String { self.rawValue }
}

struct AppTheme {
    // Use AppStorage for persistence between app launches
    @AppStorage("selectedThemeColor") static var selectedTheme: String = ThemeColor.gray.rawValue
    
    // Main background color
    static var backgroundColor: Color {
        Color("skin\(selectedTheme)")
    }
    
    // Additional theme colors
    static var accentColor: Color {
        Color("accent\(selectedTheme)")
    }
    
    static var textColor: Color {
        // White theme might need dark text
        if selectedTheme == ThemeColor.white.rawValue {
            return Color.black
        }
        return Color("text\(selectedTheme)")
    }
    
    // Function to change the theme
    static func changeTheme(to newTheme: ThemeColor) {
        selectedTheme = newTheme.rawValue
    }
    
    // Get current theme as enum
    static var currentTheme: ThemeColor {
        ThemeColor(rawValue: selectedTheme) ?? .gray
    }
}
