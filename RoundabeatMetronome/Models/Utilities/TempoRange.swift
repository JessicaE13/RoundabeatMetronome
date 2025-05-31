import SwiftUI

// MARK: - Tempo Range Data Structure
struct TempoRange {
    let name: String
    let minBPM: Int
    let maxBPM: Int
    let midBPM: Int
    
    init(name: String, minBPM: Int, maxBPM: Int) {
        self.name = name
        self.minBPM = minBPM
        self.maxBPM = maxBPM
        self.midBPM = (minBPM + maxBPM) / 2
    }
    
    static let allRanges: [TempoRange] = [
        TempoRange(name: "Larghissimo", minBPM: 20, maxBPM: 24),
        TempoRange(name: "Grave", minBPM: 25, maxBPM: 40),
        TempoRange(name: "Largo", minBPM: 41, maxBPM: 60),
        TempoRange(name: "Larghetto", minBPM: 61, maxBPM: 66),
        TempoRange(name: "Adagio", minBPM: 67, maxBPM: 72),
        TempoRange(name: "Adagietto", minBPM: 73, maxBPM: 76),
        TempoRange(name: "Andante", minBPM: 77, maxBPM: 80),
        TempoRange(name: "Andantino", minBPM: 81, maxBPM: 92),
        TempoRange(name: "Andante Moderato", minBPM: 93, maxBPM: 108),
        TempoRange(name: "Moderato", minBPM: 109, maxBPM: 112),
        TempoRange(name: "Allegretto", minBPM: 113, maxBPM: 119),
        TempoRange(name: "Allegro", minBPM: 120, maxBPM: 168),
        TempoRange(name: "Vivace", minBPM: 169, maxBPM: 172),
        TempoRange(name: "Vivacissimo", minBPM: 173, maxBPM: 176),
        TempoRange(name: "Presto", minBPM: 177, maxBPM: 200),
        TempoRange(name: "Prestissimo", minBPM: 201, maxBPM: 400)
    ]
    
    static func getCurrentRange(for tempo: Double) -> TempoRange {
        let currentTempo = Int(tempo)
        return allRanges.first { range in
            currentTempo >= range.minBPM && currentTempo <= range.maxBPM
        } ?? allRanges.first { $0.name == "Allegro" }!
    }
}
