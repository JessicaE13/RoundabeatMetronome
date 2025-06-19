import SwiftUI

// MARK: - Setlists View
struct SetlistView: View {
    @StateObject private var setlistManager = SetlistManager()
    @ObservedObject var metronome: MetronomeEngine
    
    @State private var showingCreateSetlist = false
    @State private var showingCurrentSetlist = false
    
    // Get screen dimensions directly
    private var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    private var screenHeight: CGFloat {
        UIScreen.main.bounds.height
    }
    
    // Check if device is iPad
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if setlistManager.setlists.isEmpty {
                    emptyStateView
                } else {
                    setlistContent
                }
            }
            .navigationTitle("Setlists")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("New Setlist") {
                        showingCreateSetlist = true
                    }
                    .font(.system(size: toolbarFontSize, weight: .medium))
                }
            }
            .sheet(isPresented: $showingCreateSetlist) {
                CreateSetlistView(setlistManager: setlistManager)
            }
            .sheet(isPresented: $showingCurrentSetlist) {
                if let currentSetlist = setlistManager.currentSetlist {
                    CurrentSetlistView(
                        setlist: currentSetlist,
                        setlistManager: setlistManager,
                        metronome: metronome
                    )
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: emptyStateSpacing) {
            Spacer()
            
            Image(systemName: "music.note.list")
                .font(.system(size: emptyStateIconSize, weight: .light))
                .foregroundColor(.secondary.opacity(0.6))
            
            Text("No Setlists Yet")
                .font(.system(size: emptyStateTitleSize, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("Create your first setlist to organize songs\nwith their tempo and time signatures")
                .font(.system(size: emptyStateBodySize))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            Button("Create Your First Setlist") {
                showingCreateSetlist = true
            }
            .font(.system(size: emptyStateButtonSize, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.accentColor)
            )
            .padding(.top, 8)
            
            Spacer()
        }
        .padding(.horizontal, horizontalPadding)
    }
    
    // MARK: - Setlist Content
    private var setlistContent: some View {
        ScrollView {
            LazyVStack(spacing: setlistSpacing) {
                // Current Setlist Section
                if let currentSetlist = setlistManager.currentSetlist {
                    currentSetlistSection(currentSetlist)
                }
                
                // All Setlists Section
                VStack(alignment: .leading, spacing: sectionSpacing) {
                    HStack {
                        Text("All Setlists")
                            .font(.system(size: sectionHeaderSize, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(setlistManager.setlist.count) setlist\(setlistManager.setlist.count == 1 ? "" : "s")")
                            .font(.system(size: sectionSubtitleSize))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, horizontalPadding)
                    
                    ForEach(setlistManager.setlist) { setlist in
                        setlistRowView(setlist)
                    }
                }
                
                // Add extra padding at the bottom for navigation bar
                Spacer()
                    .frame(height: isIPad ? 100 : 80)
            }
            .padding(.top, contentTopPadding)
        }
    }
    
    // MARK: - Current Setlist Section
    private func currentSetlistSection(_ setlist: Setlist) -> some View {
        VStack(alignment: .leading, spacing: sectionSpacing) {
            HStack {
                Text("Now Playing")
                    .font(.system(size: sectionHeaderSize, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, horizontalPadding)
            
            Button(action: {
                showingCurrentSetlist = true
            }) {
                currentSetlistCard(setlist)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, horizontalPadding)
        }
        .padding(.bottom, sectionDividerSpacing)
    }
    
    private func currentSetlistCard(_ setlist: Setlist) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(setlist.name)
                        .font(.system(size: currentSetlistTitleSize, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text("\(setlist.songCount) songs • \(setlist.formattedDuration)")
                        .font(.system(size: currentSetlistSubtitleSize))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    if let currentSong = setlistManager.currentSong {
                        Text("Song \(setlistManager.currentSongIndex + 1)")
                            .font(.system(size: currentSongIndexSize))
                            .foregroundColor(.accentColor)
                            .fontWeight(.medium)
                        
                        Text("\(currentSong.bpm) BPM")
                            .font(.system(size: currentSongBPMSize))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if let currentSong = setlistManager.currentSong {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(currentSong.title.isEmpty ? "Untitled Song" : currentSong.title)
                            .font(.system(size: currentSongTitleSize, weight: .medium))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        if !currentSong.artist.isEmpty {
                            Text(currentSong.artist)
                                .font(.system(size: currentSongArtistSize))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Text(currentSong.timeSignatureDisplay)
                            .font(.system(size: currentSongDetailsSize, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text(currentSong.subdivisionSymbol)
                            .font(.system(size: currentSongDetailsSize, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(currentSetlistCardPadding)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.accentColor.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.accentColor.opacity(0.3), lineWidth: 1.5)
                )
        )
    }
    
    // MARK: - Setlist Row View
    private func setlistRowView(_ setlist: Setlist) -> some View {
        NavigationLink(destination: SetlistDetailView(setlist: setlist, setlistManager: setlistManager, metronome: metronome)) {
            HStack(spacing: 16) {
                // Setlist icon
                Image(systemName: setlist.id == setlistManager.currentSetlist?.id ? "music.note.list" : "music.note.list")
                    .font(.system(size: setlistIconSize, weight: .medium))
                    .foregroundColor(setlist.id == setlistManager.currentSetlist?.id ? .accentColor : .secondary)
                    .frame(width: setlistIconFrameSize, height: setlistIconFrameSize)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(setlist.id == setlistManager.currentSetlist?.id ? Color.accentColor.opacity(0.1) : Color.gray.opacity(0.1))
                    )
                
                // Setlist info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(setlist.name)
                            .font(.system(size: setlistTitleSize, weight: .medium))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        if setlist.id == setlistManager.currentSetlist?.id {
                            Text("CURRENT")
                                .font(.system(size: currentBadgeSize, weight: .bold))
                                .foregroundColor(.accentColor)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.accentColor.opacity(0.1))
                                )
                        }
                    }
                    
                    HStack {
                        Text("\(setlist.songCount) songs")
                            .font(.system(size: setlistSubtitleSize))
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .font(.system(size: setlistSubtitleSize))
                            .foregroundColor(.secondary)
                        
                        Text(setlist.formattedDuration)
                            .font(.system(size: setlistSubtitleSize))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: chevronSize, weight: .medium))
                    .foregroundColor(.secondary.opacity(0.6))
            }
            .padding(setlistRowPadding)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6).opacity(0.5))
            )
            .padding(.horizontal, horizontalPadding)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Responsive Properties
    
    private var toolbarFontSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 16 :
                   screenWidth <= 834 ? 17 :
                   screenWidth <= 1024 ? 18 :
                   19
        } else {
            return screenWidth <= 320 ? 14 :
                   screenWidth <= 375 ? 15 :
                   screenWidth <= 393 ? 16 :
                   17
        }
    }
    
    private var emptyStateIconSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 64 :
                   screenWidth <= 834 ? 72 :
                   screenWidth <= 1024 ? 80 :
                   88
        } else {
            return screenWidth <= 320 ? 48 :
                   screenWidth <= 375 ? 56 :
                   screenWidth <= 393 ? 64 :
                   72
        }
    }
    
    private var emptyStateTitleSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 24 :
                   screenWidth <= 834 ? 28 :
                   screenWidth <= 1024 ? 32 :
                   36
        } else {
            return screenWidth <= 320 ? 18 :
                   screenWidth <= 375 ? 20 :
                   screenWidth <= 393 ? 22 :
                   24
        }
    }
    
    private var emptyStateBodySize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 16 :
                   screenWidth <= 834 ? 17 :
                   screenWidth <= 1024 ? 18 :
                   19
        } else {
            return screenWidth <= 320 ? 14 :
                   screenWidth <= 375 ? 15 :
                   screenWidth <= 393 ? 16 :
                   17
        }
    }
    
    private var emptyStateButtonSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 16 :
                   screenWidth <= 834 ? 17 :
                   screenWidth <= 1024 ? 18 :
                   19
        } else {
            return screenWidth <= 320 ? 14 :
                   screenWidth <= 375 ? 15 :
                   screenWidth <= 393 ? 16 :
                   17
        }
    }
    
    private var sectionHeaderSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 20 :
                   screenWidth <= 834 ? 22 :
                   screenWidth <= 1024 ? 24 :
                   26
        } else {
            return screenWidth <= 320 ? 16 :
                   screenWidth <= 375 ? 18 :
                   screenWidth <= 393 ? 20 :
                   22
        }
    }
    
    private var sectionSubtitleSize: CGFloat {
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
    
    private var currentSetlistTitleSize: CGFloat {
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
    
    private var currentSetlistSubtitleSize: CGFloat {
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
    
    private var currentSongIndexSize: CGFloat {
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
    
    private var currentSongBPMSize: CGFloat {
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
    
    private var currentSongTitleSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 16 :
                   screenWidth <= 834 ? 17 :
                   screenWidth <= 1024 ? 18 :
                   19
        } else {
            return screenWidth <= 320 ? 13 :
                   screenWidth <= 375 ? 14 :
                   screenWidth <= 393 ? 15 :
                   16
        }
    }
    
    private var currentSongArtistSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 13 :
                   screenWidth <= 834 ? 14 :
                   screenWidth <= 1024 ? 15 :
                   16
        } else {
            return screenWidth <= 320 ? 11 :
                   screenWidth <= 375 ? 12 :
                   screenWidth <= 393 ? 13 :
                   14
        }
    }
    
    private var currentSongDetailsSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 13 :
                   screenWidth <= 834 ? 14 :
                   screenWidth <= 1024 ? 15 :
                   16
        } else {
            return screenWidth <= 320 ? 11 :
                   screenWidth <= 375 ? 12 :
                   screenWidth <= 393 ? 13 :
                   14
        }
    }
    
    private var setlistTitleSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 16 :
                   screenWidth <= 834 ? 17 :
                   screenWidth <= 1024 ? 18 :
                   19
        } else {
            return screenWidth <= 320 ? 13 :
                   screenWidth <= 375 ? 14 :
                   screenWidth <= 393 ? 15 :
                   16
        }
    }
    
    private var setlistSubtitleSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 13 :
                   screenWidth <= 834 ? 14 :
                   screenWidth <= 1024 ? 15 :
                   16
        } else {
            return screenWidth <= 320 ? 11 :
                   screenWidth <= 375 ? 12 :
                   screenWidth <= 393 ? 13 :
                   14
        }
    }
    
    private var setlistIconSize: CGFloat {
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
    
    private var setlistIconFrameSize: CGFloat {
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
    
    private var currentBadgeSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 10 :
                   screenWidth <= 834 ? 11 :
                   screenWidth <= 1024 ? 12 :
                   13
        } else {
            return screenWidth <= 320 ? 8 :
                   screenWidth <= 375 ? 9 :
                   screenWidth <= 393 ? 10 :
                   11
        }
    }
    
    private var chevronSize: CGFloat {
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
    
    // Spacing Properties
    private var emptyStateSpacing: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 24 :
                   screenWidth <= 834 ? 28 :
                   screenWidth <= 1024 ? 32 :
                   36
        } else {
            return screenWidth <= 320 ? 16 :
                   screenWidth <= 375 ? 20 :
                   screenWidth <= 393 ? 24 :
                   28
        }
    }
    
    private var setlistSpacing: CGFloat {
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
    
    private var sectionSpacing: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 12 :
                   screenWidth <= 834 ? 14 :
                   screenWidth <= 1024 ? 16 :
                   18
        } else {
            return screenWidth <= 320 ? 8 :
                   screenWidth <= 375 ? 10 :
                   screenWidth <= 393 ? 12 :
                   14
        }
    }
    
    private var sectionDividerSpacing: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 24 :
                   screenWidth <= 834 ? 28 :
                   screenWidth <= 1024 ? 32 :
                   36
        } else {
            return screenWidth <= 320 ? 16 :
                   screenWidth <= 375 ? 20 :
                   screenWidth <= 393 ? 24 :
                   28
        }
    }
    
    private var contentTopPadding: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 16 :
                   screenWidth <= 834 ? 20 :
                   screenWidth <= 1024 ? 24 :
                   28
        } else {
            return screenWidth <= 320 ? 8 :
                   screenWidth <= 375 ? 12 :
                   screenWidth <= 393 ? 16 :
                   20
        }
    }
    
    private var horizontalPadding: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 32 :
                   screenWidth <= 834 ? 40 :
                   screenWidth <= 1024 ? 48 :
                   56
        } else {
            return screenWidth <= 320 ? 12 :
                   screenWidth <= 375 ? 16 :
                   screenWidth <= 393 ? 20 :
                   24
        }
    }
    
    private var currentSetlistCardPadding: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 20 :
                   screenWidth <= 834 ? 24 :
                   screenWidth <= 1024 ? 28 :
                   32
        } else {
            return screenWidth <= 320 ? 12 :
                   screenWidth <= 375 ? 16 :
                   screenWidth <= 393 ? 18 :
                   20
        }
    }
    
    private var setlistRowPadding: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 16 :
                   screenWidth <= 834 ? 18 :
                   screenWidth <= 1024 ? 20 :
                   22
        } else {
            return screenWidth <= 320 ? 10 :
                   screenWidth <= 375 ? 12 :
                   screenWidth <= 393 ? 14 :
                   16
        }
    }
}

#Preview {
    SetlistView(metronome: MetronomeEngine())
}
