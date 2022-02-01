//
//  Colors.swift
//  BookPal
//
//  Created by Jan Kipka on 31.01.22.
//

import Foundation
import SwiftUI

struct Colors {
    static let orange = Color(red: 255 / 255, green: 209 / 255, blue: 52 / 255)
    
    static let lighterOrange = Color(red: 255 / 255, green: 244 / 255, blue: 207 / 255)

    static let lighterBlue = Color(red: 214 / 255, green: 227 / 255, blue: 255 / 255)

    static let darkerBlue = Color(red: 152 / 255, green: 223 / 255, blue: 255 / 255)

    static let mint = Color(red: 129 / 255, green: 252 / 255, blue: 228 / 255)
    
    static let lighterMint = Color(red: 194 / 255, green: 255 / 255, blue: 241 / 255)
    
    static func getRGB(red: Int, green: Int, blue: Int) -> Color {
        return Color(red: Double(red / 255), green: Double(green / 255), blue: Double(blue / 255))
    }
    
    static func linearGradient(topColor: Color, bottomColor: Color) -> LinearGradient {
        LinearGradient(gradient: Gradient(colors: [topColor, bottomColor]), startPoint: .top, endPoint: .bottom)
    }
}


