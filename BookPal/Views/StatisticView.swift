//
//  StatisticView.swift
//  BookPal
//
//  Created by Jan Kipka on 31.01.22.
//

import Foundation
import SwiftUI

struct StatisticView: View {
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Colors.darkerBlue, Colors.lighterBlue]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            }.navigationTitle("Statistics")
        }
        // TODO
    }
    
}
