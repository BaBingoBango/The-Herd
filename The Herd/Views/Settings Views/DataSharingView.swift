//
//  DataSharingView.swift
//  The Herd
//
//  Created by Ethan Marshall on 8/20/23.
//

import SwiftUI

/// An app view written in SwiftUI!
struct DataSharingView: View {
    
    // MARK: View Variables
    @State var checkStatus = Operation()
    @State var statusCode: Int? = nil
    
    // MARK: View Body
    var body: some View {
        VStack {
            Image(systemName: "person.2.fill")
                .fontWeight(.semibold)
                .font(.system(size: 40))
                .foregroundColor(.blue)
                .padding(.top)
            
            Text("Data Sharing & Access")
                .dynamicFont(.title, lineLimit: 5)
                .multilineTextAlignment(.center)
                .fontWeight(.bold)
                .padding(.top, 5)
                .padding(.bottom)
            
            switch checkStatus.status {
            case .success:
                if statusCode != nil && statusCode! == 1 {
                    InformationalRowView(iconName: "checkmark.shield.fill", text: "Security rules are active on the server and data is being protected.", headingText: "Security System Status", color: .green)
                        .padding(.bottom)
                } else {
                    InformationalRowView(iconName: "xmark.shield.fill", text: "There is a problem with the server security system. Please discontinue use of the app and check back later.", headingText: "Security System Status", color: .red)
                        .padding(.bottom)
                }
                
            case .failure:
                InformationalRowView(iconName: "exclamationmark.shield.fill", text: "There was an error checking the system status. Please check your Internet connection and try again.", headingText: "Security System Status", color: .gray)
                    .padding(.bottom)
                
            default:
                InformationalRowView(iconName: "", text: "Loading...\n", headingText: "Security System Status", color: .gray, showSpinner: true)
                    .padding(.bottom)
            }
            
            InformationalRowView(iconName: "lock.fill", text: "Server rules ensure that other users can't view or modify your personal account.", color: .blue)
                .padding(.bottom)
            
            InformationalRowView(iconName: "doc.on.doc", text: "Only a copy of your information is shared in posts and comments; your live location or identity are never accessible.", color: .blue)
                .padding(.bottom)
            
            InformationalRowView(iconName: "point.3.filled.connected.trianglepath.dotted", text: "The Herd uses Google's cloud computing services, but performs no tracking via Google Analytics or other methods.", color: .blue)
            
            Spacer()
        }
        .padding(.horizontal)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // MARK: View Launch Code
            // Add a real-time listener for the status code!
            systemCollection.document("status").addSnapshotListener { snapshot, error in
                if let error = error { checkStatus.setError(message: error.localizedDescription ) }
                if let snapshot = snapshot, let snapshotData = snapshot.data() {
                    if snapshotData.keys.contains("code") {
                        statusCode = (snapshotData["code"] as! Int)
                        checkStatus.status = .success
                    } else {
                        statusCode = -1
                        checkStatus.status = .success
                    }
                } else {
                    checkStatus.setError(message: "No status code was found.")
                }
            }
        }
    }
    
    // MARK: View Functions
    // Functions go here! :)
}

// MARK: View Preview
struct DataSharingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DataSharingView()
        }
    }
}

// MARK: Support Views
// Support views go here! :)
