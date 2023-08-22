//
//  CommentFieldView.swift
//  The Herd
//
//  Created by Ethan Marshall on 6/15/23.
//

import SwiftUI

/// An app view written in SwiftUI!
struct CommentFieldView: View {
    
    // MARK: View Variables
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("postingAnonymously") var postingAnonymously = false
    var commentingAnonymously: Bool
    var modeSwitchingDisabled: Bool {
        if parentPost!.anonymousIdentifierTable.contains(where: { $0.key == currentUser.UUID }) { return true }
        if parentPost!.authorUUID == currentUser.UUID { return true }
        for eachComment in parentPost!.comments {
            if eachComment.authorUUID == currentUser.UUID { return true }
            for eachSecondLevelComment in eachComment.comments {
                if eachSecondLevelComment.authorUUID == currentUser.UUID { return true }
            }
        }
        return false
    }
    @State var enteredComment = ""
    @State var addComment = Operation()
    @Binding var post: Post
    @ObservedObject var currentUser: User = .getSample()
    var locationManager: LocationManager
    var parentPost: Post?
    @FocusState var focusedField: String?
    var withinCharacterLimits: Bool {
        return enteredComment.count >= 1 && enteredComment.count <= 250
    }
    
    // MARK: View Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    Button(action: {
                        postingAnonymously.toggle()
                    }) {
                        HStack(spacing: 10) {
                            ZStack {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.clear)

                                Text(commentingAnonymously ? "🕶️" : currentUser.emoji)
                                    .font(.system(size: 20))
                            }
                            
                            VStack(alignment: .leading, spacing: 0) {
                                Text(commentingAnonymously ? "Posting Anonymously" : "Posting With Emoji")
                                    .dynamicFont(.callout, padding: 0)
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(.primary)
                                
                                if !modeSwitchingDisabled {
                                    HStack(spacing: 5) {
                                        Text(commentingAnonymously ? "Use Emoji" : "Go Anonymous")
                                            .dynamicFont(.callout, padding: 0)
                                            .fontWeight(.bold)
                                            .foregroundColor(.blue)
                                            .multilineTextAlignment(.leading)
                                        
                                        Image(systemName: "chevron.right")
                                            .dynamicFont(.callout, padding: 0)
                                            .fontWeight(.bold)
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(10)
                        .modifier(RectangleWrapper(color: commentingAnonymously ? .gray : currentUser.color, opacity: 0.1))
                    }
                    .padding(.horizontal)
                    .disabled(modeSwitchingDisabled)
                    
                    HStack {
                        ZStack {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(parentPost!.getAnonymousNumber(post.authorUUID) != nil ? .gray : post.authorColor)

                            Text(parentPost!.getAnonymousNumber(post.authorUUID) ?? post.authorEmoji)
                                .font(.system(size: 12.5))
                                .fontDesign(.monospaced)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading) {
                            Text(post.commentLevel == 0 ? "Replying To Post" : "Replying To Comment")
                                .dynamicFont(.callout, padding: 0)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                            
                            Text(post.text)
                                .dynamicFont(.headline, lineLimit: 15, padding: 0)
                                .multilineTextAlignment(.leading)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(10)
                    .modifier(RectangleWrapper(color: parentPost!.getAnonymousNumber(post.authorUUID) != nil ? .gray : post.authorColor, opacity: 0.1, enforceLayoutPriority: true))
                    .padding(.horizontal)
                    
                    ZStack {
                        VStack {
                            HStack {
                                Text("Write your comment here!")
                                    .dynamicFont(.title2, fontDesign: currentUser.fontPreference.toFontDesign(), lineLimit: 2, padding: 0)
                                    .foregroundColor(.primary)
                                    .fontWeight(.bold)
                                    .padding([.leading, .top], 10)
                                
                                Spacer()
                            }
                            
                            Spacer()
                        }
                        
                        TextEditor(text: $enteredComment)
                            .dynamicFont(.title2, fontDesign: currentUser.fontPreference.toFontDesign(), padding: 5)
                            .fontWeight(.bold)
                            .foregroundColor(Color.calculateRatioColor(count: enteredComment.count, maximum: 250))
                            .multilineTextAlignment(.leading)
                            .opacity(enteredComment.isEmpty ? 0.5 : 1)
                            .focused($focusedField, equals: "editor")
                    }
                    .background(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.white)
                    .frame(height: 225)
                    .cornerRadius(10)
                    .shadow(color: .gray.opacity(0.3), radius: 10)
                    .padding([.horizontal, .bottom])
                    
                    Spacer()
                }
            }
            .alert(isPresented: $addComment.isShowingErrorMessage) {
                Alert(title: Text("Couldn't Post Comment"),
                      message: Text(addComment.errorMessage),
                      dismissButton: .default(Text("Close")))
            }
            
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel")
                            .fontWeight(.bold)
                    }
                    .disabled(addComment.status == .inProgress)
                }
                
                ToolbarItem(placement: .principal) {
                    Text("\(250 - enteredComment.count)")
                        .dynamicFont(.body, fontDesign: .monospaced, padding: 0)
                        .fontWeight(.bold)
                        .foregroundColor(Color.calculateRatioColor(count: enteredComment.count, maximum: 250))
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    if addComment.status == .inProgress {
                        ProgressView()
                        
                    } else {
                        Button(action: {
                            addComment.status = .inProgress
                            
                            let newComment = Post(authorUUID: currentUser.UUID,
                                                  authorEmoji: currentUser.emoji,
                                                  authorColor: currentUser.color,
                                                  text: enteredComment,
                                                  votes: [currentUser.UUID : .init(voterUUID: currentUser.UUID, value: 1, timePosted: Date())],
                                                  commentLevel: post.commentLevel + 1,
                                                  comments: [],
                                                  timePosted: Date(),
                                                  latitude: 0,
                                                  longitude: 0,
                                                  mentions: [])
                            
                            var newCommentsArray = post.commentLevel == 0 ? post.comments : parentPost!.comments
                            if post.commentLevel == 0 {
                                newCommentsArray += [newComment]
                                
                            } else if post.commentLevel == 1 {
                                newCommentsArray[newCommentsArray.firstIndex(where: { $0.UUID == post.UUID })!].comments.append(newComment)
                                
                            } else {
                                addComment.setError(message: "You cannot reply to a comment that is already a reply to another comment.")
                                return
                            }
                            
                            var newAnonTable = parentPost!.anonymousIdentifierTable
                            if commentingAnonymously && parentPost!.getAnonymousNumber(currentUser.UUID) == nil {
                                newAnonTable[currentUser.UUID] = parentPost!.anonymousIdentifierTable[parentPost!.authorUUID] != nil ? newAnonTable.count : newAnonTable.count + 1
                            }
                            var newAssociationList = parentPost!.associatedUserIDs
                            newAssociationList.append(currentUser.UUID)
                            
                            postsCollection.document(post.commentLevel == 0 ? post.UUID : parentPost!.UUID).updateData([
                                "comments" : newCommentsArray.map({ $0.dictify() }),
                                "anonymousIdentifierTable" : newAnonTable,
                                "associatedUserIDs" : newAssociationList
                                
                            ]) { error in
                                if let error = error {
                                    addComment.setError(message: error.localizedDescription)
                                } else {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                            
                        }) {
                            Text("Post!")
                                .fontWeight(.bold)
                        }
                        .disabled(!withinCharacterLimits)
                    }
                }
            })
        }
        .interactiveDismissDisabled(addComment.status == .inProgress)
        .onAppear {
            // MARK: View Launch Code
            focusedField = "editor"
        }
    }
    
    // MARK: View Functions
    // Functions go here! :)
}

// MARK: View Preview
struct CommentFieldView_Previews: PreviewProvider {
    static var previews: some View {
        CommentFieldView(commentingAnonymously: false, post: .constant(Post.getSamples().randomElement()!), locationManager: LocationManager(), parentPost: Post.sample)
    }
}

// MARK: Support Views
// Support views go here! :)
