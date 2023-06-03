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
    var post = Post.sample
    
    // MARK: View Body
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                ZStack {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(post.author.color)
                    
                    Text(post.author.emoji)
                        .font(.system(size: 25))
                }
                .offset(y: -12.5)
                
                Text("\(post.calculateDistanceFromLocation(latitude: 30, longitude: 50)) · \(post.distanceFromNow)")
                    .offset(y: -6.5)
                
                Spacer()
                
                Image(systemName: "ellipsis.circle.fill")
                    .font(.system(size: 30))
                    .padding(.top, 12.5)
            }
            
            Text(post.text)
                .font(.system(size: 30))
                .padding(.bottom, 5)
            
            HStack {
                Label("\(Post.countComments(post.comments))", systemImage: "bubble.left")
                
                Spacer()
                
                Image(systemName: "arrow.up")
                
                Text("\(post.score)")
                
                Image(systemName: "arrow.down")
            }
        }
        .padding([.leading, .bottom, .trailing])
        .modifier(RectangleWrapper(color: .gray, opacity: 0.1))
        .padding(.top, 20)


    }
    
    // MARK: View Functions
    // Functions go here! :)
}

// MARK: View Preview
struct PostOptionView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            PostOptionView()
                .padding()
        }
    }
}

// MARK: Support Views
// Support views go here! :)
