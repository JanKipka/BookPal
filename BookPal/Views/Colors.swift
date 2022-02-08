//
//  Colors.swift
//  BookPal
//
//  Created by Jan Kipka on 31.01.22.
//

import Foundation
import SwiftUI

extension Color {
    
    static let primaryColor = Color("primaryColor")
    
    static let secondaryColor = Color("secondaryColor")
    
    static let orangeAccent = Color("orangeAccent")
    
    static let orangeAccent2 = Color("orangeAccent2")
    
    static let mintAccent = Color("mintAccent")
    
    static let mintAccent2 = Color("mintAccent2")
    
    static func linearGradient(topColor: Color, bottomColor: Color) -> LinearGradient {
        LinearGradient(gradient: Gradient(colors: [topColor, bottomColor]), startPoint: .top, endPoint: .bottom)
    }
}


