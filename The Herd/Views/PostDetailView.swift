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
            VStack {
                PostOptionView(post: post, showTopBar: false, cornerRadius: 0)
                
                
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
// Support views go here! :)
