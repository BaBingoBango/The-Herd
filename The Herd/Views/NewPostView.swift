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
    var draftID: String?
    @AppStorage("postingAnonymously") var postingAnonymously = false
    @State var enteredText = ""
    @FocusState var focusedField: String?
    @State var uploadPost = Operation()
    @State var uploadingDraft = false
    @ObservedObject var currentUser: User = .getSample()
    var locationManager: LocationManager
    
    var withinCharacterLimits: Bool {
        return enteredText.count >= 1 && enteredText.count <= 500
    }
    
    // MARK: View Body
    var body: some View {
        ScrollView {
            VStack {
//                Text("New post time?")
//                    .dynamicFont(.largeTitle, lineLimit: 2)
//                    .fontWeight(.bold)
//                    .multilineTextAlignment(.center)
//                    .padding(.top, 12.5)
                
                Button(action: {
                    postingAnonymously.toggle()
                }) {
                    HStack(spacing: 10) {
                        Text(postingAnonymously ? "🕶️" : currentUser.emoji)
                            .font(.system(size: 37.5))
                        
                        VStack(alignment: .leading, spacing: 2.5) {
                            Text(postingAnonymously ? "Posting Anonymously" : "Posting With Emoji")
                                .dynamicFont(.headline, padding: 0)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 5) {
                                Text(postingAnonymously ? "Use Emoji" : "Go Anonymous")
                                    .dynamicFont(.body, padding: 0)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                    .multilineTextAlignment(.leading)
                                
                                Image(systemName: "chevron.right")
                                    .dynamicFont(.body, padding: 0)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .modifier(RectangleWrapper(color: postingAnonymously ? .gray : currentUser.color, opacity: 0.25))
                }
                
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
                        .focused($focusedField, equals: "editor")
                }
                .padding()
                .background(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.white)
                .frame(height: 300)
                .cornerRadius(10)
                .shadow(color: .gray.opacity(0.3), radius: 10)
                
                HStack {
                    Text("About Posting")
                        .dynamicFont(.title2, padding: 0)
                        .fontWeight(.bold)
                    
                    Spacer()
                }
                .padding(.top, 20)
                
                HStack {
                    Text("🗺️")
                        .font(.system(size: 37.5))
                    
                    Text("Anyone within five miles of where you are now will see your post!")
                        .font(.callout)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
                .padding()
                .modifier(RectangleWrapper(color: .teal, opacity: 0.25))
                
                HStack {
                    Text("🔒")
                        .font(.system(size: 37.5))
                    
                    Text("Another important fact about posts? idk tbh")
                        .font(.callout)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
                .padding()
                .modifier(RectangleWrapper(color: .yellow, opacity: 0.25))
            }
            .padding(.horizontal)
        }
        
        HStack {
            Button(action: {
                // Check if the current user is loaded in!
                uploadPost.status = .inProgress
                
                // Create the new Post object!
                let newPost = Post(authorUUID: currentUser.UUID,
                                   authorEmoji: postingAnonymously ? "🕶️" : currentUser.emoji,
                                   authorColor: postingAnonymously ? .gray : currentUser.color,
                                   anonymousIdentifierTable: postingAnonymously ? [currentUser.UUID : 0] : [:],
                                   text: enteredText,
                                   votes: [currentUser.UUID : .init(voterUUID: currentUser.UUID, value: 1, timePosted: Date())],
                                   comments: [],
                                   timePosted: Date(),
                                   latitude: currentUser.getLocation(locationManager)!.0,
                                   longitude: currentUser.getLocation(locationManager)!.1)
                
                // Transport the new post!
                // FIXME: none of the transports in this view are working when its source is DraftsView!
                newPost.upload(operation: $uploadPost,
                               onError: { error in uploadPost.setError(message: error.localizedDescription) },
                               onSuccess: {
                    
                    // If this was a draft, delete it!
                    if let draftID = draftID {
                        usersCollection.document(currentUser.UUID).collection("drafts").document(draftID).delete() { error in
                            
                            if let error = error {
                                uploadPost.setError(message: error.localizedDescription)
                            } else {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                        
                    } else {
                        // If not, just dismiss!
                        presentationMode.wrappedValue.dismiss()
                    }
                })
            }) {
                if uploadPost.status != .inProgress || (uploadPost.status == .inProgress && uploadingDraft) {
                    Text("Submit!")
                        .dynamicFont(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .modifier(RectangleWrapper(fixedHeight: 55, color: .accentColor))
                } else {
                    ProgressView()
                        .padding(.horizontal)
                        .modifier(RectangleWrapper(fixedHeight: 55, color: .gray.opacity(0.25)))
                }
            }
            .disabled(!withinCharacterLimits || currentUser.getLocation(locationManager) == nil)
            
            Button(action: {
                // Transport the draft!
                uploadingDraft = true
                var newDraft = Draft(text: enteredText, dateCreated: Date())
                if let draftID = draftID { newDraft.UUID = draftID }
                newDraft.transportToServer(path: usersCollection.document(currentUser.UUID).collection("drafts"),
                                           documentID: newDraft.UUID,
                                           operation: $uploadPost,
                                           onError: { error in uploadPost.setError(message: error.localizedDescription); uploadingDraft = false },
                                           onSuccess: { presentationMode.wrappedValue.dismiss() })
            }) {
                if uploadPost.status != .inProgress || (uploadPost.status == .inProgress && !uploadingDraft) {
                    Text("Save Draft")
                        .dynamicFont(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                        .modifier(RectangleWrapper(fixedHeight: 55, color: .gray.opacity(0.15)))
                } else {
                    ProgressView()
                        .padding(.horizontal)
                        .modifier(RectangleWrapper(fixedHeight: 55, color: .gray.opacity(0.25)))
                }
            }
            .disabled(!withinCharacterLimits || uploadPost.status == .inProgress)
        }
        .padding([.bottom, .horizontal])
        
        .alert(isPresented: $uploadPost.isShowingErrorMessage) {
            Alert(title: Text("Couldn't Create Post"),
                  message: Text(uploadPost.errorMessage),
                  dismissButton: .default(Text("Close")))
        }
        
        .onAppear {
            // MARK: View Launch Code
            focusedField = "editor"
            
            // Set up a real-time listener for the user's profile!
            usersCollection.document(currentUser.UUID).addSnapshotListener({ snapshot, error in
                if let snapshot = snapshot {
                    if let snapshotData = snapshot.data() { currentUser.replaceFields(User.dedictify(snapshotData)) }
                }
            })
        }
    }
    
    // MARK: View Functions
    // Functions go here! :)
}

// MARK: View Preview
struct NewPostView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            NewPostView(locationManager: LocationManager())
        }
    }
}

// MARK: Support Views
// Support views go here! :)
