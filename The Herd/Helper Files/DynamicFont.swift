//
//  DynamicFont.swift
//  The Herd
//
//  Created by Ethan Marshall on 6/13/23.
//

import Foundation
import SwiftUI

struct DynamicFont: ViewModifier {
    
    let font: Font
    let fontDesign: Font.Design
    let lineLimit: Int
    let minimumScaleFactor: Double
    let padding: CGFloat
    
    func body(content: Content) -> some View {
        content
            .font(font)
            .fontDesign(fontDesign)
            .lineLimit(lineLimit)
            .minimumScaleFactor(minimumScaleFactor)
            .padding(.horizontal, padding)
    }
}

extension View {
    func dynamicFont(_ font: Font,
                     fontDesign: Font.Design = .default,
                     lineLimit: Int = 1,
                     minimumScaleFactor: Double = 0.5,
                     padding: CGFloat = 15) -> some View {
        
        modifier(DynamicFont(font: font,
                             fontDesign: fontDesign,
                             lineLimit: lineLimit,
                             minimumScaleFactor: minimumScaleFactor,
                             padding: padding))
    }
}
