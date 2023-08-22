//
//  ChangeIdentityView.swift
//  The Herd
//
//  Created by Ethan Marshall on 8/21/23.
//

import SwiftUI

/// An app view written in SwiftUI!
struct ChangeIdentityView: View {
    
    // MARK: View Variables
    @ObservedObject var currentUser: User
    @State var changeIdentity = Operation()
    
    // MARK: View Body
    var body: some View {
        VStack {
            ZStack {
                Image(systemName: "circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(currentUser.color)
                
                Text(currentUser.emoji)
                    .font(.system(size: 35))
            }
            .shadow(color: .gray, radius: 5)
            
            Text("Change Emoji And Color")
                .dynamicFont(.title, lineLimit: 5)
                .multilineTextAlignment(.center)
                .fontWeight(.bold)
                .offset(y: 5)
            
            Spacer()
            
            InformationalRowView(iconName: "arrow.triangle.2.circlepath", text: "Use this tool to randomize your color and emoji to something new! You can change as often as you like.", color: .orange)
                .padding(.bottom)
            
            InformationalRowView(iconName: "bubble.left.and.exclamationmark.bubble.right.fill", text: "You won't be able to access old chats, but you'll still be able to delete old posts and comments.", color: .orange)
                .padding(.bottom)
            
            InformationalRowView(iconName: "arrow.uturn.backward", text: "Once you change, you won't be able to go back, unless you roll the same combo again!", color: .orange)
            
            Spacer()
            
            ZStack {
                Button(action: {
                    changeUserIdentity()
                }) {
                    Text(changeIdentity.status == .inProgress ? "" : "Change Identity!")
                        .dynamicFont(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .modifier(RectangleWrapper(fixedHeight: 55, color: changeIdentity.status == .inProgress ? .gray.opacity(0.2) : .orange, opacity: 1))
                }
                .disabled(changeIdentity.status == .inProgress)
                .alert(isPresented: $changeIdentity.isShowingErrorMessage) {
                    Alert(title: Text("Couldn't Change Identity"),
                          message: Text(changeIdentity.errorMessage),
                          dismissButton: .default(Text("Close")))
                }
                
                if changeIdentity.status == .inProgress {
                    ProgressView()
                }
            }
        }
        .padding([.horizontal, .bottom])
        .navigationTitle("Edit Identity")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(changeIdentity.status == .inProgress)
        .interactiveDismissDisabled(changeIdentity.status == .inProgress)
        
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
    
    // MARK: View Functions
    func changeUserIdentity() {
        changeIdentity.status = .inProgress
        let newEmoji = Emoji.allEmojis.randomElement()!
        let newColor = User.iconColors.randomElement()!
        
        usersCollection.document(currentUser.UUID).updateData([
            "emoji" : newEmoji,
            "color" : [
                Double(UIColor(newColor).cgColor.components![0]),
                Double(UIColor(newColor).cgColor.components![1]),
                Double(UIColor(newColor).cgColor.components![2]),
                Double(UIColor(newColor).cgColor.components![3])
            ]
        ]) { error in
            if let error = error {
                changeIdentity.setError(message: error.localizedDescription)
            } else {
                changeIdentity.status = .success
            }
        }
    }
}

// MARK: View Preview
struct ChangeIdentityView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChangeIdentityView(currentUser: .getSample())
        }
    }
}

// MARK: Support Views
// Support views go here! :)
