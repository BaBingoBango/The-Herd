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
            if let isSignedIn = isSignedIn {
                // If the listener has been called, use isSignedIn to dispatch!
                if isSignedIn {
                    Button(action: {
                        try! Auth.auth().signOut()
                    }) {
                        Text("sign out!")
                    }
                } else {
                    SignInView()
                }
                
            } else {
                // If not, check the Auth object!
                if let user = Auth.auth().currentUser {
                    Button(action: {
                        try! Auth.auth().signOut()
                    }) {
                        Text("sign out!")
                    }
                } else {
                    SignInView()
                }
            }
        }
            .onAppear {
                // MARK: View Launch Code
                let authListener = Auth.auth().addStateDidChangeListener { auth, user in
                    
                    if let user = user {
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
