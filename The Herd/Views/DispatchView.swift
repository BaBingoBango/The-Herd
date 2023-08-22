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
    @State var serverStatusCode = 2
    
    // MARK: View Body
    var body: some View {
        // Dispatch off of the server status code at the root!
        Group {
            switch serverStatusCode {
                
            case 1: // normal code
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
                
            case 2: // code loading
                EmptyView()
                
            case -1: // no code found
                EmptyCollectionView(iconName: "wifi.slash", heading: "Couldn't Connect", text: "The server couldn't be reached. Please check your Internet connection and try again.")
                
            default: // bad code or unknown code
                EmptyCollectionView(iconName: "wrench.adjustable.fill", heading: "Server Unavaliable", text: "The server is currently undergoing maintenance. Please check back soon!")
            }
        }
        .onAppear {
            // MARK: View Launch Code
            // Listen to the auth status!
            _ = Auth.auth().addStateDidChangeListener { auth, user in
                
                if user != nil {
                    isSignedIn = true
                } else {
                    isSignedIn = false
                }
            }
            
            // Add a real-time listener for the server status code!
            systemCollection.document("status").addSnapshotListener { snapshot, error in
                if let error = error { serverStatusCode = -1 }
                
                if let snapshot = snapshot, let snapshotData = snapshot.data() {
                    if snapshotData.keys.contains("code") {
                        serverStatusCode = (snapshotData["code"] as! Int)
                        
                    } else {
                        serverStatusCode = -1
                    }
                } else {
                    serverStatusCode = -1
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
