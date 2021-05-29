//
//  ContentView.swift
//  TreasureChestSwiftDemo
//
//  Created by ming on 2021/5/6.
//  Copyright © 2021 xiao ming. All rights reserved.
//

import SwiftUI
import UIKit

struct ContentView: View {
    var body: some View {
        
        VStack {
            MapView1()
                .ignoresSafeArea(edges: .top)
                .frame(height: 300)
            CircleImage()
                .offset(y: -100)
                .padding(.bottom, -100)
            VStack(alignment: .leading) {
                Text("hello swiftUI")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                HStack {
                    Text("name")
                    Spacer()
                    Text("school")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                
                Divider()
                Text("About Turtle Rock")
                    .font(.title2)
                Text("Descriptive text goes here.")
            }
            .padding(11)
            Spacer()
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


