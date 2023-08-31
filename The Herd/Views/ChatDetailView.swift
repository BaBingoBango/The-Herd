//
//  ChatDetailView.swift
//  The Herd
//
//  Created by Ethan Marshall on 8/7/23.
//

import SwiftUI

/// An app view written in SwiftUI!
struct ChatDetailView: View {
    
    // MARK: View Variables
    @ObservedObject var currentUser: User
    @State var chat: Chat
    var navigationTitle = "Chat"
    @State var enteredMessage: String? = nil
    @State var showingEditor = false
    @Binding var newlyCreatedPost: Post
    
    // MARK: View Body
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                ScrollViewReader { scrollReader in
                    ForEach(chat.messages.sorted(by: { $0.timeSent < $1.timeSent })) { eachMessage in
                        HStack {
                            if eachMessage.sender.userID == currentUser.UUID {
                                Spacer()
                            }
                            
                            if eachMessage.sender.userID != currentUser.UUID {
                                ZStack {
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(eachMessage.sender.color)
                                    
                                    Text(eachMessage.sender.emoji)
                                        .font(.system(size: 22))
                                }
                            }
                            
                            Text(eachMessage.text)
                                .fontWeight(.semibold)
                                .padding()
                                .modifier(RectangleWrapper(color: .gray, opacity: 0.1, cornerRadius: 30, enforceLayoutPriority: true))
                            
                            if eachMessage.sender.userID == currentUser.UUID {
                                ZStack {
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(eachMessage.sender.color)
                                    
                                    Text(eachMessage.sender.emoji)
                                        .font(.system(size: 22))
                                }
                            }
                            
                            if eachMessage.sender.userID != currentUser.UUID {
                                Spacer()
                            }
                        }
                        .id(eachMessage.UUID)
                        .isHidden(currentUser.blockedUserIDs.contains(eachMessage.sender.userID) &&
                                  eachMessage.timeSent > currentUser.blockDetails[eachMessage.sender.userID]?.associatedDate ?? Date(),
                                  remove: true)
                    }
                    .onAppear {
                        scrollReader.scrollTo(chat.messages.last?.UUID, anchor: .bottom)
                    }
                    .onChange(of: chat.messages) { _ in
                        scrollReader.scrollTo(chat.messages.last?.UUID, anchor: .bottom)
                    }
                }
            }
            
            Spacer()
            
            HStack {
                TextEditorApproachView(textBinding: $enteredMessage)
                
                Button(action: {
                    if let unwrappedEnteredMessage = enteredMessage {
                        var newMessages = chat.messages
                        newMessages.append(.init(sender: .init(userID: currentUser.UUID, emoji: currentUser.emoji, color: currentUser.color), text: unwrappedEnteredMessage, timeSent: Date()))
                        enteredMessage = nil
                        chatsCollection.document(chat.UUID).updateData([
                            "messages" : newMessages.map({ $0.dictify() })
                        ])
                    }
                }) {
                    Image(systemName: "arrow.up.square.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.accentColor)
                }
            }
            .layoutPriority(-1)
        }
        .padding([.horizontal, .bottom])
        
        // MARK: Navigation Settings
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: {
                    showingEditor = true
                }) {
                    Image(systemName: "info.circle")
                        .fontWeight(.semibold)
                        .foregroundColor(.accentColor)
                }
                .sheet(isPresented: $showingEditor) {
                    ChatEditorView(currentUser: currentUser, chat: chat, newlyCreatedPost: $newlyCreatedPost)
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
        }
    }
    
    // MARK: View Functions
    // Functions go here! :)
}

// MARK: View Preview
struct ChatDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatDetailView(currentUser: .getSample(), chat: Chat.samples.randomElement()!, newlyCreatedPost: .constant(.sample))
        }
    }
}

// MARK: Support Views
/// From https://medium.com/nerd-for-tech/create-an-automatically-expanding-texteditor-with-a-placeholder-in-swiftui-6f4792c1ba19
struct TextEditorApproachView: View {
    
    var text: Binding<String?>
    
    let placeholder = "Enter Text Here"
    
    init(textBinding: Binding<String?>) {
        UITextView.appearance().backgroundColor = .clear
        text = textBinding
    }
    
    var body: some View {
        VStack {
//            ScrollView {
                ZStack(alignment: .topLeading) {
                    Color.gray
                        .opacity(0.3)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    Text(text.wrappedValue ?? placeholder)
                        .padding()
                        .opacity(text.wrappedValue == nil ? 1 : 0)
                    
                    TextEditor(text: Binding(text, replacingNilWith: ""))
                        .frame(minHeight: 30, alignment: .leading)
                        .cornerRadius(6.0)
                        .multilineTextAlignment(.leading)
                        .padding(5)
                }
//            }
        }
    }
}

public extension Binding where Value: Equatable {
    init(_ source: Binding<Value?>, replacingNilWith nilProxy: Value) {
        self.init(
            get: { source.wrappedValue ?? nilProxy },
            set: { newValue in
                if newValue == nilProxy {
                    source.wrappedValue = nil
                } else {
                    source.wrappedValue = newValue
                }
            }
        )
    }
}
