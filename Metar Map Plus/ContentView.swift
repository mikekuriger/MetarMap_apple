//
//  ContentView.swift
//  Metar Map Plus
//
//  Created by Kuriger, Michael on 2/21/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            MapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
        }
    }
}

