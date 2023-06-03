//
//  PostBrowserView.swift
//  The Herd
//
//  Created by Ethan Marshall on 6/3/23.
//

import SwiftUI

/// An app view written in SwiftUI!
struct PostBrowserView: View {
    
    // MARK: View Variables
    @State var isShowingNewPostView = false
    
    // MARK: View Body
    var body: some View {
//        NavigationView {
            ScrollView {
                VStack {
                    Button(action: {
                        isShowingNewPostView = true
                    }) {
                        Label("New Post", systemImage: "plus")
                            .foregroundColor(.white)
                            .fontWeight(.heavy)
                            .padding()
                            .modifier(RectangleWrapper(color: .accentColor, opacity: 1))
                    }
                    .sheet(isPresented: $isShowingNewPostView) {
                        Text("new post view goes here!")
                    }
                    
                    ForEach(Taylor.lyrics, id: \.self) { eachLyric in
                        PostOptionView(post: .init(author: .sample, text: eachLyric, votes: [:], comments: [], timePosted: Date(), latitude: 0, longitude: 0))
                    }
                }
                .padding([.leading, .bottom, .trailing])
            }
//        }
    }
    
    // MARK: View Functions
    // Functions go here! :)
}

// MARK: View Preview
struct PostBrowserView_Previews: PreviewProvider {
    static var previews: some View {
        PostBrowserView()
    }
}

// MARK: Support Views
// Support views go here! :)
