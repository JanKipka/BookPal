//
//  LibraryView.swift
//  BookPal
//
//  Created by Jan Kipka on 31.01.22.
//

import Foundation
import SwiftUI

struct LibraryView: View {
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Colors.darkerBlue, Colors.lighterBlue]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            }.navigationTitle("Library")
        }
        
        // TODO
        // Template: Apple Podcast App -> Library Tab
        // At the top, a menu with Genre, Authors, All
        // Below tiles with recently read books
    }
    
}