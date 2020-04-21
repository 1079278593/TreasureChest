//
//  RotatedBadgeSymbol.swift
//  TreasureChestSwiftDemo
//
//  Created by xiao ming on 2020/4/21.
//  Copyright © 2020 xiao ming. All rights reserved.
//

import SwiftUI

struct RotatedBadgeSymbol: View {
    let angle: Angle
    var body: some View {
        BadgeSymbol()
        .padding(-60)
        .rotationEffect(angle, anchor: .bottom)
    }
}

struct RotatedBadgeSymbol_Previews: PreviewProvider {
    static var previews: some View {
        RotatedBadgeSymbol(angle: .init(degrees: 5))
    }
}
