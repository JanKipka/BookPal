//
//  MainView.swift
//  BookPal
//
//  Created by Jan Kipka on 31.01.22.
//

import Foundation
import SwiftUI


struct MainView: View {
    var body: some View {
        TabView {
            ReadNowView()
                .tabItem {
                    Label("Read Now", systemImage: "book.fill")
                }

            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "books.vertical.fill")
                }
            
            StatisticView()
                .tabItem {
                    Label("Stats", systemImage: "chart.line.uptrend.xyaxis")
                }
        }
    }
}
