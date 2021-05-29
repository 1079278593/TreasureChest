//
//  CircleImage.swift
//  TreasureChestSwiftDemo
//
//  Created by ming on 2021/5/6.
//  Copyright © 2021 xiao ming. All rights reserved.
//

import SwiftUI

struct CircleImage: View {
    var body: some View {
        Image("turtlerock")//turtlerock/cell_redBg/kongfuzi
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.green, lineWidth: 2.0))
            .shadow(radius: 10)
    }
}

struct CircleImage_Previews: PreviewProvider {
    static var previews: some View {
        CircleImage()
    }
}
