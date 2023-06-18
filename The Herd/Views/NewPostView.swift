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
    @State var showingDrafts = 1
    @State var getDrafts = Operation()
    @State var userDrafts: [Draft] = []
    @State var uploadPost = Operation()
    @State var uploadingDraft = false
    @ObservedObject var currentUser: User = .getSample()
    var locationManager: LocationManager
    
    var withinCharacterLimits: Bool {
        return enteredText.count >= 1 && enteredText.count <= 500
    }
    
    // MARK: View Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Picker(selection: $showingDrafts, label: Text("")) {
                        Text("New Post").tag(0)
                        Text("From Drafts").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Text(showingDrafts == 0 ? "New post time?" : "Drafts")
                        .dynamicFont(.largeTitle, lineLimit: 2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    if showingDrafts == 0 {
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
                }
                .padding(.horizontal)
            }
            
            if showingDrafts == 0 {
                HStack {
                    Button(action: {
                        // Check if the current user is loaded in!
                        uploadPost.status = .inProgress
                        
                        // Create the new Post object!
                        let newPost = Post(author: currentUser,
                                           text: enteredText,
                                           votes: [currentUser.UUID : .init(voter: currentUser, value: 1, timePosted: Date())],
                                           comments: [],
                                           timePosted: Date(),
                                           latitude: currentUser.getLocation(locationManager)!.0,
                                           longitude: currentUser.getLocation(locationManager)!.1)
                        
                        // Transport the new post!
                        newPost.transportToServer(path: postsCollection,
                                                  documentID: newPost.UUID,
                                                  operation: $uploadPost,
                                                  onError: { error in uploadPost.setError(message: error.localizedDescription) },
                                                  onSuccess: { presentationMode.wrappedValue.dismiss() })
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
                        let newDraft = Draft(text: enteredText, dateCreated: Date())
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
                
                // MARK: Navigation Settings (New Post)
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
                
            } else {
                Group {
                    if getDrafts.status != .success {
                        ProgressView()
                            .controlSize(.large)
                            .padding(.top, 30)
                        
                    } else {
                        ForEach(userDrafts, id: \.UUID) { eachDraft in
                            Button(action: {}) {
                                Text(eachDraft.text)
                                    .dynamicFont(.title2, lineLimit: 100, padding: 0)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)
                                    .padding(.bottom, 15)
                                    .padding(20)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                
                // MARK: Navigation Settings (Drafts)
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
        }
        .alert(isPresented: $uploadPost.isShowingErrorMessage) {
            Alert(title: Text("Couldn't Create Post"),
                  message: Text(uploadPost.errorMessage),
                  dismissButton: .default(Text("Close")))
        }
        .onAppear {
            // MARK: View Launch Code
            // Set up a real-time listener for the user's profile!
            usersCollection.document(currentUser.UUID).addSnapshotListener({ snapshot, error in
                if let snapshot = snapshot {
                    if let snapshotData = snapshot.data() { currentUser.replaceFields(User.dedictify(snapshotData)) }
                }
            })
            
            // Set up a real-time listener for the user's drafts!
            usersCollection.document(currentUser.UUID).collection("drafts").addSnapshotListener({ snapshots, error in
                if let snapshots = snapshots {
                    userDrafts = snapshots.documents.map { Draft.dedictify($0.data()) }
                    getDrafts.status = .success
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
        NewPostView(userDrafts: [
            .init(text: "yo yo yo yo yo yo yoy yo yo ", dateCreated: Date()),
            .init(text: "ALLL ALLLLL ALLLLL TOOOO WELLLLL", dateCreated: Date())
        ], locationManager: LocationManager())
    }
}

// MARK: Support Views
// Support views go here! :)
