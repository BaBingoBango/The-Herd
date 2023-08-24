//
//  PostOptionView.swift
//  The Herd
//
//  Created by Ethan Marshall on 6/3/23.
//

import SwiftUI

/// An app view written in SwiftUI!
struct PostOptionView: View {
    
    // MARK: View Variables
    @Binding var post: Post
    var activateNavigation = false
    @State var showingPostDetail = false
    var currentUser = User.getSample()
    var locationManager = LocationManager()
    var showTopBar = true
    var showText = true
    var seperateControls = true
    var cornerRadius = 20.0
    var bottomBarFont: Font = .headline
    var blockRecursion = false
    var parentPost: Post?
    @State var deletePost = Operation()
    @State var savePost = Operation()
    @State var isPostSaved = false
    @State var showingCommentField = false
    @State var commentFieldDetent = PresentationDetent.large
    var voteValue: Int {
        post.votes[currentUser.UUID]?.value ?? 0
    }
    var hasUserCommented: Bool {
        Post.hasUserCommented(post.comments, userUUID: currentUser.UUID)
    }
    @AppStorage("postingAnonymously") var postingAnonymously = false
    @State var rolodexUser = Operation()
    @State var isUserInRolodex = false
    @Binding var newlyCreatedPost: Post
    @State private var refreshView = false
    @State var blockUser = Operation()
    @State var isUserBlocked = false
    
    // MARK: View Body
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if showTopBar {
                HStack {
                    ZStack {
                        Circle()
                            .foregroundColor(parentPost!.getAnonymousNumber(post.authorUUID) != nil ? .gray : post.authorColor)
                            .frame(width: 40, height: 40)

                        Text(parentPost!.getAnonymousNumber(post.authorUUID) ?? post.authorEmoji)
                            .aspectRatio(contentMode: .fit)
                            .fontDesign(.monospaced)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .offset(y: -12.5)
                    
                    Text("\(post.distanceFromNow) · \(post.calculateDistanceFromLocation(latitude: currentUser.getLocation(locationManager)!.0, longitude: currentUser.getLocation(locationManager)!.1)) away")
                        .dynamicFont(.callout, padding: 0)
                        .fontWeight(.heavy)
                        .foregroundColor(.secondary)
                        .offset(y: -4.5)
                    
                    Spacer()
                    
                    if !blockRecursion {
                        PostMenuButton(post: $post, currentUser: currentUser, locationManager: locationManager, deletePost: $deletePost, savePost: $savePost, isPostSaved: $isPostSaved, rolodexUser: $rolodexUser, isUserInRolodex: $isUserInRolodex, newlyCreatedPost: $newlyCreatedPost, blockUser: $blockUser, isUserBlocked: $isUserBlocked)
                            .onAppear {
                                postsCollection.document(post.UUID).collection("saved").document(currentUser.UUID).getDocument() { snapshot, error in
                                    if error != nil {
                                        return
                                    } else if let snapshot = snapshot {
                                        if snapshot.exists {
                                            isPostSaved = true
                                        }
                                    }
                                }
                                isUserInRolodex = currentUser.addresses[post.authorUUID] != nil
                                isUserBlocked = currentUser.blockedUserIDs.contains(post.authorUUID)
                            }
                    }
                }
                .padding(.horizontal)
                
                Divider()
                    .offset(y: -8)
            }
            
            NavigationLink(destination: PostDetailView(post: $post, currentUser: currentUser, locationManager: locationManager, commentingAnonymously: commentingAnonymously(), newlyCreatedPost: $newlyCreatedPost), isActive: $showingPostDetail) { EmptyView() }
                .id(UUID())
            
            switch deletePost.status {
            case .inProgress:
                HStack {
                    Spacer()
                    
                    VStack(spacing: 7.5) {
                        ProgressView()
                            .controlSize(.large)
                        
                        Text("Deleting...")
                            .dynamicFont(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
            case .success:
                HStack {
                    Spacer()
                    
                    VStack(spacing: 7.5) {
                        Image(systemName: "trash")
                            .font(.system(size: 25))
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        
                        Text("Post Deleted")
                            .dynamicFont(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
            default:
                Button(action: {
                    if activateNavigation { showingPostDetail = true }
                }) {
                    VStack(alignment: .leading, spacing: 0) {
                        if showText {
                            VStack(alignment: .leading, spacing: 0) {
                                VStack(alignment: .leading) {
                                    ForEach(post.mentions.chunked(into: showTopBar ? 4 : 5).indices, id: \.self) { index in
                                        let row = post.mentions.chunked(into: showTopBar ? 4 : 5)[index]
                                        HStack {
                                            ForEach(row, id: \.UUID) { eachMention in
                                                Text("@ \(eachMention.emoji)")
                                                    .dynamicFont(.title3, fontDesign: .rounded, padding: 0)
                                                    .padding(.horizontal, 10)
                                                    .fontWeight(.heavy)
                                                    .foregroundColor(eachMention.color)
                                                    .modifier(RectangleWrapper(fixedHeight: 35, color: eachMention.color, opacity: 0.15, cornerRadius: 15, enforceLayoutPriority: true))
                                                    .padding(.top, 5)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.top, showTopBar ? 5 : 12.5)
                                
                                Text(post.text)
                                    .dynamicFont(post.text.count <= 5 ? .largeTitle : .title2, fontDesign: currentUser.fontPreference.toFontDesign(), lineLimit: 100, padding: 0)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)
                                    .padding(.bottom, 10)
                                    .padding(.top, showTopBar ? 0 : 10)
                                    .padding(.horizontal)
                                
                                if let repost = post.repost.first {
                                    NavigationLink(destination: PostDetailView(post: $post.repost.first!, currentUser: currentUser, locationManager: locationManager, commentingAnonymously: commentingAnonymously(true), newlyCreatedPost: $newlyCreatedPost)) {
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
                                            
                                            HStack {
                                                Text(repost.text)
                                                    .dynamicFont(.body, lineLimit: 15, padding: 0)
                                                    .multilineTextAlignment(.leading)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.primary)
                                                
                                                Spacer()
                                            }
                                        }
                                        .padding(10)
                                        .modifier(RectangleWrapper(color: repost.getAnonymousNumber(repost.authorUUID) != nil ? .gray : repost.authorColor, opacity: 0.1, enforceLayoutPriority: true))
                                        .padding([.horizontal, .bottom])
                                    }
                                    .id(UUID())
                                }
                            }
                        }
                        
                        HStack {
                            if post.commentLevel != 2 {
                                Button(action: {
                                    showingCommentField = true
                                }) {
                                    HStack(spacing: 7.5) {
                                        Image(systemName: hasUserCommented ? "bubble.left.fill" : "bubble.left")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 20)
                                            .foregroundColor(hasUserCommented ? (parentPost!.getAnonymousNumber(post.authorUUID) != nil ? .gray : post.authorColor): .secondary)
                                        
                                        Text(post.commentLevel == 0 ? "\(Post.countComments(post.comments))" : "Reply")
                                            .dynamicFont(bottomBarFont, padding: 0)
                                            .fontWeight(.semibold)
                                            .foregroundColor(hasUserCommented ? (parentPost!.getAnonymousNumber(post.authorUUID) != nil ? .gray : post.authorColor): .secondary)
                                    }
                                    .padding(.trailing, seperateControls ? 0 : 15)
                                }
                                .sheet(isPresented: $showingCommentField) {
                                    CommentFieldView(commentingAnonymously: commentingAnonymously(), post: $post, currentUser: currentUser, locationManager: locationManager, parentPost: post.commentLevel == 0 ? post : parentPost)
                                        .presentationDetents([.medium, .large], selection: $commentFieldDetent)
                                }
                                
                                if seperateControls {
                                    Spacer()
                                }
                            }
                            
                            Button(action: {
                                changeVote(newValue: voteValue == 1 ? 0 : 1)
                            }) {
                                Image(systemName: voteValue == 1 ? "hand.thumbsup.fill" : "hand.thumbsup")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20)
                                    .fontWeight(.semibold)
                                    .foregroundColor(voteValue == 1 ? .green : .secondary)
                            }
                            
                            Text("\(post.score)")
                                .dynamicFont(bottomBarFont, padding: 0)
                                .fontWeight(.semibold)
                                .foregroundColor({
                                    switch voteValue {
                                    case 1: return .green
                                    case -1: return .red
                                    default: return .secondary
                                    }
                                }())
                            
                            Button(action: {
                                changeVote(newValue: voteValue == -1 ? 0 : -1)
                            }) {
                                Image(systemName: voteValue == -1 ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20)
                                    .fontWeight(.semibold)
                                    .foregroundColor(voteValue == -1 ? .red : .secondary)
                            }
                        }
                        .padding(.horizontal, seperateControls ? 15 : 5)
                    }
                }
            }
        }
        .padding(.bottom)
        .modifier(RectangleWrapper(color: post.authorColor, useGradient: true, opacity:  !blockRecursion ? 0.15 : 0.75, cornerRadius: cornerRadius, hideRectangle: !showText))
        .padding(.top, showTopBar ? 15 : 0)
    }
    
    // MARK: View Functions
    func commentingAnonymously(_ useRepost: Bool = false) -> Bool {
        if !useRepost {
            let hasSpokenAnonymously = parentPost!.anonymousIdentifierTable.contains(where: { $0.key == currentUser.UUID })
            if parentPost!.authorUUID == currentUser.UUID {
                return hasSpokenAnonymously
            } else {
                return hasSpokenAnonymously || postingAnonymously
            }
        } else {
            let hasSpokenAnonymously = post.repost.first!.anonymousIdentifierTable.contains(where: { $0.key == currentUser.UUID })
            if post.repost.first!.authorUUID == currentUser.UUID {
                return hasSpokenAnonymously
            } else {
                return hasSpokenAnonymously || postingAnonymously
            }
        }
    }
    func changeVote(newValue: Int) {
        let newVote = Vote(voterUUID: currentUser.UUID, value: newValue, timePosted: Date())
        var newVotesList = post.commentLevel == 0 ? post.votes : parentPost!.votes
        var newCommentsArray = post.commentLevel == 0 ? post.comments : parentPost!.comments
        
        if post.commentLevel == 0 {
            newVotesList[currentUser.UUID] = newVote
        } else if post.commentLevel == 1 {
            newCommentsArray[newCommentsArray.firstIndex(where: { $0.UUID == post.UUID })!].votes[currentUser.UUID] = newVote
        } else if post.commentLevel == 2 {
            for eachLevelOneCommentIndex in 0..<newCommentsArray.count {
                for eachLevelTwoCommentIndex in 0..<newCommentsArray[eachLevelOneCommentIndex].comments.count {
                    if newCommentsArray[eachLevelOneCommentIndex].comments[eachLevelTwoCommentIndex].UUID == post.UUID {
                        newCommentsArray[eachLevelOneCommentIndex].comments[eachLevelTwoCommentIndex].votes[currentUser.UUID] = newVote
                    }
                }
            }
        }
        
        postsCollection.document(parentPost?.UUID ?? post.UUID).updateData([
            "votes" : newVotesList.mapValues({ $0.dictify() }),
            "comments" : newCommentsArray.map({ $0.dictify() })
        ]) { error in
            if error == nil {
                DispatchQueue.main.async {
                    post.votes = newVotesList
                    if post.commentLevel == 0 {
                        post.votes = newVotesList
                    } else {
                        post.votes[currentUser.UUID] = newVote
                    }
                    self.refreshView.toggle()
                }
            }
        }
    }
}

// MARK: View Preview
struct PostOptionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ScrollView {
                PostOptionView(post: .constant(.sample), activateNavigation: true, blockRecursion: true, newlyCreatedPost: .constant(.sample))
                    .padding()
            }
        }
    }
}

// MARK: Support Views
struct PostMenuButton: View {
    
    @Binding var post: Post
    var currentUser: User
    var locationManager: LocationManager
    @Binding var deletePost: Operation
    @Binding var savePost: Operation
    @Binding var isPostSaved: Bool
    var makeBold = false
    @Binding var rolodexUser: Operation
    @Binding var isUserInRolodex: Bool
    @State var showingRepostView = false
    @Binding var newlyCreatedPost: Post
    @Binding var blockUser: Operation
    @Binding var isUserBlocked: Bool
    
    var body: some View {
        Menu {
            Button(action: {
                showingRepostView = true
            }) {
                Label("Repost...", systemImage: "arrowshape.turn.up.forward")
            }
            
            let viewCopy = PostOptionView(post: $post, currentUser: currentUser, locationManager: locationManager, blockRecursion: true, parentPost: post, newlyCreatedPost: .constant(.sample)).frame(width: 500)
            let viewImage = Image(uiImage: ImageRenderer(content: viewCopy).uiImage!)
            
            ShareLink(item: viewImage, preview: SharePreview(post.text, image: viewImage)) {
                Label("Share...", systemImage: "square.and.arrow.up")
            }
            
            if currentUser.UUID != post.authorUUID && post.getAnonymousNumber(post.authorUUID) == nil {
                Button(action: {
                    rolodexUser.status = .inProgress
                    
                    if !isUserInRolodex {
                        let newAddress = Address(userUUID: post.authorUUID,
                                                 userEmoji: post.authorEmoji,
                                                 userColor: post.authorColor,
                                                 nickname: "\(Address.defaultAdjectives.randomElement()!) \(Address.defaultNouns.randomElement()!)",
                                                 comment: "")
                        var newAddresses = currentUser.addresses
                        newAddresses[post.authorUUID] = newAddress
                        usersCollection.document(currentUser.UUID).updateData([
                            "addresses" : newAddresses.mapValues({ $0.dictify() })
                        ]) { error in
                            if let error = error {
                                rolodexUser.setError(message: error.localizedDescription)
                            } else {
                                isUserInRolodex = true
                                rolodexUser.status = .success
                            }
                        }
                        
                    } else {
                        var newAddresses = currentUser.addresses
                        newAddresses.removeValue(forKey: post.authorUUID)
                        usersCollection.document(currentUser.UUID).updateData([
                            "addresses" : newAddresses.mapValues({ $0.dictify() })
                        ]) { error in
                            if let error = error {
                                rolodexUser.setError(message: error.localizedDescription)
                            } else {
                                isUserInRolodex = false
                                rolodexUser.status = .success
                            }
                        }
                    }
                }) {
                    Label(!isUserInRolodex ? "Add User to Rolodex" : "Remove User from Rolodex", systemImage: !isUserInRolodex ? "person.crop.circle.badge.plus" : "person.crop.circle.badge.minus")
                }
            }
//            .alert(isPresented: $savePost.isShowingErrorMessage) {
//                Alert(title: Text("Couldn't Save Post"),
//                      message: Text(savePost.errorMessage),
//                      dismissButton: .default(Text("Close")))
//            }
            
            Button(action: {
                savePost.status = .inProgress
                
                if !isPostSaved {
                    let newSaveRecord = SavedPostRecord(userUUID: currentUser.UUID, postUUID: post.UUID, dateSaved: Date())
                    newSaveRecord.transportToServer(path: postsCollection.document(post.UUID).collection("saved"),
                                                    documentID: currentUser.UUID,
                                                    operation: nil,
                                                    onError: { error in savePost.setError(message: error.localizedDescription) },
                                                    onSuccess: { isPostSaved = true; savePost.status = .success })
                } else {
                    postsCollection.document(post.UUID).collection("saved").document(currentUser.UUID).delete() { error in
                        if let error = error {
                            savePost.setError(message: error.localizedDescription)
                        } else {
                            isPostSaved = false
                            savePost.status = .success
                        }
                    }
                }
                
            }) {
                Label(!isPostSaved ? "Save Post" : "Unsave Post", systemImage: !isPostSaved ? "bookmark" : "bookmark.slash.fill")
            }
            .alert(isPresented: $savePost.isShowingErrorMessage) {
                Alert(title: Text("Couldn't Save Post"),
                      message: Text(savePost.errorMessage),
                      dismissButton: .default(Text("Close")))
            }
            
            Divider()
            
            if currentUser.UUID == post.authorUUID {
                Button(role: .destructive, action: {
                    deletePost.status = .inProgress
                    
                    postsCollection.document(post.UUID).delete() { error in
                        if let error = error {
                            deletePost.setError(message: error.localizedDescription)
                        } else {
                            deletePost.status = .success
                        }
                    }
                }) {
                    Label("Delete Post", systemImage: "trash")
                }
                .alert(isPresented: $deletePost.isShowingErrorMessage) {
                    Alert(title: Text("Couldn't Delete Post"),
                          message: Text(deletePost.errorMessage),
                          dismissButton: .default(Text("Close")))
                }
            } else {
                Button(role: .destructive, action: {
                    blockUser.status = .inProgress
                    
                    if !isUserBlocked {
                        var newBlocks = currentUser.blockedUserIDs
                        newBlocks.append(post.authorUUID)
                        usersCollection.document(currentUser.UUID).updateData([
                            "blockedUserIDs" : newBlocks
                        ]) { error in
                            if let error = error {
                                blockUser.setError(message: error.localizedDescription)
                            } else {
                                isUserBlocked = true
                                blockUser.status = .success
                            }
                        }
                        
                    } else {
                        var newBlocks = currentUser.blockedUserIDs
                        newBlocks.removeAll(where: { $0 == post.authorUUID })
                        usersCollection.document(currentUser.UUID).updateData([
                            "blockedUserIDs" : newBlocks
                        ]) { error in
                            if let error = error {
                                blockUser.setError(message: error.localizedDescription)
                            } else {
                                isUserBlocked = false
                                blockUser.status = .success
                            }
                        }
                    }
                }) {
                    Label(!isUserBlocked ? "Block User" : "Unblock User", systemImage: !isUserBlocked ? "hand.raised.fill" : "hand.thumbsup.fill")
                }
            }
            
        } label: {
            Image(systemName: "ellipsis.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20)
                .fontWeight(makeBold ? .bold : .regular)
                .foregroundColor(makeBold ? .white : .secondary)
        }
        .offset(y: -5)
        .sheet(isPresented: $showingRepostView) {
            ManagePostsView(currentUser: currentUser, locationManager: locationManager, repost: post, newlyCreatedPost: $newlyCreatedPost)
        }
    }
}

// TODO: changing votes deletes the post lol (location thing)
// TODO: cant vote on comments
