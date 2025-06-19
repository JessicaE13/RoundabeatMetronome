import SwiftUI

// MARK: - Edit Song View
struct EditSongView: View {
    let song: Song
    let setlist: Setlist
    @ObservedObject var setlistManager: SetlistManager
    @ObservedObject var metronome: MetronomeEngine
    @Environment(\.presentationMode) var presentationMode
    
    @State private var editedSong: Song
    @State private var showingDeleteAlert = false
    @State private var showingDiscardAlert = false
    @State private var showingTimeSignaturePicker = false
    @State private var showingSubdivisionPicker = false
    @State private var showingNumberPad = false
    @State private var hasUnsavedChanges = false
    
    // Get screen dimensions directly
    private var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    // Check if device is iPad
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    init(song: Song, setlist: Setlist, setlistManager: SetlistManager, metronome: MetronomeEngine) {
        self.song = song
        self.setlist = setlist
        self.setlistManager = setlistManager
        self.metronome = metronome
        self._editedSong = State(initialValue: song)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Main content
            ScrollView {
                VStack(alignment: .leading, spacing: sectionSpacing) {
                    // Basic Info Section
                    VStack(alignment: .leading, spacing: settingsSectionSpacing) {
                        sectionHeader(title: "Song Details")
                        
                        VStack(spacing: formFieldSpacing) {
                            // Title field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Title")
                                    .font(.system(size: labelSize, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                TextField("Enter song title", text: $editedSong.title)
                                    .font(.system(size: textFieldSize))
                                    .padding(textFieldPadding)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemGray6))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(editedSong.title.isEmpty ? Color.red.opacity(0.3) : Color.accentColor.opacity(0.3), lineWidth: 1)
                                    )
                                    .onChange(of: editedSong.title) { _, _ in
                                        checkForChanges()
                                    }
                                
                                if editedSong.title.isEmpty {
                                    Text("Title is required")
                                        .font(.system(size: errorTextSize))
                                        .foregroundColor(.red)
                                }
                            }
                            
                            // Artist field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Artist")
                                    .font(.system(size: labelSize, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                TextField("Enter artist name", text: $editedSong.artist)
                                    .font(.system(size: textFieldSize))
                                    .padding(textFieldPadding)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemGray6))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
                                    )
                                    .onChange(of: editedSong.artist) { _, _ in
                                        checkForChanges()
                                    }
                            }
                            
                            // Notes field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Notes")
                                    .font(.system(size: labelSize, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                TextField("Optional notes about this song", text: $editedSong.notes, axis: .vertical)
                                    .font(.system(size: textFieldSize))
                                    .padding(textFieldPadding)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemGray6))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
                                    )
                                    .lineLimit(3...6)
                                    .onChange(of: editedSong.notes) { _, _ in
                                        checkForChanges()
                                    }
                            }
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, dividerSpacing)
                    
                    // Musical Settings Section
                    VStack(alignment: .leading, spacing: settingsSectionSpacing) {
                        sectionHeader(title: "Musical Settings")
                        
                        VStack(spacing: musicalSettingsSpacing) {
                            // BPM Setting
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Tempo (BPM)")
                                    .font(.system(size: labelSize, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                Button(action: {
                                    showingNumberPad = true
                                }) {
                                    HStack {
                                        Text("\(editedSong.bpm)")
                                            .font(.custom("Kanit-SemiBold", size: bpmDisplaySize))
                                            .foregroundColor(.primary)
                                            .kerning(1.0)
                                        
                                        Spacer()
                                        
                                        Text("BPM")
                                            .font(.system(size: bpmLabelSize, weight: .medium))
                                            .foregroundColor(.secondary)
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: chevronSize, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(settingRowPadding)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemGray6))
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                            
                            // Time Signature Setting
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Time Signature")
                                    .font(.system(size: labelSize, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                Button(action: {
                                    showingTimeSignaturePicker = true
                                }) {
                                    HStack {
                                        Text("\(editedSong.timeSignatureNumerator)/\(editedSong.timeSignatureDenominator)")
                                            .font(.custom("Kanit-Medium", size: timeSignatureDisplaySize))
                                            .foregroundColor(.primary)
                                            .kerning(1.0)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: chevronSize, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(settingRowPadding)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemGray6))
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                            
                            // Subdivision Setting
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Subdivision")
                                    .font(.system(size: labelSize, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                Button(action: {
                                    showingSubdivisionPicker = true
                                }) {
                                    HStack {
                                        Text(getCurrentSubdivisionSymbol())
                                            .font(.system(size: subdivisionDisplaySize))
                                            .foregroundColor(.primary)
                                        
                                        Text(getCurrentSubdivisionName())
                                            .font(.system(size: subdivisionNameSize, weight: .medium))
                                            .foregroundColor(.secondary)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: chevronSize, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(settingRowPadding)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemGray6))
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, dividerSpacing)
                    
                    // Quick Actions Section
                    VStack(alignment: .leading, spacing: settingsSectionSpacing) {
                        sectionHeader(title: "Quick Actions")
                        
                        VStack(spacing: quickActionSpacing) {
                            // Load to Metronome Button
                            Button(action: {
                                setlistManager.applySongToMetronome(editedSong, metronome: metronome)
                                if #available(iOS 10.0, *) {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "arrow.down.circle.fill")
                                        .font(.system(size: actionIconSize, weight: .medium))
                                        .foregroundColor(.accentColor)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Load to Metronome")
                                            .font(.system(size: actionTitleSize, weight: .medium))
                                            .foregroundColor(.primary)
                                        
                                        Text("Apply these settings to the metronome")
                                            .font(.system(size: actionDescSize))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(actionRowPadding)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.accentColor.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                            
                            // Copy from Metronome Button
                            Button(action: {
                                copyFromMetronome()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.up.circle")
                                        .font(.system(size: actionIconSize, weight: .medium))
                                        .foregroundColor(.secondary)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Copy from Metronome")
                                            .font(.system(size: actionTitleSize, weight: .medium))
                                            .foregroundColor(.primary)
                                        
                                        Text("Use current metronome settings")
                                            .font(.system(size: actionDescSize))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(actionRowPadding)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemGray6))
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    // Delete Button Section
                    VStack(alignment: .leading, spacing: settingsSectionSpacing) {
                        Button(action: {
                            showingDeleteAlert = true
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                    .font(.system(size: actionIconSize, weight: .medium))
                                    .foregroundColor(.red)
                                
                                Text("Delete Song")
                                    .font(.system(size: actionTitleSize, weight: .medium))
                                    .foregroundColor(.red)
                                
                                Spacer()
                            }
                            .padding(actionRowPadding)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.red.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, sectionSpacing)
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.top, topPadding)
                .padding(.bottom, bottomPadding)
            }
        }
        .navigationTitle("Edit Song")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(hasUnsavedChanges)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if hasUnsavedChanges {
                    Button("Cancel") {
                        showingDiscardAlert = true
                    }
                    .font(.system(size: toolbarButtonSize))
                    .foregroundColor(.secondary)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveSong()
                }
                .font(.system(size: toolbarButtonSize, weight: .medium))
                .foregroundColor(canSave ? .accentColor : .secondary)
                .disabled(!canSave)
            }
        }
        .overlay(
            // Modal Overlays
            Group {
                // Time Signature Picker Modal
                if showingTimeSignaturePicker {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showingTimeSignaturePicker = false
                        }
                    
                    TimeSignaturePickerView(
                        metronome: createTempMetronome(),
                        isShowingPicker: $showingTimeSignaturePicker
                    )
                    .onDisappear {
                        updateTimeSignatureFromTempMetronome()
                    }
                }
                
                // Subdivision Picker Modal
                if showingSubdivisionPicker {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showingSubdivisionPicker = false
                        }
                    
                    SubdivisionPickerView(
                        metronome: createTempMetronome(),
                        isShowingPicker: $showingSubdivisionPicker
                    )
                    .onDisappear {
                        updateSubdivisionFromTempMetronome()
                    }
                }
                
                // Number Pad Modal
                if showingNumberPad {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showingNumberPad = false
                        }
                    
                    NumberPadView(
                        isShowingKeypad: $showingNumberPad,
                        currentTempo: Double(editedSong.bpm),
                        onSubmit: { newBPM in
                            editedSong.bpm = Int(newBPM)
                            checkForChanges()
                        }
                    )
                }
            }
        )
        .alert("Delete Song", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                setlistManager.deleteSong(from: setlist, song: song)
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Are you sure you want to delete \"\(song.title)\"? This action cannot be undone.")
        }
        .alert("Discard Changes", isPresented: $showingDiscardAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Discard", role: .destructive) {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("You have unsaved changes. Are you sure you want to discard them?")
        }
        .onAppear {
            checkForChanges()
        }
    }
    
    // MARK: - Helper Views
    
    private func sectionHeader(title: String) -> some View {
        Text(title)
            .font(.system(size: sectionHeaderSize, weight: .bold))
            .foregroundColor(.primary)
    }
    
    // MARK: - Helper Methods
    
    private var canSave: Bool {
        !editedSong.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        editedSong.bpm >= 40 && editedSong.bpm <= 400 &&
        hasUnsavedChanges
    }
    
    private func checkForChanges() {
        hasUnsavedChanges = editedSong != song
    }
    
    private func saveSong() {
        guard canSave else { return }
        
        var songToSave = editedSong
        songToSave.updateLastModified()
        
        setlistManager.updateSong(in: setlist, song: songToSave)
        
        if #available(iOS 10.0, *) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
        
        presentationMode.wrappedValue.dismiss()
    }
    
    private func copyFromMetronome() {
        editedSong.bpm = metronome.bpm
        editedSong.timeSignatureNumerator = metronome.beatsPerMeasure
        editedSong.timeSignatureDenominator = metronome.beatUnit
        editedSong.subdivisionMultiplier = metronome.subdivisionMultiplier
        checkForChanges()
        
        if #available(iOS 10.0, *) {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
    
    private func getCurrentSubdivisionSymbol() -> String {
        switch editedSong.subdivisionMultiplier {
        case 1.0: return "♩"
        case 2.0: return "♫"
        case 3.0: return "3♫"
        case 4.0: return "♬"
        default: return "♩"
        }
    }
    
    private func getCurrentSubdivisionName() -> String {
        switch editedSong.subdivisionMultiplier {
        case 1.0: return "Quarter Note"
        case 2.0: return "Eighth Note"
        case 3.0: return "Eighth Note Triplet"
        case 4.0: return "Sixteenth Note"
        default: return "Quarter Note"
        }
    }
    
    private func createTempMetronome() -> MetronomeEngine {
        let tempMetronome = MetronomeEngine()
        tempMetronome.bpm = editedSong.bpm
        tempMetronome.updateTimeSignature(numerator: editedSong.timeSignatureNumerator, denominator: editedSong.timeSignatureDenominator)
        tempMetronome.updateSubdivision(to: editedSong.subdivisionMultiplier)
        return tempMetronome
    }
    
    private func updateTimeSignatureFromTempMetronome() {
        // This would need to be updated with proper state management
        // For now, we'll handle this through the picker's onSubmit
    }
    
    private func updateSubdivisionFromTempMetronome() {
        // This would need to be updated with proper state management
        // For now, we'll handle this through the picker's onSubmit
    }
    
    // MARK: - Responsive Properties
    
    private var toolbarButtonSize: CGFloat {
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
    
    private var labelSize: CGFloat {
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
    
    private var textFieldSize: CGFloat {
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
    
    private var errorTextSize: CGFloat {
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
    
    private var bpmDisplaySize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 24 :
                   screenWidth <= 834 ? 26 :
                   screenWidth <= 1024 ? 28 :
                   30
        } else {
            return screenWidth <= 320 ? 18 :
                   screenWidth <= 375 ? 20 :
                   screenWidth <= 393 ? 22 :
                   24
        }
    }
    
    private var bpmLabelSize: CGFloat {
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
    
    private var timeSignatureDisplaySize: CGFloat {
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
    
    private var subdivisionDisplaySize: CGFloat {
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
    
    private var subdivisionNameSize: CGFloat {
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
    
    private var chevronSize: CGFloat {
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
    
    private var actionIconSize: CGFloat {
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
    
    private var actionTitleSize: CGFloat {
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
    
    private var actionDescSize: CGFloat {
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
    
    // Spacing and Padding Properties
    private var sectionSpacing: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 32 :
                   screenWidth <= 834 ? 36 :
                   screenWidth <= 1024 ? 40 :
                   44
        } else {
            return screenWidth <= 320 ? 20 :
                   screenWidth <= 375 ? 24 :
                   screenWidth <= 393 ? 28 :
                   32
        }
    }
    
    private var settingsSectionSpacing: CGFloat {
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
    
    private var formFieldSpacing: CGFloat {
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
    
    private var musicalSettingsSpacing: CGFloat {
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
    
    private var quickActionSpacing: CGFloat {
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
    
    private var dividerSpacing: CGFloat {
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
    
    private var topPadding: CGFloat {
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
    
    private var bottomPadding: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 32 :
                   screenWidth <= 834 ? 40 :
                   screenWidth <= 1024 ? 48 :
                   56
        } else {
            return screenWidth <= 320 ? 20 :
                   screenWidth <= 375 ? 24 :
                   screenWidth <= 393 ? 28 :
                   32
        }
    }
    
    private var textFieldPadding: CGFloat {
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
    
    private var settingRowPadding: CGFloat {
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
    
    private var actionRowPadding: CGFloat {
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
    NavigationView {
        EditSongView(
            song: Song(title: "Sample Song", artist: "Sample Artist", bpm: 120),
            setlist: Setlist(name: "Sample Setlist"),
            setlistManager: SetlistManager(),
            metronome: MetronomeEngine()
        )
    }
}
