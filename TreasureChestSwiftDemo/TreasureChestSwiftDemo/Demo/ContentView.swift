//
//  ContentView.swift
//  TreasureChestSwiftDemo
//
//  Created by xiao ming on 2020/4/15.
//  Copyright © 2020 xiao ming. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            HStack {
                Text("Hello, World!0000")
                .foregroundColor(Color.red)
                .lineLimit(11)
                
                Spacer()
                Text("Placeholder")
                .font(.subheadline)
            }
            .padding(11)
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/) {
                Text("Button")
            }
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/) {
                Text("Button")
            }
            .padding(1)
        
        }
    .padding(11)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
