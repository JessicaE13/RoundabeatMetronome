import SwiftUI

// MARK: - Subdivision Option Model
struct SubdivisionOption: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let symbol: String
    let multiplier: Double // How many clicks per beat
    let description: String
    
    static func == (lhs: SubdivisionOption, rhs: SubdivisionOption) -> Bool {
        return lhs.multiplier == rhs.multiplier && lhs.name == rhs.name
    }
}

// MARK: - Subdivision Picker View
struct SubdivisionPickerView: View {
    @ObservedObject var metronome: MetronomeEngine
    @Binding var isShowingPicker: Bool
    
    // Available subdivision options
    static let subdivisionOptions: [SubdivisionOption] = [
        SubdivisionOption(
            name: "Quarter Note",
            symbol: "♩",
            multiplier: 1.0,
            description: "One click per beat (standard)"
        ),
        SubdivisionOption(
            name: "Eighth Note",
            symbol: "♫",
            multiplier: 2.0,
            description: "Two clicks per beat"
        ),
        SubdivisionOption(
            name: "Eighth Note Triplet",
            symbol: "3♫",
            multiplier: 3.0,
            description: "Three clicks per beat"
        ),
        SubdivisionOption(
            name: "Sixteenth Note",
            symbol: "♬",
            multiplier: 4.0,
            description: "Four clicks per beat"
        ),
        SubdivisionOption(
            name: "Dotted Eighth",
            symbol: "♪.",
            multiplier: 1.5,
            description: "One and a half clicks per beat"
        ),

    ]
    
    var body: some View {
        ZStack {
            // Base shape with black fill matching other picker views
            RoundedRectangle(cornerRadius: 35)
                .fill(Color.black.opacity(0.95))
            
            // Outer stroke with gradient
            RoundedRectangle(cornerRadius: 35)
                .inset(by: 0.5)
                .stroke(LinearGradient(
                    gradient: Gradient(colors: [Color.white.opacity(0.2), Color.white.opacity(0.15)]),
                    startPoint: .top,
                    endPoint: .bottomTrailing)
                )
            
            VStack(spacing: 25) {
                headerView
                currentSubdivisionDisplay
                subdivisionOptionsSection
            }
            .padding(30)
        }
        .frame(width: 340, height: 520) // Fixed size instead of maxWidth/maxHeight
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
    
    private var headerView: some View {
        HStack {
            Spacer()
            Text("SUBDIVISION")
                .font(.system(size: 12))
                .kerning(1.5)
                .foregroundColor(Color.white.opacity(0.4))
            Spacer()
            Button(action: {
                if #available(iOS 10.0, *) {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                isShowingPicker = false
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(Color.white.opacity(0.6))
                    .font(.system(size: 20, weight: .medium))
            }
        }
    }
    
    private var currentSubdivisionDisplay: some View {
        VStack(spacing: 8) {
            // Find current subdivision or default to quarter note
            let currentSubdivision = SubdivisionPickerView.subdivisionOptions.first(where: {
                $0.multiplier == metronome.subdivisionMultiplier
            }) ?? SubdivisionPickerView.subdivisionOptions[0]
            
            Text(currentSubdivision.symbol)
                .font(.system(size: 36))
                .foregroundColor(Color.white.opacity(0.8))
                .shadow(color: Color.white.opacity(0.1), radius: 0.5, x: 0, y: 0)
                .frame(height: 60)
                .frame(minWidth: 200)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.4))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                )
            
            Text(currentSubdivision.name)
                .font(.system(size: 14))
                .kerning(0.5)
                .foregroundColor(Color.white.opacity(0.6))
        }
    }
    
    private var subdivisionOptionsSection: some View {
        VStack(spacing: 15) {
            Text("SELECT SUBDIVISION")
                .font(.system(size: 10))
                .kerning(1.2)
                .foregroundColor(Color.white.opacity(0.4))
            
            VStack(spacing: 12) {
                ForEach(SubdivisionPickerView.subdivisionOptions) { subdivision in
                    subdivisionButton(subdivision: subdivision)
                }
            }
        }
    }
    
    private func subdivisionButton(subdivision: SubdivisionOption) -> some View {
        let isSelected = subdivision.multiplier == metronome.subdivisionMultiplier
        
        return Button(action: {
            if #available(iOS 10.0, *) {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
            metronome.updateSubdivision(to: subdivision.multiplier)
            isShowingPicker = false
        }) {
            HStack(spacing: 16) {
                // Musical symbol
                Text(subdivision.symbol)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? Color.white.opacity(0.9) : Color.white.opacity(0.6))
                    .frame(width: 40, alignment: .center)
                
                // Subdivision info
                VStack(alignment: .leading, spacing: 4) {
                    Text(subdivision.name)
                        .font(.system(size: 16))
                        .kerning(0.5)
                        .foregroundColor(isSelected ? Color.white.opacity(0.9) : Color.white.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(subdivision.description)
                        .font(.system(size: 12))
                        .foregroundColor(isSelected ? Color.white.opacity(0.6) : Color.white.opacity(0.4))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.8))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.white.opacity(0.15) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? Color.white.opacity(0.25) : Color.white.opacity(0.1),
                                lineWidth: 1
                            )
                    )
            )
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        BackgroundView()
        SubdivisionPickerView(
            metronome: MetronomeEngine(),
            isShowingPicker: .constant(true)
        )
    }
}
