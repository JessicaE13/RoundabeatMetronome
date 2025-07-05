//
//  LibraryView2.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 7/5/25.
//

import SwiftUI

struct LibraryView2: View {

    @State private var selectedTab: Tab = .home
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Title
                Text("My App")
                    .font(.largeTitle)
                    .bold()

                // Pill-style tab buttons
                HStack(spacing: 12) {
                    ForEach(Tab.allCases, id: \.self) { tab in
                        Button(action: {
                            selectedTab = tab
                        }) {
                            Text(tab.title)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    selectedTab == tab ? Color.accentColor : Color(.systemGray5)
                                )
                                .foregroundColor(selectedTab == tab ? .black : .primary)
                                .clipShape(Capsule())
                        }
                    }
                }
Divider()
                    .background(Color(.white))

            
Divider()
                .background(Color(.white))

                // Selected tab view
                Spacer()
            
                    switch selectedTab {
                    case .home:
                     LogoView()
                    case .explore:
                       LogoView()
                    case .profile:
                     ContentView()
                    
                }
                Spacer()
            }
            .padding()
        }
    }
}

enum Tab: CaseIterable {
    case home, explore, profile
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .explore: return "Explore"
        case .profile: return "Profile"
        }
    }
}


#Preview {
    LibraryView2()
}
