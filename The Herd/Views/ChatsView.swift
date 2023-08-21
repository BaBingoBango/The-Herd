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
    var hiddenChatsMode = false
    var locationManager = LocationManager()
    @State var showingProfileView = false
    
    // MARK: View Body
    var body: some View {
        let viewBody = Group {
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
                    ForEach(userChats.filter({ !hiddenChatsMode ? !currentUser.hiddenChatIDs.contains($0.UUID) : currentUser.hiddenChatIDs.contains($0.UUID) }).sorted(by: {
                        let firstChatLastUpdate = $0.messages.last?.timeSent ?? $0.dateCreated
                        let secondChatLastUpdate = $1.messages.last?.timeSent ?? $1.dateCreated
                        return firstChatLastUpdate > secondChatLastUpdate
                        
                    }), id: \.UUID) { eachChat in
                        let isGroupChat = eachChat.memberIDs.count >= 3
                        let nonUserIDs = eachChat.memberIDs.filter({ $0 != currentUser.UUID })
                        
                        NavigationLink(destination: ChatDetailView(currentUser: currentUser, chat: eachChat, navigationTitle: !isGroupChat ? "Chat with \(eachChat.getEmoji(nonUserIDs.first!))" : "Chat with \(nonUserIDs.count) People")) {
                            
                            ChatOptionView(color: isGroupChat ? .gray : eachChat.getColor(nonUserIDs.first!),
                                           isGroupChat: isGroupChat,
                                           emoji: eachChat.getEmoji(nonUserIDs.first!),
                                           text: eachChat.messages.last?.text ?? "No Messages Yet!")
                        }
                    }
                    
                    if !currentUser.hiddenChatIDs.isEmpty && !hiddenChatsMode {
                        NavigationLink(destination: ChatsView(currentUser: currentUser, hiddenChatsMode: true)) {
                            ChatOptionView(color: .gray,
                                           isGroupChat: true,
                                           emoji: "",
                                           text: "\(currentUser.hiddenChatIDs.count) Hidden Chat\(currentUser.hiddenChatIDs.count == 1 ? "" : "s")",
                                           grayIconName: "eye.slash")
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        
        // MARK: Navigation Settings
        .navigationTitle(!hiddenChatsMode ? "Chats" : "Hidden Chats")
        .navigationBarTitleDisplayMode(!hiddenChatsMode ? .automatic : .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    showingProfileView = true
                }) {
                    ZStack {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(currentUser.color)

                        Text(currentUser.emoji)
                            .font(.system(size: 20))
                    }
                }
                .sheet(isPresented: $showingProfileView) {
                    ProfileView(currentUser: currentUser, locationManager: locationManager)
                }
            }
            
            if !hiddenChatsMode {
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
                        AddressBookView(currentUser: currentUser, pickerMode: true, mentions: $mentions, pickerAction: "Chat", excludedUserIDs: [])
                    }
                }
            }
        }
        .onAppear {
            // MARK: View Launch Code
            // Set up a real-time listener for chats!
            // TODO: update this to check color and emoji as well
            chatsCollection.whereField("memberIDs", arrayContains: currentUser.UUID).addSnapshotListener({ snapshot, error in
                if let snapshot = snapshot {
                    userChats = snapshot.documents.map({ Chat.dedictify($0.data()) })
                }
            })
        }
        
        if !hiddenChatsMode {
            NavigationView {
                viewBody
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
        } else {
            viewBody
        }
    }
    
    // MARK: View Functions
    func createNewChat() {
        var chatMembers = mentions
        mentions = []
        chatMembers.append(.init(userID: currentUser.UUID, emoji: currentUser.emoji, color: currentUser.color))
        let newChat = Chat(memberIDs: chatMembers.map({ $0.userID }),
                           memberEmojis: chatMembers.map({ $0.emoji }),
                           memberColors: chatMembers.map({ $0.color }),
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
struct ChatOptionView: View {
    
    var color: Color
    var isGroupChat: Bool
    var emoji: String
    var text: String
    var grayIconName = "person.2.fill"
    
    var body: some View {
        HStack {
            ZStack {
                Image(systemName: "circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(color)
                
                if isGroupChat {
                    Image(systemName: grayIconName)
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                } else {
                    Text(emoji)
                        .font(.system(size: 22.5))
                }
            }
            .shadow(color: .gray, radius: 5)
            
            Text(text)
                .dynamicFont(.body, lineLimit: 2, minimumScaleFactor: 0.9, padding: 0)
                .foregroundColor(.primary)
        }
    }
}
