//
//  SettingsView.swift
//  The Herd
//
//  Created by Ethan Marshall on 6/12/23.
//

import SwiftUI
import FirebaseAuth

/// An app view written in SwiftUI!
struct SettingsView: View {
    
    // MARK: View Variables
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var currentUser: User
    @State var showingSignOutConfirmation = false
    @State var signOut = Operation()
    @State var selectedKeyboardOption: Bool
    @State var changeKeyboardOption = Operation()
    
    // MARK: View Body
    var body: some View {
        Form {
            Section(header: Text("Appearance").font(.title3).fontWeight(.bold)) {
                NavigationLink(destination: FontPickerView(currentUser: currentUser)) {
                    ProfileOptionView(text: "Text Style", color: .cyan, iconName: "textformat")
                }
                
                NavigationLink(destination: EmptyView()) {
                    ProfileOptionView(text: "App Icon", color: .cyan, iconName: "photo.artframe")
                }
                
                HStack {
                    ProfileOptionView(text: "Rainbow Keyboard", color: .cyan, iconName: "keyboard.fill", hideSpacer: changeKeyboardOption.status != .inProgress)
                    
                    if changeKeyboardOption.status != .inProgress {
                        Toggle("", isOn: $selectedKeyboardOption)
                            .layoutPriority(-1)
                    } else {
                        ProgressView()
                    }
                }
            }
            .headerProminence(.increased)
            
            Section(header: Text("Account").font(.title3).fontWeight(.bold)) {
                NavigationLink(destination: ChangeIdentityView(currentUser: currentUser)) {
                    ProfileOptionView(text: "Change Emoji & Color", color: .orange, iconName: "arrow.triangle.2.circlepath")
                }
                
                NavigationLink(destination: EmptyView()) {
                    ProfileOptionView(text: "Blocked Users", color: .orange, iconName: "questionmark")
                }
            }
            .headerProminence(.increased)
            
            Section(header: Text("Privacy").font(.title3).fontWeight(.bold)) {
                NavigationLink(destination: DataSharingView()) {
                    ProfileOptionView(text: "Data Sharing & Access", color: .blue, iconName: "person.2.fill")
                }
                
                NavigationLink(destination: DataDownloaderView(currentUser: currentUser)) {
                    ProfileOptionView(text: "Download Data", color: .blue, iconName: "square.and.arrow.down.fill")
                }
                
                NavigationLink(destination: EmptyView()) {
                    ProfileOptionView(text: "Privacy Policy", color: .blue, iconName: "hand.raised.fill")
                }
            }
            .headerProminence(.increased)
            
            Section(header: Text("Danger Zone!").font(.title3).fontWeight(.bold)) {
                Button(action: {
                    showingSignOutConfirmation = true
                }) {
                    ProfileOptionView(text: "Sign Out...", color: .red, iconName: "arrow.left")
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: DeleteContentView(currentUser: currentUser)) {
                    ProfileOptionView(text: "Delete Content", color: .red, iconName: "trash.fill")
                }
                
                NavigationLink(destination: DeleteAccountView(currentUser: currentUser)) {
                    ProfileOptionView(text: "Delete Account", color: .red, iconName: "person.fill.xmark")
                }
            }
            .headerProminence(.increased)
            .alert(isPresented: $signOut.isShowingErrorMessage) {
                Alert(title: Text("Couldn't Sign Out"),
                      message: Text(signOut.errorMessage),
                      dismissButton: .default(Text("Close")))
            }
            
            Section(header: Text("About").font(.title3).fontWeight(.bold)) {
                NavigationLink(destination: EmptyView()) {
                    Text("Licensing and Credit")
                }
                
                HStack {
                    Text("Version Number")
                    Spacer()
                    Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)
                        .fontDesign(.monospaced)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Build Number")
                    Spacer()
                    Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String)
                        .fontDesign(.monospaced)
                        .foregroundColor(.secondary)
                }
            }
            .headerProminence(.increased)
        }
        .onAppear {
            // MARK: View Launch Code
            // Set up a real-time listener for the user's profile!
            usersCollection.document(currentUser.UUID).addSnapshotListener({ snapshot, error in
                if let snapshot = snapshot {
                    if let snapshotData = snapshot.data() {
                        currentUser.replaceFields(User.dedictify(snapshotData))
                        selectedKeyboardOption = currentUser.useRainbowKeyboard
                        changeKeyboardOption.status = .success
                    }
                }
            })
        }
        .onChange(of: selectedKeyboardOption) { _ in
            changeKeyboardOption.status = .inProgress
            
            usersCollection.document(currentUser.UUID).updateData([
                "useRainbowKeyboard" : selectedKeyboardOption
            ]) { error in
                if let error = error { changeKeyboardOption.setError(message: error.localizedDescription) }
            }
        }
        .alert(isPresented: $showingSignOutConfirmation) {
            Alert(title: Text("Sign Out?"),
                  message: Text("You'll need to sign back in again to access your data, but nothing will be deleted."),
                  primaryButton: .default(Text("Cancel")),
                  secondaryButton: .destructive(Text("Sign Out")) {

                signOut.status = .inProgress
                do {
                    try Auth.auth().signOut()
                } catch {
                    signOut.setError(message: error.localizedDescription)
                }
            })
        }
        
        // MARK: Navigation Settings
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Done")
                        .fontWeight(.bold)
                }
            }
        })
    }
    
    // MARK: View Functions
    // Functions go here! :)
}

// MARK: View Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView(currentUser: .getSample(), selectedKeyboardOption: false)
        }
    }
}

// MARK: Support Views
struct ProfileOptionView: View {
    
    var text: String
    var color: Color
    var iconName: String
    var percentComplete: String?
    var hideSpacer = false
    
    var body: some View {
        HStack {
            ZStack {
                Rectangle()
                    .fill(color.gradient)
                    .aspectRatio(1, contentMode: .fit)
                    .cornerRadius(6)
                
                Image(systemName: iconName)
                    .font(.system(size: 14))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .aspectRatio(contentMode: .fit)
            }
            .frame(width: 30)
            
            Text(text)
                .foregroundColor(.primary)
            
            if !hideSpacer {
                Spacer()
            }
            
            if percentComplete != nil {
                Text(percentComplete!)
                    .foregroundColor(.secondary)
            }
        }
    }
}
