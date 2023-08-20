//
//  ChatEditorView.swift
//  The Herd
//
//  Created by Ethan Marshall on 8/17/23.
//

import SwiftUI

/// An app view written in SwiftUI!
struct ChatEditorView: View {
    
    // MARK: View Variables
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var currentUser: User
    @State var chat: Chat
    var memberInfo: [(String, String, Color)] {
        var answer: [(String, String, Color)] = []
        for eachIndex in 0..<chat.memberIDs.count {
            answer.append((chat.memberIDs[eachIndex], chat.memberEmojis[eachIndex], chat.memberColors[eachIndex]))
        }
        return answer
    }
    @State var showingRolodex = false
    @State var mentions: [ChatMember] = []
    @State var toggleHiding = Operation()
    
    // MARK: View Body
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Members")) {
                    ForEach(memberInfo, id: \.0) { eachMemberInfo in
                        HStack {
                            ZStack {
                                Circle()
                                    .foregroundColor(eachMemberInfo.2)
                                    .frame(height: 40)
                                
                                Text(eachMemberInfo.1)
                                    .font(.system(size: 27.5))
                            }
                            .padding(.leading, 10)
                            
                            VStack(alignment: .leading) {
                                let rolodexNickname = currentUser.addresses[eachMemberInfo.0]?.nickname ?? "Unsaved User"
                                let rolodexComment = eachMemberInfo.0 == currentUser.UUID ? "" : currentUser.addresses[eachMemberInfo.0]?.comment
                                
                                Text(eachMemberInfo.0 == currentUser.UUID ? "You" : rolodexNickname)
                                    .dynamicFont(.title3, fontDesign: .rounded, padding: 0)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                if let rolodexComment = rolodexComment {
                                    if !rolodexComment.isEmpty {
                                        Text(rolodexComment)
                                            .dynamicFont(.body, minimumScaleFactor: 0.9, padding: 0)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                    
                    Button(action: {
                        showingRolodex = true
                    }) {
                        Text("Add Member...")
                    }
                    .sheet(isPresented: $showingRolodex) {
                        AddressBookView(currentUser: currentUser, pickerMode: true, mentions: $mentions, pickerAction: "Add", excludedUserIDs: chat.memberIDs)
                            .onAppear {
                                print(chat.memberIDs)
                            }
                    }
                }
                
                Section(footer: Text("Hidden chats can be accessed and restored from the Chats screen by selecting Hidden Chats.")) {
                    Button(action: {
                        toggleHiding.status = .inProgress
                        
                        var newChatIDs = currentUser.hiddenChatIDs
                        if currentUser.hiddenChatIDs.contains(chat.UUID) {
                            newChatIDs.removeAll(where: { $0 == chat.UUID })
                        } else {
                            newChatIDs.append(chat.UUID)
                        }
                        usersCollection.document(currentUser.UUID).updateData([
                            "hiddenChatIDs" : newChatIDs
                        ]) { error in
                            if let error = error {
                                toggleHiding.setError(message: error.localizedDescription)
                            } else {
                                toggleHiding.status = .success
                            }
                        }
                    }) {
                        Text(currentUser.hiddenChatIDs.contains(chat.UUID) ? "Restore Chat" : "Hide Chat")
                    }
                    .disabled(toggleHiding.status == .inProgress)
                }
            }
            .onChange(of: mentions) { _ in
                if !mentions.isEmpty {
                    updateMembers()
                }
            }
            
            // MARK: Navigation Settings
            .navigationTitle("Chat Settings")
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
            
            // MARK: View Launch Code
            .onAppear {
                // Add a real-time listener for this chat!
                chatsCollection.document(chat.UUID).addSnapshotListener({ snapshot, error in
                    if let snapshot = snapshot {
                        chat = Chat.dedictify(snapshot.data()!)
                    }
                })
                // Set up a real-time listener for the user's profile!
                usersCollection.document(currentUser.UUID).addSnapshotListener({ snapshot, error in
                    if let snapshot = snapshot {
                        if let snapshotData = snapshot.data() { currentUser.replaceFields(User.dedictify(snapshotData)) }
                    }
                })
            }
        }
    }
    
    // MARK: View Functions
    func updateMembers() {
        var newIDs = chat.memberIDs; newIDs.append(mentions.first!.userID)
        var newEmojis = chat.memberEmojis; newEmojis.append(mentions.first!.emoji)
        var newColors = chat.memberColors; newColors.append(mentions.first!.color)
        mentions = []
        
        chatsCollection.document(chat.UUID).updateData([
            "memberIDs" : newIDs,
            "memberEmojis" : newEmojis,
            "memberColors" : newColors.map({ $0.dictify() })
        ]) { error in
            // TODO: add an error here!
        }
    }
}

// MARK: View Preview
struct ChatEditorView_Previews: PreviewProvider {
    static var previews: some View {
        ChatEditorView(currentUser: .getSample(), chat: .samples.randomElement()!)
    }
}

// MARK: Support Views
// Support views go here! :)
