import SwiftUI

// MARK: - Setlist Detail View
struct SetlistDetailView: View {
    let setlist: Setlist
    @ObservedObject var setlistManager: SetlistManager
    @ObservedObject var metronome: MetronomeEngine
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showingAddSong = false
    @State private var showingEditSetlist = false
    @State private var showingDeleteAlert = false
    @State private var editMode: EditMode = .inactive
    
    // Get screen dimensions directly
    private var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    // Check if device is iPad
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if setlist.songs.isEmpty {
                emptyStateView
            } else {
                songListView
            }
        }
        .navigationTitle(setlist.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingAddSong = true }) {
                        Label("Add Song", systemImage: "plus")
                    }
                    
                    Button(action: { editMode = editMode == .active ? .inactive : .active }) {
                        Label(editMode == .active ? "Done" : "Edit Songs", systemImage: "pencil")
                    }
                    
                    Divider()
                    
                    Button(action: { setlistManager.setCurrentSetlist(setlist) }) {
                        Label("Set as Current", systemImage: "music.note.list")
                    }
                    .disabled(setlistManager.currentSetlist?.id == setlist.id)
                    
                    Button(action: { setlistManager.duplicateSetlist(setlist) }) {
                        Label("Duplicate", systemImage: "doc.on.doc")
                    }
                    
                    Divider()
                    
                    Button(action: { showingDeleteAlert = true }, role: .destructive) {
                        Label("Delete Setlist", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: toolbarIconSize, weight: .medium))
                }
            }
        }
        .environment(\.editMode, $editMode)
        .sheet(isPresented: $showingAddSong) {
            AddSongView(setlist: setlist, setlistManager: setlistManager, metronome: metronome)
        }
        .sheet(isPresented: $showingEditSetlist) {
            EditSetlistView(setlist: setlist, setlistManager: setlistManager)
        }
        .alert("Delete Setlist", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                setlistManager.deleteSetlist(setlist)
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Are you sure you want to delete \"\(setlist.name)\"? This action cannot be undone.")
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: emptyStateSpacing) {
            Spacer()
            
            Image(systemName: "music.note")
                .font(.system(size: emptyIconSize, weight: .light))
                .foregroundColor(.secondary.opacity(0.6))
            
            Text("No Songs Yet")
                .font(.system(size: emptyTitleSize, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("Add your first song to get started")
                .font(.system(size: emptyBodySize))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Add First Song") {
                showingAddSong = true
            }
            .font(.system(size: emptyButtonSize, weight: .medium))
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
    
    // MARK: - Song List View
    private var songListView: some View {
        List {
            // Setlist Info Section
            Section {
                setlistInfoCard
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
            
            // Songs Section
            Section("Songs") {
                ForEach(Array(setlist.songs.enumerated()), id: \.element.id) { index, song in
                    songRowView(song: song, index: index)
                }
                .onDelete(perform: deleteSongs)
                .onMove(perform: moveSongs)
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    // MARK: - Setlist Info Card
    private var setlistInfoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(setlist.name)
                        .font(.system(size: cardTitleSize, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Created \(setlist.createdDate, formatter: dateFormatter)")
                        .font(.system(size: cardSubtitleSize))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if setlistManager.currentSetlist?.id == setlist.id {
                    Text("CURRENT")
                        .font(.system(size: currentBadgeSize, weight: .bold))
                        .foregroundColor(.accentColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.accentColor.opacity(0.1))
                        )
                }
            }
            
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(setlist.songCount)")
                        .font(.system(size: statNumberSize, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("Songs")
                        .font(.system(size: statLabelSize))
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(setlist.formattedDuration)
                        .font(.system(size: statNumberSize, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("Est. Duration")
                        .font(.system(size: statLabelSize))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if !setlist.songs.isEmpty {
                    Button(action: { setlistManager.setCurrentSetlist(setlist) }) {
                        HStack(spacing: 6) {
                            Image(systemName: setlistManager.currentSetlist?.id == setlist.id ? "checkmark" : "play.fill")
                                .font(.system(size: actionButtonIconSize, weight: .medium))
                            
                            Text(setlistManager.currentSetlist?.id == setlist.id ? "Active" : "Use")
                                .font(.system(size: actionButtonTextSize, weight: .medium))
                        }
                        .foregroundColor(setlistManager.currentSetlist?.id == setlist.id ? .green : .accentColor)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill((setlistManager.currentSetlist?.id == setlist.id ? Color.green : Color.accentColor).opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke((setlistManager.currentSetlist?.id == setlist.id ? Color.green : Color.accentColor).opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .disabled(setlistManager.currentSetlist?.id == setlist.id)
                }
            }
        }
        .padding(cardPadding)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, 8)
    }
    
    // MARK: - Song Row View
    private func songRowView(song: Song, index: Int) -> some View {
        NavigationLink(destination: EditSongView(song: song, setlist: setlist, setlistManager: setlistManager, metronome: metronome)) {
            HStack(spacing: 16) {
                // Song number
                Text("\(index + 1)")
                    .font(.system(size: songNumberSize, weight: .bold))
                    .foregroundColor(.accentColor)
                    .frame(width: songNumberWidth, alignment: .center)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.accentColor.opacity(0.1))
                    )
                
                // Song info
                VStack(alignment: .leading, spacing: 4) {
                    Text(song.title.isEmpty ? "Untitled Song" : song.title)
                        .font(.system(size: songTitleSize, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    HStack {
                        if !song.artist.isEmpty {
                            Text(song.artist)
                                .font(.system(size: songArtistSize))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        
                        if !song.artist.isEmpty && !song.notes.isEmpty {
                            Text("•")
                                .font(.system(size: songArtistSize))
                                .foregroundColor(.secondary)
                        }
                        
                        if !song.notes.isEmpty {
                            Text(song.notes)
                                .font(.system(size: songArtistSize))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
                
                Spacer()
                
                // Song details
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(song.bpm) BPM")
                        .font(.system(size: songBPMSize, weight: .medium))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 8) {
                        Text(song.timeSignatureDisplay)
                            .font(.system(size: songDetailsSize))
                            .foregroundColor(.secondary)
                        
                        Text(song.subdivisionSymbol)
                            .font(.system(size: songDetailsSize))
                            .foregroundColor(.secondary)
                    }
                }
                
                // Load button
                Button(action: {
                    setlistManager.applySongToMetronome(song, metronome: metronome)
                    if #available(iOS 10.0, *) {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }) {
                    Image(systemName: "arrow.down.circle")
                        .font(.system(size: loadButtonSize, weight: .medium))
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Actions
    
    private func deleteSongs(offsets: IndexSet) {
        for index in offsets {
            let song = setlist.songs[index]
            setlistManager.deleteSong(from: setlist, song: song)
        }
    }
    
    private func moveSongs(from source: IndexSet, to destination: Int) {
        setlistManager.moveSongs(in: setlist, from: source, to: destination)
    }
    
    // MARK: - Date Formatter
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    // MARK: - Responsive Properties
    
    private var toolbarIconSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 18 :
                   screenWidth <= 834 ? 20 :
                   screenWidth <= 1024 ? 22 :
                   24
        } else {
            return screenWidth <= 320 ? 16 :
                   screenWidth <= 375 ? 17 :
                   screenWidth <= 393 ? 18 :
                   19
        }
    }
    
    private var emptyIconSize: CGFloat {
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
    
    private var emptyTitleSize: CGFloat {
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
    
    private var emptyBodySize: CGFloat {
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
    
    private var emptyButtonSize: CGFloat {
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
    
    private var cardTitleSize: CGFloat {
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
    
    private var cardSubtitleSize: CGFloat {
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
    
    private var currentBadgeSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 11 :
                   screenWidth <= 834 ? 12 :
                   screenWidth <= 1024 ? 13 :
                   14
        } else {
            return screenWidth <= 320 ? 9 :
                   screenWidth <= 375 ? 10 :
                   screenWidth <= 393 ? 11 :
                   12
        }
    }
    
    private var statNumberSize: CGFloat {
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
    
    private var statLabelSize: CGFloat {
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
    
    private var actionButtonIconSize: CGFloat {
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
    
    private var actionButtonTextSize: CGFloat {
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
    
    private var songNumberSize: CGFloat {
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
    
    private var songNumberWidth: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 32 :
                   screenWidth <= 834 ? 36 :
                   screenWidth <= 1024 ? 40 :
                   44
        } else {
            return screenWidth <= 320 ? 24 :
                   screenWidth <= 375 ? 28 :
                   screenWidth <= 393 ? 32 :
                   36
        }
    }
    
    private var songTitleSize: CGFloat {
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
    
    private var songArtistSize: CGFloat {
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
    
    private var songBPMSize: CGFloat {
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
    
    private var songDetailsSize: CGFloat {
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
    
    private var loadButtonSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 18 :
                   screenWidth <= 834 ? 20 :
                   screenWidth <= 1024 ? 22 :
                   24
        } else {
            return screenWidth <= 320 ? 16 :
                   screenWidth <= 375 ? 17 :
                   screenWidth <= 393 ? 18 :
                   19
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
    
    private var horizontalPadding: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 32 :
                   screenWidth <= 834 ? 40 :
                   screenWidth <= 1024 ? 48 :
                   56
        } else {
            return screenWidth <= 320 ? 16 :
                   screenWidth <= 375 ? 20 :
                   screenWidth <= 393 ? 24 :
                   28
        }
    }
    
    private var cardPadding: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 20 :
                   screenWidth <= 834 ? 24 :
                   screenWidth <= 1024 ? 28 :
                   32
        } else {
            return screenWidth <= 320 ? 16 :
                   screenWidth <= 375 ? 18 :
                   screenWidth <= 393 ? 20 :
                   22
        }
    }
}

#Preview {
    NavigationView {
        SetlistDetailView(
            setlist: Setlist(name: "Sample Setlist", songs: [
                Song(title: "Sample Song", artist: "Sample Artist", bpm: 120)
            ]),
            setlistManager: SetlistManager(),
            metronome: MetronomeEngine()
        )
    }
}
