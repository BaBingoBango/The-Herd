//
//  SignInView.swift
//  The Herd
//
//  Created by Ethan Marshall on 6/11/23.
//

import SwiftUI
import FirebaseAuth

/// An app view written in SwiftUI!
struct SignInView: View {
    
    // MARK: View Variables
    @State var googleSignIn = Operation()
    
    // MARK: View Body
    var body: some View {
        NavigationStack {
            ZStack {
                Rectangle()
                    .foregroundColor(.accentColor)
                    .edgesIgnoringSafeArea(.all)
                    .opacity(0.175)
                
                VStack {
                    Text("app logo!")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 45, design: .rounded))
                        .fontWeight(.heavy)
                        .foregroundColor(.black)
                    
                    Text("Sign Up or Log In")
                        .font(.system(size: 30))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .offset(y: 15)
                        .padding(.bottom, 60)
                    
                    AuthenticationOptionView(emoji: "📞", text: "Continue with Phone")
                    
                    AuthenticationOptionView(imageName: "google icon", text: "Continue with Google", isInProgress: googleSignIn.status == .inProgress)
                    
                    AuthenticationOptionView(systemIconName: "applelogo", text: "Continue with Apple")
                    
                    // TODO: add "sign in methods and privacy" screen with information
                }
                .padding()
            }
        }
    }
    
    // MARK: View Functions
    struct AuthenticationOptionView: View {
        
        var emoji: String?
        var imageName: String?
        var systemIconName: String?
        var text: String
        var isInProgress = false
        
        var body: some View {
            HStack {
                if isInProgress {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(width: 20, height: 20)
                        .padding(.trailing, 1)
                    
                } else {
                    if emoji != nil {
                        Text(emoji!)
                            .font(.system(size: 27))
                    }
                    
                    if imageName != nil {
                        Image(imageName!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25)
                        
                    }
                    
                    if systemIconName != nil {
                        Image(systemName: systemIconName!)
                            .font(.system(size: 27))
                            .foregroundColor(.primary)
                    }
                }
                
                Text(text)
                    .font(.system(size: 22.5))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.leading, 5)
            }
            .modifier(RectangleWrapper(fixedHeight: 60, color: isInProgress ? .gray : .accentColor))
        }
    }
}

// MARK: View Preview
struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}

// MARK: Support Views
// Support views go here! :)
