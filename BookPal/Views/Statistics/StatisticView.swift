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
                Color.linearGradient(topColor: Color.primaryColor, bottomColor: Color.secondaryColor)
                    .ignoresSafeArea()
            }.navigationTitle("Statistics")
        }
        // TODO
    }
    
}
