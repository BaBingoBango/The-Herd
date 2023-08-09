//
//  ChatsView.swift
//  The Herd
//
//  Created by Ethan Marshall on 8/6/23.
//

import SwiftUI
import FirebaseFirestore

/// An app view written in SwiftUI!
struct ChatsView: View {
    
    // MARK: View Variables
    @ObservedObject var currentUser: User
    @State var userChats: [Chat] = []
    @State var refreshChats = Operation()
    @State var createChat = Operation()
    @State var showingRolodex = false
    @State var mentions: [ChatMember] = []
    
    // MARK: View Body
    var body: some View {
        NavigationView {
            Group {
                if refreshChats.status == .inProgress {
                    ProgressView()
                        .controlSize(.large)
                    
                } else if userChats.isEmpty {
                    VStack {
                        Image(systemName: "ellipsis.bubble.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                            .padding(.top)
                            .padding(.bottom, 1)
                        
                        Text("No Chats")
                            .dynamicFont(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 1)
                        
                        Text("Start a chat with another user to exchange messages here!")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                } else {
                    List {
                        ForEach(userChats, id: \.UUID) { eachChat in
                            NavigationLink(destination: ChatDetailView(chat: eachChat, navigationTitle: "Chat with Someone")) {
                                HStack {
                                    let isGroupChat = eachChat.members.count >= 3
                                    let nonUserMembers = eachChat.members.filter({ $0.UUID != currentUser.UUID })
                                    // TODO: NEXT: fix the above variable to match the new structure
                                    
                                    ZStack {
                                        Image(systemName: "circle.fill")
                                            .font(.system(size: 50))
                                            .foregroundColor(isGroupChat ? .gray : nonUserMembers.first!.color)
                                        
                                        if isGroupChat {
                                            Image(systemName: "person.2.fill")
                                                .font(.system(size: 22.5))
                                                .foregroundColor(.white)
                                        } else {
                                            Text(nonUserMembers.first!.emoji)
                                                .font(.system(size: 25))
                                        }
                                    }
                                    .shadow(color: .gray, radius: 5)
                                    
                                    VStack(alignment: .leading) {
                                        Text("Chat with Someone")
                                            .dynamicFont(.title3, fontDesign: .rounded, padding: 0)
                                            .fontWeight(.bold)
                                            .foregroundColor(.primary)
                                        
                                        if let lastMessage = eachChat.messages.sorted(by: { $0.timeSent < $1.timeSent }).last {
                                            Text(lastMessage.text)
                                                .dynamicFont(.body, minimumScaleFactor: 0.9, padding: 0)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            
            // MARK: Navigation Settings
            .navigationTitle("Chats")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        showingRolodex = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 25))
                            .fontWeight(.bold)
                            .foregroundColor(.accentColor)
                    }
                    .sheet(isPresented: $showingRolodex) {
                        AddressBookView(currentUser: currentUser, pickerMode: true, mentions: $mentions)
                    }
                }
            }
        }
        .alert(isPresented: $createChat.isShowingErrorMessage) {
            Alert(title: Text("Couldn't Create Chat"),
                  message: Text(createChat.errorMessage),
                  dismissButton: .default(Text("Close")))
        }
        .onChange(of: mentions) { _ in
            if !mentions.isEmpty {
                createNewChat()
            }
        }
        .onAppear {
            // MARK: View Launch Code
            // Set up a real-time listener for chats!
//            chatsCollection.wh
        }
    }
    
    // MARK: View Functions
    func createNewChat() {
        var chatMembers = mentions
        chatMembers.append(.init(userID: currentUser.UUID, emoji: currentUser.emoji, color: currentUser.color))
        let newChat = Chat(memberIDs: chatMembers.map({ $0.userID }),
                           memberEmojis: chatMembers.map({ $0.emoji }),
                           memberColorNames: chatMembers.map({ $0.color.toString() }),
                           messages: [])
        newChat.transportToServer(path: chatsCollection,
                                  documentID: newChat.UUID,
                                  operation: nil,
                                  onError: { error in createChat.setError(message: error.localizedDescription) },
                                  onSuccess: { createChat.status = .success })
    }
}

// MARK: View Preview
struct ChatsView_Previews: PreviewProvider {
    static var previews: some View {
        ChatsView(currentUser: .getSample(), userChats: Chat.samples)
    }
}

// MARK: Support Views
// Support views go here! :)
