//
//  PaywallView.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 7/13/25.
//

import SwiftUI
import RevenueCat

struct PaywallView: View {
    
    @Binding var isPresented: Bool
    
    @State
    private(set) var isPurchasing: Bool = false
    private(set) var offering: Offering? = UserViewModel.shared.offerings?.current
    
    private let footerText = "Don't forget to add your subscription terms and conditions. Read more about this here: https://www.revenuecat.com/blog/schedule-2-section-3-a-b"
    
    @State private var error: NSError?
    @State private var displayError: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    Section(header: Text("Pro"), footer: Text(footerText)) {
                        ForEach(offering?.availablePackages ?? []) { package in
                            PackageCellView(package: Package)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationBarTitle("✨ Roundabeat Metronome Pro")
            }
        }
        
    }
}


struct PackageCellView: View {
    let package: Package
    let onSelection: (Package) -> Void
    var body: some View {
        HStack {
            VStack {
                HStack {
                    Text(package.storeProduct.localizedTitle)
                        .font(.title3)
                        .bold()
                    
                    Spacer()
                }
                HStack {
                    Text(package.terms(for: package))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .padding([.top, .bottom], 8.0)
            
            Spacer()
            
            Text(package.storeProduct.localizedPriceString)
                .font(.title3)
                .bold()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onSelection(package)
        }
    }
}

extension NSError: LocalizedError {
    public var errorDescription: String? {
        return self.localizedDescription
    }
}


#Preview {

        PackageCellView(package: .init(identifier: "com.example.test", packageType: .subscription, storeProduct: .init(id: "com.example.test"), offeringIdentifier: nil, webCheckoutUrl: nil))
    
}
