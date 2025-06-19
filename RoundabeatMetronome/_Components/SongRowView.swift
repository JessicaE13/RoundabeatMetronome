//
//  SongRowView.swift
//  RoundabeatMetronome
//

import SwiftUI

// MARK: - Song Row View
struct SongRowView: View {
    let song: Song
    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onToggleFavorite: () -> Void
    
    @State private var showingActionSheet = false
    
    // Get screen dimensions directly
    private var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    // Check if device is iPad
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Music note icon
                Image(systemName: "music.note")
                    .font(.system(size: iconSize, weight: .medium))
                    .foregroundColor(.accentColor)
                    .frame(width: iconFrameSize, height: iconFrameSize)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.accentColor.opacity(0.1))
                    )
                
                // Song info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(song.title)
                            .font(.system(size: titleFontSize, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        if song.isFavorite {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.red)
                        }
                        
                        Spacer()
                    }
                    
                    if !song.artist.isEmpty {
                        Text(song.artist)
                            .font(.system(size: subtitleFontSize))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    HStack(spacing: 8) {
                        // BPM
                        Text("\(song.bpm) BPM")
                            .font(.system(size: detailFontSize, weight: .medium))
                            .foregroundColor(.accentColor)
                        
                        // Time signature
                        if song.timeSignature.numerator != 4 || song.timeSignature.denominator != 4 {
                            Text(song.timeSignature.displayString)
                                .font(.system(size: detailFontSize))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                }
                
                // More button
                Button(action: {
                    showingActionSheet = true
                }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .buttonStyle(.plain)
        .padding(rowPadding)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .confirmationDialog("Song Options", isPresented: $showingActionSheet, titleVisibility: .visible) {
            Button(song.isFavorite ? "Remove from Favorites" : "Add to Favorites") {
                onToggleFavorite()
            }
            
            Button("Edit Song") {
                onEdit()
            }
            
            Button("Delete Song", role: .destructive) {
                onDelete()
            }
            
            Button("Cancel", role: .cancel) { }
        }
    }
    
    // MARK: - Responsive Properties
    
    private var iconSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 18 :
                   screenWidth <= 834 ? 20 :
                   screenWidth <= 1024 ? 22 :
                   24
        } else {
            return screenWidth <= 320 ? 14 :
                   screenWidth <= 375 ? 16 :
                   screenWidth <= 393 ? 18 :
                   20
        }
    }
    
    private var iconFrameSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 36 :
                   screenWidth <= 834 ? 40 :
                   screenWidth <= 1024 ? 44 :
                   48
        } else {
            return screenWidth <= 320 ? 28 :
                   screenWidth <= 375 ? 32 :
                   screenWidth <= 393 ? 36 :
                   40
        }
    }
    
    private var titleFontSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 16 :
                   screenWidth <= 834 ? 18 :
                   screenWidth <= 1024 ? 20 :
                   22
        } else {
            return screenWidth <= 320 ? 14 :
                   screenWidth <= 375 ? 16 :
                   screenWidth <= 393 ? 18 :
                   20
        }
    }
    
    private var subtitleFontSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 14 :
                   screenWidth <= 834 ? 15 :
                   screenWidth <= 1024 ? 16 :
                   17
        } else {
            return screenWidth <= 320 ? 12 :
                   screenWidth <= 375 ? 13 :
                   screenWidth <= 393 ? 14 :
                   15
        }
    }
    
    private var detailFontSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 12 :
                   screenWidth <= 834 ? 13 :
                   screenWidth <= 1024 ? 14 :
                   15
        } else {
            return screenWidth <= 320 ? 10 :
                   screenWidth <= 375 ? 11 :
                   screenWidth <= 393 ? 12 :
                   13
        }
    }
    
    private var rowPadding: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 16 :
                   screenWidth <= 834 ? 18 :
                   screenWidth <= 1024 ? 20 :
                   22
        } else {
            return screenWidth <= 320 ? 12 :
                   screenWidth <= 375 ? 14 :
                   screenWidth <= 393 ? 16 :
                   18
        }
    }
}

#Preview {
    let sampleSong = Song(
        title: "Don't Stop Believin'",
        artist: "Journey",
        bpm: 119,
        isFavorite: true
    )
    
    return SongRowView(
        song: sampleSong,
        onTap: { print("Tapped") },
        onEdit: { print("Edit") },
        onDelete: { print("Delete") },
        onToggleFavorite: { print("Toggle favorite") }
    )
    .padding()
}
