//
//  PostDetailView.swift
//  The Herd
//
//  Created by Ethan Marshall on 6/4/23.
//

import SwiftUI

/// An app view written in SwiftUI!
struct PostDetailView: View {
    
    // MARK: View Variables
    @State var post = Post.sample
    
    // MARK: View Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                PostOptionView(post: post, showTopBar: false, cornerRadius: 0)
                
                CommentsView(comments: post.comments, post: post)
                    .padding(.horizontal)
            }
            
            // MARK: Navigation Settings
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text(post.author.emoji)
                            .font(.system(size: 25))
                            .padding(.top, 10)
                        
                        Text("\(post.distanceFromNow) ago · \(post.calculateDistanceFromLocation(latitude: 42.50807, longitude: 83.40217)) away")
                            .font(.system(size: 15))
                            .fontWeight(.heavy)
                            .padding(.bottom, 17.5)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                }
            })
            .toolbarBackground(post.author.color, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
    
    // MARK: View Functions
    // Functions go here! :)
}

// MARK: View Preview
struct PostDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PostDetailView()
        }
    }
}

// MARK: Support Views
struct CommentsView: View {
    
    var comments: [Post]
    var post: Post
    var barColor: Color = .clear
    
    var body: some View {
        ForEach(comments, id: \.UUID) { eachComment in
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    ZStack {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 37.5))
                            .foregroundColor(eachComment.author.color)
                        
                        Text(eachComment.author.emoji)
                            .font(.system(size: 25))
                    }
                    
                    Text(eachComment.distanceFromNow)
                        .font(.system(size: 17.5))
                        .fontWeight(.heavy)
                        .foregroundColor(.secondary)
                }
                
                Text(eachComment.text)
                    .font(.system(size: 22.5, design: .default))
                    .fontWeight(.medium)
                    .padding(.leading, 7.5)
                    .padding(.bottom)
                
                PostOptionView(post: eachComment, showTopBar: false, showText: false, seperateControls: false, cornerRadius: 0, bottomBarFont: .body)
                
                CommentsView(comments: eachComment.comments, post: post, barColor: eachComment.author.color)
                    .padding(.leading)
            }
        }
    }
}
