//
//  PhoneSignInView.swift
//  The Herd
//
//  Created by Ethan Marshall on 6/11/23.
//

import SwiftUI
import iPhoneNumberField

/// An app view written in SwiftUI!
struct PhoneSignInView: View {
    
    // MARK: View Variables
    @State var enteredPhoneNumber = ""
    
    // MARK: View Body
    var body: some View {
        VStack {
            Text("📞")
                .font(.system(size: 70))
                .padding(.bottom, 5)
            
            Text("Continue with Phone Number")
                .font(.system(size: 30))
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            iPhoneNumberField("(123) 456-7890", text: $enteredPhoneNumber)
                .multilineTextAlignment(.center)
                .font(UIFont(size: 30, weight: .bold, design: .rounded))
                .flagHidden(false)
                .flagSelectable(true)
                .maximumDigits(10)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: .gray.opacity(0.3), radius: 10)
                .padding()
            
            Text("Submit!")
        }
    }
    
    // MARK: View Functions
    // Functions go here! :)
}

// MARK: View Preview
struct PhoneSignInView_Previews: PreviewProvider {
    static var previews: some View {
        PhoneSignInView()
    }
}

// MARK: Support Views
// Support views go here! :)
