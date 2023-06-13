//
//  NewPostView.swift
//  The Herd
//
//  Created by Ethan Marshall on 6/11/23.
//

import SwiftUI
import FirebaseAuth

/// An app view written in SwiftUI!
struct NewPostView: View {
    
    // MARK: View Variables
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.colorScheme) var colorScheme
    @State var enteredText = ""
    @State var uploadPost = Operation()
    
    // MARK: View Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Text("New post time?")
                        .font(.system(size: 30))
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    ZStack {
                        VStack {
                            HStack {
                                Text("Write your post here!")
                                    .font(.system(size: 22.5))
                                    .fontWeight(.bold)
                                    .padding([.leading, .top], 6)
                                
                                Spacer()
                            }
                            
                            Spacer()
                        }
                        
                        TextEditor(text: $enteredText)
                            .font(.system(size: 22.5))
                            .fontWeight(.bold)
                            .opacity(enteredText.isEmpty ? 0.5 : 1)
                    }
                    .padding()
                    .background(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.white)
                    .frame(height: 300)
                    .cornerRadius(10)
                    .shadow(color: .gray.opacity(0.3), radius: 10)
                    
                    HStack {
                        Text("🗺️")
                            .font(.system(size: 40))
                        
                        Text("Anyone within five miles of where you are will be able to see your post, but you'll be able to see it from anywhere!")
                            .font(.system(size: 17.5))
                            .fontWeight(.medium)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                    .padding()
                    .modifier(RectangleWrapper(color: .teal, opacity: 0.25))
                    .padding(.top, 5)
                    
                    HStack {
                        Text("🔒")
                            .font(.system(size: 40))
                        
                        Text("Drafts are end-to-end encrypted and can't be accessed by anyone but you.")
                            .font(.system(size: 17.5))
                            .fontWeight(.medium)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                    .padding()
                    .modifier(RectangleWrapper(color: .red, opacity: 0.25))
                }
                .padding(.horizontal)
            }
            
            HStack {
                Button(action: {
                    uploadPost.status = .inProgress
                    
                    // TODO: create and upload a new post!
                }) {
                    if uploadPost.status != .inProgress {
                        Text("Submit!")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .modifier(RectangleWrapper(fixedHeight: 55, color: .accentColor))
                    } else {
                        ProgressView()
                            .modifier(RectangleWrapper(fixedHeight: 55, color: .gray.opacity(0.25)))
                    }
                }
                
                Button(action: {
                    // TODO: add a draft!
                }) {
                    Text("Save Draft")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                        .modifier(RectangleWrapper(fixedHeight: 55, color: .gray.opacity(0.15)))
                        .disabled(uploadPost.status == .inProgress)
                }
            }
            .padding([.bottom, .horizontal])
            
            // MARK: Navigation Settings
            .toolbar(content: {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel")
                            .fontWeight(.bold)
                    }
                }
            })
        }
        .alert(isPresented: $uploadPost.isShowingErrorMessage) {
            Alert(title: Text("Couldn't Create Post"),
                  message: Text(uploadPost.errorMessage),
                  dismissButton: .default(Text("Close")))
        }
    }
    
    // MARK: View Functions
    // Functions go here! :)
}

// MARK: View Preview
struct NewPostView_Previews: PreviewProvider {
    static var previews: some View {
        NewPostView()
    }
}

// MARK: Support Views
// Support views go here! :)
