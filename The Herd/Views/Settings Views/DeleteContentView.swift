//
//  DeleteContentView.swift
//  The Herd
//
//  Created by Ethan Marshall on 8/21/23.
//

import SwiftUI

/// An app view written in SwiftUI!
struct DeleteContentView: View {
    
    // MARK: View Variables
    @ObservedObject var currentUser: User
    @State var deletePosts = false
    @State var deleteComments = false
    @State var deleteContent = Operation()
    @State var successMessage = "Deletion Complete"
    var buttonDisabled: Bool {
        deleteContent.status == .inProgress || deleteContent.status == .success
    }
    
    // MARK: View Body
    var body: some View {
        VStack {
            Image(systemName: "trash.fill")
                .font(.system(size: 40))
                .foregroundColor(.red)
                .padding(.top)
            
            Text("Delete Your Posts And Comments")
                .dynamicFont(.title, lineLimit: 5)
                .multilineTextAlignment(.center)
                .fontWeight(.bold)
                .padding(.top, 5)
                .padding(.bottom)
            
            InformationalRowView(iconName: "xmark.square.fill", text: "Use this tool to delete posts and comments you've created from The Herd servers.")
                .padding(.bottom)
            
            InformationalRowView(iconName: "hand.thumbsup.fill", text: "Your total Thumbs-Up and post counts will be affected by the removal of content.")
                .padding(.bottom)
            
            InformationalRowView(iconName: "ellipsis.bubble.fill", text: "Post and comment replies under content you delete will also be removed.")
                .padding(.bottom)
            
            Spacer()
            
            VStack {
                Button(action: {
                    deleteContent.status = .notStarted
                    deletePosts.toggle()
                    if deletePosts { deleteComments = false }
                }) {
                    HStack {
                        Text("Delete Posts")
                            .dynamicFont(.title3, padding: 0)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if deletePosts {
                            Image(systemName: "checkmark.circle.fill")
                                .dynamicFont(.title3, padding: 0)
                                .foregroundColor(.red)
                        } else {
                            Image(systemName: "circle")
                                .dynamicFont(.title3, padding: 0)
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding(.bottom)
                
                Button(action: {
                    deleteContent.status = .notStarted
                    deleteComments.toggle()
                    if deleteComments { deletePosts = false }
                }) {
                    HStack {
                        Text("Delete Comments")
                            .dynamicFont(.title3, padding: 0)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if deleteComments {
                            Image(systemName: "checkmark.circle.fill")
                                .dynamicFont(.title3, padding: 0)
                                .foregroundColor(.red)
                        } else {
                            Image(systemName: "circle")
                                .dynamicFont(.title3, padding: 0)
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding(.bottom)
            }
            
            ZStack {
                Button(action: {
                    deleteUserContent()
                }) {
                    Text(deleteContent.status == .inProgress ? "" : (deleteContent.status == .success ? successMessage : "Confirm Deletion"))
                        .dynamicFont(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .modifier(RectangleWrapper(fixedHeight: 55, color: (!deletePosts && !deleteComments) || buttonDisabled ? .gray.opacity(0.2) : .red, opacity: 1))
                }
                .disabled(!deletePosts && !deleteComments)
                .alert(isPresented: $deleteContent.isShowingErrorMessage) {
                    Alert(title: Text("Couldn't Delete Content"),
                          message: Text(deleteContent.errorMessage),
                          dismissButton: .default(Text("Close")))
                }
                
                if deleteContent.status == .inProgress {
                    ProgressView()
                }
            }
            .padding(.bottom)
        }
        .padding(.horizontal)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Delete Content")
        .navigationBarBackButtonHidden(deleteContent.status == .inProgress)
        .interactiveDismissDisabled(deleteContent.status == .inProgress)
    }
    
    // MARK: View Functions
    func deleteUserContent() {
        deleteContent.status = .inProgress
        
        if deletePosts {
            var postsDeleted = 0
            postsCollection.whereField("authorUUID", isEqualTo: currentUser.UUID).getDocuments { snapshots, error in
                if let error = error {
                    deleteContent.setError(message: error.localizedDescription); return
                } else {
                    for eachDocument in snapshots!.documents {
                        eachDocument.reference.delete { err in
                            if let err = err {
                                deleteContent.setError(message: err.localizedDescription); return
                            } else {
                                postsDeleted += 1
                                print("\(postsDeleted) posts deleted!")
                                if postsDeleted == snapshots!.count {
                                    deleteContent.status = .success
                                    successMessage = "\(postsDeleted) Post\(postsDeleted == 1 ? "" : "s") Deleted"
                                }
                            }
                        }
                    }
                    if snapshots!.documents.isEmpty {
                        deleteContent.status = .success
                        successMessage = "0 Posts Deleted"
                    }
                }
            }
        } else if deleteComments {
            var commentsDeleted = 0
            postsCollection.whereFilter(.orFilter([
                .whereField("associatedUserIDs", arrayContains: currentUser.UUID),
                .whereField("authorUUID", isEqualTo: currentUser.UUID)
            ])).getDocuments { snapshots, error in
                
                if let error = error {
                    deleteContent.setError(message: error.localizedDescription); return
                } else {
                    let commentsToDelete = snapshots!.documents
                    .map({ Post.dedictify($0.data()) })
                    .reduce(0) { (sum, post) -> Int in
                        return sum + post.countComments(currentUser.UUID)
                    }

                    for eachDocument in snapshots!.documents.filter({ Post.dedictify($0.data()).isUserCommenter(currentUser.UUID) }) {
                        let post = Post.dedictify(eachDocument.data())
                        
                        eachDocument.reference.updateData([
                            "comments" : post.removeUserComments(currentUser.UUID).map({ $0.dictify() })
                        ]) { err in
                            if let err = err {
                                deleteContent.setError(message: err.localizedDescription); return
                            } else {
                                commentsDeleted += post.countComments(currentUser.UUID)
                                if commentsDeleted == commentsToDelete {
                                    deleteContent.status = .success
                                    successMessage = "\(commentsDeleted) Comment\(commentsDeleted == 1 ? "" : "s") Deleted"
                                }
                            }
                        }
                    }
                    if snapshots!.documents.filter({ Post.dedictify($0.data()).isUserCommenter(currentUser.UUID) }).isEmpty {
                        deleteContent.status = .success
                        successMessage = "0 Comments Deleted"
                    }
                }
            }
        }
    }
}

// MARK: View Preview
struct DeleteContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DeleteContentView(currentUser: .getSample())
        }
    }
}

// MARK: Support Views
// Support views go here! :)
