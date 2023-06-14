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
    @State var currentUser: User? = nil
    
    var withinCharacterLimits: Bool {
        return enteredText.count >= 1 && enteredText.count <= 500
    }
    
    // MARK: View Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Text("New post time?")
                        .dynamicFont(.largeTitle, lineLimit: 2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    ZStack {
                        VStack {
                            HStack {
                                Text("Write your post here!")
                                    .dynamicFont(.title2, lineLimit: 2, padding: 0)
                                    .fontWeight(.bold)
                                    .padding([.leading, .top], 6)
                                
                                Spacer()
                            }
                            
                            Spacer()
                        }
                        
                        TextEditor(text: $enteredText)
                            .dynamicFont(.title2, padding: 0)
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
                            .font(.system(size: 37.5))
                        
                        Text("Anyone within five miles of where you are will be able to see your post, but you'll be able to see it from anywhere!")
                            .font(.callout)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                    .padding()
                    .modifier(RectangleWrapper(color: .teal, opacity: 0.25))
                    .padding(.top, 5)
                    
//                    HStack {
//                        Text("🔒")
//                            .font(.system(size: 40))
//
//                        Text("Drafts are end-to-end encrypted and can't be accessed by anyone but you.")
//                            .font(.system(size: 17.5))
//                            .fontWeight(.medium)
//                            .multilineTextAlignment(.leading)
//
//                        Spacer()
//                    }
//                    .padding()
//                    .modifier(RectangleWrapper(color: .red, opacity: 0.25))
                }
                .padding(.horizontal)
            }
            
            HStack {
                Button(action: {
                    // Check if the current user is loaded in!
                    if let currentUser = currentUser {
                        uploadPost.status = .inProgress
                        
                        // Create the new Post object!
                        let newPost = Post(author: currentUser,
                                           text: enteredText,
                                           votes: [currentUser.UUID : .init(voter: currentUser, value: 1, timePosted: Date())],
                                           comments: [],
                                           timePosted: Date(),
                                           latitude: 0, // TODO: add location!
                                           longitude: 0)
                        
                        // Transport the new post!
                        // TODO: NEXT - test this! <3
                        newPost.transportToServer(path: postsCollection,
                                                  documentID: newPost.UUID,
                                                  operation: $uploadPost,
                                                  onError: nil,
                                                  onSuccess: { presentationMode.wrappedValue.dismiss() })
                    }
                }) {
                    if uploadPost.status != .inProgress {
                        Text("Submit!")
                            .dynamicFont(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .modifier(RectangleWrapper(fixedHeight: 55, color: .accentColor))
                    } else {
                        ProgressView()
                            .modifier(RectangleWrapper(fixedHeight: 55, color: .gray.opacity(0.25)))
                    }
                }
                .disabled(!withinCharacterLimits || currentUser == nil)
                
                Button(action: {
                    // TODO: add a draft!
                }) {
                    Text("Save Draft")
                        .dynamicFont(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                        .modifier(RectangleWrapper(fixedHeight: 55, color: .gray.opacity(0.15)))
                }
                .disabled(!withinCharacterLimits || currentUser == nil || uploadPost.status == .inProgress)
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
        .onAppear {
            // MARK: View Launch Code
            // If we haven't loaded the user's profile yet, transport it!
            if let userID = Auth.auth().currentUser?.uid {
                User.transportUserFromServer(userID,
                                             onError: { error in fatalError(error.localizedDescription) },
                                             onSuccess: { user in currentUser = user })
                
                // Set up a real-time listener for the user's profile!
                usersCollection.document(userID).addSnapshotListener({ snapshot, error in
                    if let snapshot = snapshot {
                        if let snapshotData = snapshot.data() { currentUser = User.dedictify(snapshotData) }
                    }
                })
            }
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
