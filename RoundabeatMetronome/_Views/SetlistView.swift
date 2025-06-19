import SwiftUI

// MARK: - Setlists List View (Main Setlists Tab)
struct SetlistsListView: View {
    @ObservedObject var metronome: MetronomeEngine
    @StateObject private var setlistManager = SetlistManager()
    
    @State private var showingCreateSetlist = false
    @State private var searchText = ""
    
    // Get screen dimensions directly
    private var screenWidth: CGFloat {
        UIScreen.main.bounds.width
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
                    setlistsListView
                }
            }
            .navigationTitle("Setlists")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingCreateSetlist = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: toolbarIconSize, weight: .medium))
                    }
                }
            }
            .sheet(isPresented: $showingCreateSetlist) {
                CreateSetlistView(setlistManager: setlistManager)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: emptyStateSpacing) {
            Spacer()
            
            Image(systemName: "music.note.list")
                .font(.system(size: emptyIconSize, weight: .light))
                .foregroundColor(.secondary.opacity(0.6))
            
            Text("No Setlists Yet")
                .font(.system(size: emptyTitleSize, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("Create your first setlist to organize your songs")
                .font(.system(size: emptyBodySize))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button("Create First Setlist") {
                showingCreateSetlist = true
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
    
    // MARK: - Setlists List View
    private var setlistsListView: some View {
        List {
            // Current setlist section (if any)
            if let currentSetlist = setlistManager.currentSetlist {
                Section("Now Playing") {
                    currentSetlistCard(currentSetlist)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }
            
            // All setlists section
            Section("All Setlists") {
                ForEach(filteredSetlists) { setlist in
                    NavigationLink(destination: SetlistDetailView(
                        setlist: setlist,
                        setlistManager: setlistManager,
                        metronome: metronome
                    )) {
                        setlistRowView(setlist: setlist)
                    }
                }
                .onDelete(perform: deleteSetlists)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .searchable(text: $searchText, prompt: "Search setlists...")
    }
    
    // MARK: - Current Setlist Card
    private func currentSetlistCard(_ setlist: Setlist) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(setlist.name)
                        .font(.system(size: currentSetlistTitleSize, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Currently Active")
                        .font(.system(size: currentSetlistSubtitleSize))
                        .foregroundColor(.accentColor)
                }
                
                Spacer()
                
                Text("ACTIVE")
                    .font(.system(size: activeBadgeSize, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.accentColor)
                    )
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
                    if let currentSong = setlistManager.currentSong {
                        Text(currentSong.title)
                            .font(.system(size: statNumberSize, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Text("Current Song")
                            .font(.system(size: statLabelSize))
                            .foregroundColor(.secondary)
                    } else {
                        Text("No song selected")
                            .font(.system(size: statNumberSize, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        Text("Current Song")
                            .font(.system(size: statLabelSize))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
        }
        .padding(cardPadding)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.accentColor.opacity(0.3), lineWidth: 1.5)
                )
        )
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, 8)
    }
    
    // MARK: - Setlist Row View
    private func setlistRowView(setlist: Setlist) -> some View {
        HStack(spacing: 16) {
            // Setlist icon with color
            Image(systemName: "music.note.list")
                .font(.system(size: setlistIconSize, weight: .medium))
                .foregroundColor(.white)
                .frame(width: setlistIconFrameSize, height: setlistIconFrameSize)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.accentColor) // You could use setlist.color here if you want
                )
            
            // Setlist info
            VStack(alignment: .leading, spacing: 4) {
                Text(setlist.name)
                    .font(.system(size: setlistTitleSize, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack {
                    Text("\(setlist.songCount) songs")
                        .font(.system(size: setlistDetailsSize))
                        .foregroundColor(.secondary)
                    
                    if !setlist.description.isEmpty {
                        Text("•")
                            .font(.system(size: setlistDetailsSize))
                            .foregroundColor(.secondary)
                        
                        Text(setlist.description)
                            .font(.system(size: setlistDetailsSize))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
            
            // Current indicator and stats
            VStack(alignment: .trailing, spacing: 2) {
                if setlistManager.currentSetlist?.id == setlist.id {
                    Text("CURRENT")
                        .font(.system(size: currentIndicatorSize, weight: .bold))
                        .foregroundColor(.accentColor)
                } else {
                    Text(setlist.formattedDuration)
                        .font(.system(size: durationSize, weight: .medium))
                        .foregroundColor(.primary)
                }
                
                Text("Updated \(setlist.lastModified, formatter: relativeDateFormatter)")
                    .font(.system(size: lastModifiedSize))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Computed Properties
    
    private var filteredSetlists: [Setlist] {
        if searchText.isEmpty {
            return setlistManager.setlists
        } else {
            return setlistManager.filterSetlists(query: searchText)
        }
    }
    
    // MARK: - Actions
    
    private func deleteSetlists(offsets: IndexSet) {
        for index in offsets {
            let setlist = filteredSetlists[index]
            setlistManager.deleteSetlist(setlist)
        }
    }
    
    // MARK: - Date Formatters
    
    private var relativeDateFormatter: RelativeDateTimeFormatter {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
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
    
    private var currentSetlistTitleSize: CGFloat {
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
    
    private var activeBadgeSize: CGFloat {
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
    
    private var setlistTitleSize: CGFloat {
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
    
    private var setlistDetailsSize: CGFloat {
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
    
    private var currentIndicatorSize: CGFloat {
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
    
    private var durationSize: CGFloat {
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
    
    private var lastModifiedSize: CGFloat {
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

// MARK: - Create Setlist View (Modal)
struct CreateSetlistView: View {
    @ObservedObject var setlistManager: SetlistManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var setlistName: String = ""
    @State private var setlistDescription: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // Get screen dimensions directly
    private var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    // Check if device is iPad
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "music.note.list")
                        .font(.system(size: iconSize, weight: .light))
                        .foregroundColor(.accentColor)
                    
                    Text("Create New Setlist")
                        .font(.system(size: titleSize, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Give your setlist a name and optional description")
                        .font(.system(size: subtitleSize))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 32)
                
                // Form
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Setlist Name")
                            .font(.system(size: labelSize, weight: .medium))
                            .foregroundColor(.primary)
                        
                        TextField("Enter setlist name", text: $setlistName)
                            .font(.system(size: textFieldSize))
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(setlistName.isEmpty ? Color.clear : Color.accentColor.opacity(0.3), lineWidth: 1)
                            )
                        
                        HStack {
                            Spacer()
                            Text("\(setlistName.count)/50")
                                .font(.system(size: characterCountSize))
                                .foregroundColor(setlistName.count > 50 ? .red : .secondary)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description (Optional)")
                            .font(.system(size: labelSize, weight: .medium))
                            .foregroundColor(.primary)
                        
                        TextField("Optional description", text: $setlistDescription, axis: .vertical)
                            .font(.system(size: textFieldSize))
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
                            )
                            .lineLimit(3...6)
                        
                        HStack {
                            Spacer()
                            Text("\(setlistDescription.count)/200")
                                .font(.system(size: characterCountSize))
                                .foregroundColor(setlistDescription.count > 200 ? .red : .secondary)
                        }
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 16) {
                    Button(action: createSetlist) {
                        HStack {
                            Image(systemName: "plus")
                                .font(.system(size: buttonIconSize, weight: .medium))
                            
                            Text("Create Setlist")
                                .font(.system(size: buttonTextSize, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(canCreateSetlist ? Color.accentColor : Color.gray)
                        )
                    }
                    .disabled(!canCreateSetlist)
                    
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.system(size: cancelButtonSize, weight: .medium))
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
            .navigationBarHidden(true)
            .alert("Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var canCreateSetlist: Bool {
        !setlistName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        setlistName.count <= 50 &&
        setlistDescription.count <= 200
    }
    
    // MARK: - Actions
    
    private func createSetlist() {
        let trimmedName = setlistName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = setlistDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else {
            alertMessage = "Please enter a setlist name."
            showingAlert = true
            return
        }
        
        guard trimmedName.count <= 50 else {
            alertMessage = "Setlist name must be 50 characters or less."
            showingAlert = true
            return
        }
        
        guard trimmedDescription.count <= 200 else {
            alertMessage = "Description must be 200 characters or less."
            showingAlert = true
            return
        }
        
        if let _ = setlistManager.createSetlist(name: trimmedName, description: trimmedDescription) {
            presentationMode.wrappedValue.dismiss()
            
            if #available(iOS 10.0, *) {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        } else {
            alertMessage = setlistManager.errorMessage ?? "Failed to create setlist."
            showingAlert = true
        }
    }
    
    // MARK: - Responsive Properties (Same as previous implementation)
    
    private var iconSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 48 : 64
        } else {
            return screenWidth <= 320 ? 32 : 48
        }
    }
    
    private var titleSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 28 : 36
        } else {
            return screenWidth <= 320 ? 20 : 28
        }
    }
    
    private var subtitleSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 16 : 18
        } else {
            return screenWidth <= 320 ? 14 : 16
        }
    }
    
    private var labelSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 16 : 18
        } else {
            return screenWidth <= 320 ? 14 : 16
        }
    }
    
    private var textFieldSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 16 : 18
        } else {
            return screenWidth <= 320 ? 14 : 16
        }
    }
    
    private var characterCountSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 12 : 14
        } else {
            return screenWidth <= 320 ? 10 : 12
        }
    }
    
    private var buttonIconSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 16 : 18
        } else {
            return screenWidth <= 320 ? 14 : 16
        }
    }
    
    private var buttonTextSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 16 : 18
        } else {
            return screenWidth <= 320 ? 14 : 16
        }
    }
    
    private var cancelButtonSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 16 : 18
        } else {
            return screenWidth <= 320 ? 14 : 16
        }
    }
}

#Preview {
    SetlistsListView(metronome: MetronomeEngine())
}
