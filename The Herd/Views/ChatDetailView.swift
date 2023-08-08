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
    @State var chat: Chat
    var navigationTitle = "Chat"
    @State var enteredMessage = "Message"
    
    // MARK: View Body
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                ForEach(chat.messages.sorted(by: { $0.timeSent < $1.timeSent }), id: \.UUID) { eachMessage in
                    HStack {
                        ZStack {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(eachMessage.sender.color)
                            
                            Text(eachMessage.sender.emoji)
                                .font(.system(size: 22))
                        }
                        
                        Text(eachMessage.text)
                            .fontWeight(.semibold)
                            .padding()
                            .modifier(RectangleWrapper(color: .gray, opacity: 0.1, cornerRadius: 30, enforceLayoutPriority: true))
                        
                        Spacer()
                    }
                }
            }
            
            Spacer()
            
            HStack {
                TextEditorApproachView()
                
                Button(action: {
                    
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
    }
    
    // MARK: View Functions
    // Functions go here! :)
}

// MARK: View Preview
struct ChatDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatDetailView(chat: Chat.samples.randomElement()!)
        }
    }
}

// MARK: Support Views
/// From https://medium.com/nerd-for-tech/create-an-automatically-expanding-texteditor-with-a-placeholder-in-swiftui-6f4792c1ba19
struct TextEditorApproachView: View {
    
    @State private var text: String?
    
    let placeholder = "Enter Text Here"
    
    init() {
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        VStack {
//            ScrollView {
                ZStack(alignment: .topLeading) {
                    Color.gray
                        .opacity(0.3)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    Text(text ?? placeholder)
                        .padding()
                        .opacity(text == nil ? 1 : 0)
                    
                    TextEditor(text: Binding($text, replacingNilWith: ""))
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
