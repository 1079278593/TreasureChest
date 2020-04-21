//
//  JumpToMemoryKing.swift
//  TreasureChestSwiftDemo
//
//  Created by xiao ming on 2020/4/21.
//  Copyright © 2020 xiao ming. All rights reserved.
//

import SwiftUI

struct JumpToMemoryKing: View {
    var body: some View {
        NavigationView {
            NavigationLink(destination: MemoryKingView()) {
                Text("跳转").frame(width: nil, height: 31, alignment: .center)
            }
        }
    }
}

struct JumpToMemoryKing_Previews: PreviewProvider {
    static var previews: some View {
        JumpToMemoryKing()
    }
}
