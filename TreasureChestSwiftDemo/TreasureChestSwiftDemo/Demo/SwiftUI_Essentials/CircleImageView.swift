//
//  CircleImageView.swift
//  TreasureChestSwiftDemo
//
//  Created by xiao ming on 2020/4/16.
//  Copyright © 2020 xiao ming. All rights reserved.
//

import SwiftUI
import Lottie

struct CircleImageView: View {
    var image: Image
    var body: some View {
        image
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.white, lineWidth: 4))
        .shadow(radius: 10)
    }
}

struct CircleImageView_Previews: PreviewProvider {
    static var previews: some View {
        CircleImageView(image: Image("icon300"))
    }
}
