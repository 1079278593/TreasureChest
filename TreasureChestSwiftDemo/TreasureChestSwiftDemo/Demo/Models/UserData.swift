//
//  UserData.swift
//  TreasureChestSwiftDemo
//
//  Created by xiao ming on 2020/4/20.
//  Copyright © 2020 xiao ming. All rights reserved.
//

import SwiftUI
import Combine

final class UserData: ObservableObject  {
    @Published var showFavoritesOnly = false
    @Published var landmarks = landmarkData
}
