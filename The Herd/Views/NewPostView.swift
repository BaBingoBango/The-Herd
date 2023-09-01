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
    @State var enteredMentions: [ChatMember] = []
    @State var showingRolodex = false
    @FocusState var focusedField: String?
    @State var uploadPost = Operation()
    @State var uploadingDraft = false
    @ObservedObject var currentUser: User = .getSample()
    var locationManager: LocationManager
    var repost: Post?
    @Binding var newlyCreatedPost: Post
    
    var withinCharacterLimits: Bool {
        return enteredText.count >= 1 && enteredText.count <= 250
    }
    
    // MARK: View Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
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
                
                if let repost = repost {
                    HStack {
                        ZStack {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(repost.getAnonymousNumber(repost.authorUUID) != nil ? .gray : repost.authorColor)

                            Text(repost.getAnonymousNumber(repost.authorUUID) ?? repost.authorEmoji)
                                .font(.system(size: 12.5))
                                .fontDesign(.monospaced)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Reposting")
                                .dynamicFont(.callout, padding: 0)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                            
                            Text(repost.text)
                                .dynamicFont(.headline, lineLimit: 15, padding: 0)
                                .multilineTextAlignment(.leading)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(10)
                    .modifier(RectangleWrapper(color: repost.getAnonymousNumber(repost.authorUUID) != nil ? .gray : repost.authorColor, opacity: 0.1, enforceLayoutPriority: true))
                }
                
                ScrollView(.horizontal) {
                    HStack {
                        Button(action: {
                            showingRolodex = true
                        }) {
                            Text("@ +")
                                .dynamicFont(.title2, fontDesign: .rounded, padding: 10)
                                .fontWeight(.heavy)
                                .foregroundColor(.secondary)
                                .padding(.vertical, 5)
                                .modifier(RectangleWrapper(fixedHeight: 35, color: .gray, opacity: 0.15, cornerRadius: 15, enforceLayoutPriority: true))
                        }
                        .sheet(isPresented: $showingRolodex) {
                            AddressBookView(currentUser: currentUser, pickerMode: true, mentions: $enteredMentions, excludedUserIDs: enteredMentions.map({ $0.userID }), newlyCreatedPost: $newlyCreatedPost)
                        }
                        
                        ForEach(enteredMentions, id: \.UUID) { eachMention in
                            Button(action: {
                                enteredMentions.removeAll(where: { $0.UUID == eachMention.UUID })
                            }) {
                                Text("@ \(eachMention.emoji)")
                                    .dynamicFont(.title2, fontDesign: .rounded, padding: 10)
                                    .fontWeight(.heavy)
                                    .foregroundColor(eachMention.color)
                                    .padding(.vertical, 5)
                                    .modifier(RectangleWrapper(fixedHeight: 35, color: eachMention.color, opacity: 0.15, cornerRadius: 15, enforceLayoutPriority: true))
                            }
                        }
                    }
                }
                
                ZStack {
                    // Background color view
                    (colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
                        .frame(height: 300)
                        .cornerRadius(10)
                    
                    TextEditor(text: $enteredText)
                        .dynamicFont(.title2, fontDesign: currentUser.fontPreference.toFontDesign(), padding: 0)
                        .fontWeight(.bold)
                        .foregroundColor(currentUser.useRainbowKeyboard ? Color.calculateRatioColor(count: enteredText.count, maximum: 250) : .primary)
                        .opacity(1)
                        .focused($focusedField, equals: "editor")
                        .overlay(
                            VStack {
                                HStack {
                                    if enteredText.isEmpty {
                                        Text("Write your post here!")
                                            .dynamicFont(.title2, fontDesign: currentUser.fontPreference.toFontDesign(), lineLimit: 2, padding: 0)
                                            .fontWeight(.bold)
                                            .padding([.leading, .top], 6)
                                            .foregroundColor(Color.gray.opacity(0.5))
                                    }
                                    Spacer()
                                }
                                Spacer()
                            }
                        )
                        .background(Color.clear) // Clear background for TextEditor
                }
                .padding()
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
                    
                    Text("Only you'll be able to delete your post, but anyone can save it.")
                        .font(.callout)
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
                                   longitude: currentUser.getLocation(locationManager)!.1,
                                   mentions: enteredMentions,
                                   repost: repost != nil ? [repost!] : [])
                
                // Transport the new post!
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
                        newlyCreatedPost = newPost
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
                var newDraft = Draft(text: enteredText, dateCreated: Date(), userUUID: currentUser.UUID, repost: { if let repost = repost { return [repost] } else { return [] } }(), mentions: enteredMentions)
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
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Text("\(250 - enteredText.count)")
                    .dynamicFont(.body, fontDesign: .monospaced, padding: 0)
                    .fontWeight(.bold)
                    .foregroundColor(Color.calculateRatioColor(count: enteredText.count, maximum: 250))
            }
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
        NavigationView {
            VStack {
                NewPostView(locationManager: LocationManager(), newlyCreatedPost: .constant(.sample))
            }
        }
    }
}

// MARK: Support Views
// Support views go here! :)
