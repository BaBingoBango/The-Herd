//
//  DispatchView.swift
//  The Herd
//
//  Created by Ethan Marshall on 6/11/23.
//

import SwiftUI
import FirebaseAuth

/// An app view written in SwiftUI!
struct DispatchView: View {
    
    // MARK: View Variables
    @State var isSignedIn: Bool? = nil
    
    // MARK: View Body
    var body: some View {
        Group {
            // If the listener has been called, use isSignedIn to dispatch!
            if let isSignedIn = isSignedIn {
                if isSignedIn {
                    PostBrowserView()
                } else {
                    SignInView()
                }
                
            // If not, check the Auth object!
            } else {
                if Auth.auth().currentUser != nil {
                    PostBrowserView()
                } else {
                    SignInView()
                }
            }
        }
        .onAppear {
            // MARK: View Launch Code
            _ = Auth.auth().addStateDidChangeListener { auth, user in
                
                if user != nil {
                    isSignedIn = true
                } else {
                    isSignedIn = false
                }
            }
        }
    }
    
    // MARK: View Functions
    // Functions go here! :)
}

// MARK: View Preview
struct DispatchView_Previews: PreviewProvider {
    static var previews: some View {
        DispatchView()
    }
}

// MARK: Support Views
// Support views go here! :)
