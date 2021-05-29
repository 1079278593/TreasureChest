//
//  JumpToMemoryKing.swift
//  TreasureChestSwiftDemo
//
//  Created by xiao ming on 2020/4/21.
//  Copyright © 2020 xiao ming. All rights reserved.
//  这里只是临时文件，swiftUI->swift

import SwiftUI

struct JumpToMemoryKing: View {
    @State var buttonText = "old text1"
    var body: some View {
        VStack {
//            NavigationView {
//                NavigationLink(destination: MemoryKingView()) {
//                    Text("跳转").frame(width: nil, height: 31, alignment: .center)
//                }
//            }
            Text("341")
            Button(action: changeText) {
                Text(buttonText)
                Text("buttonText")
//                text = "342"
            }
        }
    }
    private func changeText() {
        buttonText = "new text"
    }
}

struct JumpToMemoryKing_Previews: PreviewProvider {
    static var previews: some View {
        JumpToMemoryKing()
    }
}
