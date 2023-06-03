//
//  RectangleWrapper.swift
//  
//
//  Created by Ethan Marshall on 5/11/22.
//

import Foundation
import SwiftUI

/// A SwiftUI modifier than encloses a view in a rectangle.
///
/// To use this modifier, create an instance of this structure within the `modifier` modifier, as below:
///
/// `.modifier(RectangleWrapper(fixedHeight: 215, color: .green))`
public struct RectangleWrapper: ViewModifier {
    
    var fixedHeight: Int?
    var color: Color?
    var opacity = 0.1
    
    /// Produces the modified view given the original content.
    public func body(content: Content) -> some View {
        ZStack {
            if fixedHeight == nil {
                Rectangle()
                    .foregroundColor(color == nil ? .primary : color!)
                    .opacity(opacity)
                    .cornerRadius(15)
            } else {
                Rectangle()
                    .foregroundColor(color == nil ? .primary : color!)
                    .frame(height: CGFloat(fixedHeight!))
                    .opacity(opacity)
                    .cornerRadius(15)
            }
            content
        }
    }
}
