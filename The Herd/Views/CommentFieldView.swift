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
    @State var enteredComment = ""
    @State var addComment = Operation()
    @Binding var post: Post
    @ObservedObject var currentUser: User = .getSample()
    var locationManager: LocationManager
    var parentPost: Post?
    @FocusState var focusedField: String?
    
    // MARK: View Body
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack {
                    ZStack {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 37.5))
                            .foregroundColor(post.authorColor)

                        Text(post.authorEmoji)
                            .font(.system(size: 25))
                    }
                    
                    VStack(alignment: .leading) {
                        Text(post.commentLevel == 0 ? "Replying To Post" : "Replying To Comment")
                            .dynamicFont(.callout, padding: 0)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        
                        Text(post.text)
                            .dynamicFont(.headline, lineLimit: 10, padding: 0)
                            .multilineTextAlignment(.leading)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                }
                .padding(10)
                .modifier(RectangleWrapper(color: post.authorColor, opacity: 0.1, enforceLayoutPriority: true))
                .padding(.horizontal)
                
                ZStack {
                    VStack {
                        HStack {
                            Text("Write your comment here!")
                                .dynamicFont(.title2, lineLimit: 2, padding: 0)
                                .foregroundColor(.primary)
                                .fontWeight(.bold)
                                .padding([.leading, .top], 10)
                            
                            Spacer()
                        }
                        
                        Spacer()
                    }
                    
                    TextEditor(text: $enteredComment)
                        .dynamicFont(.title2, padding: 5)
                        .fontWeight(.bold)
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
            .alert(isPresented: $addComment.isShowingErrorMessage) {
                Alert(title: Text("Couldn't Post Comment"),
                      message: Text(addComment.errorMessage),
                      dismissButton: .default(Text("Close")))
            }
            
            .navigationTitle("Add Comment")
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
                                                  longitude: 0)
                            
                            // TODO: if the parent post has a comment level of 1, search the parent (needs to be passed in) for the original comment - then, attach the reply and reupload!
                            
                            var newCommentsArray = post.commentLevel == 0 ? post.comments : parentPost!.comments
                            if post.commentLevel == 0 {
                                newCommentsArray += [newComment]
                                
                            } else if post.commentLevel == 1 {
                                newCommentsArray[newCommentsArray.firstIndex(where: { $0.UUID == post.UUID })!].comments.append(newComment)
                                
                            } else {
                                addComment.setError(message: "You cannot reply to a comment that is already a reply to another comment.")
                                return
                            }
                            
                            postsCollection.document(post.commentLevel == 0 ? post.UUID : parentPost!.UUID).updateData([
                                "comments" : newCommentsArray.map({ $0.dictify() })
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
                        .disabled(enteredComment.isEmpty)
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
        CommentFieldView(post: .constant(Post.getSamples().randomElement()!), locationManager: LocationManager())
    }
}

// MARK: Support Views
// Support views go here! :)
