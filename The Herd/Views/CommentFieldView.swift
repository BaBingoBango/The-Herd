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
    var comment: String?
    var commenterIcon: String?
    var commenterColor: Color?
    @FocusState var focusedField: String?
    
    // MARK: View Body
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                if let comment = comment, let commenterIcon = commenterIcon, let commenterColor = commenterColor {
                    HStack {
                        ZStack {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 37.5))
                                .foregroundColor(commenterColor)

                            Text(commenterIcon)
                                .font(.system(size: 25))
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Replying To Comment")
                                .dynamicFont(.callout, padding: 0)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                            
                            Text(comment)
                                .dynamicFont(.headline, lineLimit: 10, padding: 0)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(10)
                    .modifier(RectangleWrapper(color: commenterColor, opacity: 0.1, enforceLayoutPriority: true))
                    .padding(.horizontal)
                }
                
                ZStack {
                    VStack {
                        HStack {
                            Text("Write your comment here!")
                                .dynamicFont(.title2, lineLimit: 2, padding: 0)
                                .fontWeight(.bold)
                                .padding([.leading, .top], 10)
                            
                            Spacer()
                        }
                        
                        Spacer()
                    }
                    
                    TextEditor(text: $enteredComment)
                        .dynamicFont(.title2, padding: 5)
                        .fontWeight(.bold)
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
                                                  commentLevel: 1,
                                                  comments: [],
                                                  timePosted: Date(),
                                                  latitude: currentUser.getLocation(locationManager)!.0,
                                                  longitude: currentUser.getLocation(locationManager)!.1)
                            
                            postsCollection.document(post.UUID).updateData([
                                "comments" : (post.comments + [newComment]).map({ $0.dictify() })
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
        CommentFieldView(post: .constant(Post.getSamples().randomElement()!), locationManager: LocationManager(), comment: "Yo yo (yo yo) don't reply to this! You're sad (you're sad) can't cry to this!", commenterIcon: "🛰️", commenterColor: .cyan)
    }
}

// MARK: Support Views
// Support views go here! :)
