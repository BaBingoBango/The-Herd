//
//  FontPickerView.swift
//  The Herd
//
//  Created by Ethan Marshall on 8/20/23.
//

import SwiftUI

/// An app view written in SwiftUI!
struct FontPickerView: View {
    
    // MARK: View Variables
    @ObservedObject var currentUser: User
    @State var changeFont = Operation()
    
    // MARK: View Body
    var body: some View {
        Form {
            Section(header: Text("Text Style"), footer: Text("Posts and comments will appear in your chosen font, but your choice won't affect how others view your content.")) {
                FontOptionView(currentUser: currentUser, font: .regular, changeFont: $changeFont)
                
                FontOptionView(currentUser: currentUser, font: .rounded, changeFont: $changeFont)
                
                FontOptionView(currentUser: currentUser, font: .serif, changeFont: $changeFont)
                
                FontOptionView(currentUser: currentUser, font: .monospace, changeFont: $changeFont)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: View Functions
    // Functions go here! :)
}

// MARK: View Preview
struct FontPickerView_Previews: PreviewProvider {
    static var previews: some View {
        FontPickerView(currentUser: .getSample())
    }
}

// MARK: Support Views
struct FontOptionView: View {
    
    @ObservedObject var currentUser: User
    var font: FontPreference
    @Binding var changeFont: Operation
    
    var body: some View {
        Button(action: {
            if currentUser.fontPreference != font {
                changeFont.status = .inProgress
                
                usersCollection.document(currentUser.UUID).updateData([
                    "fontPreference" : font.toString()
                ]) { error in
                    if let error = error {
                        changeFont.setError(message: error.localizedDescription)
                    } else {
                        changeFont.status = .success
                    }
                }
            }
        }) {
            HStack {
                Text(font.toString().prefix(1).capitalized + font.toString().dropFirst())
                    .dynamicFont(.title2, fontDesign: font.toFontDesign(), lineLimit: 5, padding: 0)
                    .foregroundColor(.primary)
                
                if currentUser.fontPreference == font {
                    Spacer()
                    
                    Image(systemName: "checkmark")
                        .fontWeight(.semibold)
                        .foregroundColor(.accentColor)
                }
            }
        }
        .disabled(changeFont.status == .inProgress)
        .onAppear {
            // MARK: View Launch Code
            // Set up a real-time listener for the user's profile!
            usersCollection.document(currentUser.UUID).addSnapshotListener({ snapshot, error in
                if let snapshot = snapshot {
                    if let snapshotData = snapshot.data() { currentUser.replaceFields(User.dedictify(snapshotData)) }
                }
            })
        }
    }
}
