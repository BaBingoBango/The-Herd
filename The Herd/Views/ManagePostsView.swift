//
//  ManagePostsView.swift
//  The Herd
//
//  Created by Ethan Marshall on 6/20/23.
//

import SwiftUI

/// An app view written in SwiftUI!
struct ManagePostsView: View {
    
    // MARK: View Variables
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var showingDrafts = 0
    @ObservedObject var currentUser: User = .getSample()
    var locationManager: LocationManager
    var repost: Post?
    
    // MARK: View Body
    var body: some View {
        NavigationStack {
            VStack {
                Picker(selection: $showingDrafts, label: Text("")) {
                    Text("New Post").tag(0)
                    Text("From Drafts").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                if showingDrafts == 0 {
                    NewPostView(currentUser: currentUser, locationManager: locationManager, repost: repost)
                } else {
                    DraftsView(currentUser: currentUser, locationManager: locationManager)
                }
            }
            
            // MARK: Navigation Settings
            .toolbar(content: {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel")
                            .fontWeight(.bold)
                    }
                }
            })
        }
    }
    
    // MARK: View Functions
    // Functions go here! :)
}

// MARK: View Preview
struct ManagePostsView_Previews: PreviewProvider {
    static var previews: some View {
        ManagePostsView(locationManager: LocationManager())
    }
}

// MARK: Support Views
// Support views go here! :)
