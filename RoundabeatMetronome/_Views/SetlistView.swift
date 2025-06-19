import SwiftUI

// MARK: - Create Setlist View
struct SetlistView: View {
    @ObservedObject var setlistManager: SetlistManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var setlistName: String = ""
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
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "music.note.list")
                        .font(.system(size: iconSize, weight: .light))
                        .foregroundColor(.accentColor)
                    
                    Text("Create New Setlist")
                        .font(.system(size: titleSize, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Give your setlist a name to get started")
                        .font(.system(size: subtitleSize))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, headerTopPadding)
                .padding(.bottom, headerBottomPadding)
                
                // Form
                VStack(spacing: formSpacing) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Setlist Name")
                            .font(.system(size: labelSize, weight: .medium))
                            .foregroundColor(.primary)
                        
                        TextField("Enter setlist name", text: $setlistName)
                            .font(.system(size: textFieldSize))
                            .padding(textFieldPadding)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(setlistName.isEmpty ? Color.clear : Color.accentColor.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    // Character count
                    HStack {
                        Spacer()
                        Text("\(setlistName.count)/50")
                            .font(.system(size: characterCountSize))
                            .foregroundColor(setlistName.count > 50 ? .red : .secondary)
                    }
                }
                .padding(.horizontal, formPadding)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: buttonSpacing) {
                    Button(action: createSetlist) {
                        HStack {
                            Image(systemName: "plus")
                                .font(.system(size: buttonIconSize, weight: .medium))
                            
                            Text("Create Setlist")
                                .font(.system(size: buttonTextSize, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, buttonVerticalPadding)
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
                .padding(.horizontal, buttonPadding)
                .padding(.bottom, buttonBottomPadding)
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
        setlistName.count <= 50
    }
    
    // MARK: - Actions
    
    private func createSetlist() {
        let trimmedName = setlistName.trimmingCharacters(in: .whitespacesAndNewlines)
        
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
        
        // Check for duplicate names
        if setlistManager.setlists.contains(where: { $0.name.lowercased() == trimmedName.lowercased() }) {
            alertMessage = "A setlist with this name already exists."
            showingAlert = true
            return
        }
        
        let newSetlist = setlistManager.createSetlist(name: trimmedName)
        presentationMode.wrappedValue.dismiss()
        
        // Provide haptic feedback
        if #available(iOS 10.0, *) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
    
    // MARK: - Responsive Properties
    
    private var iconSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 48 :
                   screenWidth <= 834 ? 56 :
                   screenWidth <= 1024 ? 64 :
                   72
        } else {
            return screenWidth <= 320 ? 32 :
                   screenWidth <= 375 ? 40 :
                   screenWidth <= 393 ? 48 :
                   56
        }
    }
    
    private var titleSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 28 :
                   screenWidth <= 834 ? 32 :
                   screenWidth <= 1024 ? 36 :
                   40
        } else {
            return screenWidth <= 320 ? 20 :
                   screenWidth <= 375 ? 24 :
                   screenWidth <= 393 ? 28 :
                   32
        }
    }
    
    private var subtitleSize: CGFloat {
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
    
    private var characterCountSize: CGFloat {
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
    
    private var buttonIconSize: CGFloat {
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
    
    private var buttonTextSize: CGFloat {
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
    
    private var cancelButtonSize: CGFloat {
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
    
    // Spacing and Padding Properties
    private var headerTopPadding: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 40 :
                   screenWidth <= 834 ? 50 :
                   screenWidth <= 1024 ? 60 :
                   70
        } else {
            return screenWidth <= 320 ? 24 :
                   screenWidth <= 375 ? 32 :
                   screenWidth <= 393 ? 40 :
                   48
        }
    }
    
    private var headerBottomPadding: CGFloat {
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
    
    private var formSpacing: CGFloat {
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
    
    private var formPadding: CGFloat {
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
    
    private var buttonSpacing: CGFloat {
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
    
    private var buttonPadding: CGFloat {
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
    
    private var buttonVerticalPadding: CGFloat {
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
    
    private var buttonBottomPadding: CGFloat {
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
}

#Preview {
    SetlistView(setlistManager: SetlistManager())
}
