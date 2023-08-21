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
    @ObservedObject var currentUser: User
    @State var showingSignOutConfirmation = false
    @State var signOut = Operation()
    
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
            }
            .headerProminence(.increased)
            
            Section(header: Text("Account").font(.title3).fontWeight(.bold)) {
                NavigationLink(destination: EmptyView()) {
                    ProfileOptionView(text: "??????", color: .orange, iconName: "questionmark")
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
            
            Section(header: Text("Danger Zone!").font(.title3).fontWeight(.bold)) {Button(action: {
                    showingSignOutConfirmation = true
                }) {
                    ProfileOptionView(text: "Sign Out...", color: .red, iconName: "arrow.left")
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: DeleteAccountView(currentUser: currentUser)) {
                    ProfileOptionView(text: "Delete Account", color: .red, iconName: "trash.fill")
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
    }
    
    // MARK: View Functions
    // Functions go here! :)
}

// MARK: View Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView(currentUser: .getSample())
        }
    }
}

// MARK: Support Views
struct ProfileOptionView: View {
    
    var text: String
    var color: Color
    var iconName: String
    var percentComplete: String?
    
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
            
            Spacer()
            
            if percentComplete != nil {
                Text(percentComplete!)
                    .foregroundColor(.secondary)
            }
        }
    }
}
