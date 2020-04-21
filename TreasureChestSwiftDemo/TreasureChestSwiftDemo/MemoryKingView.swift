//
//  MemoryKingView.swift
//  TreasureChestSwiftDemo
//
//  Created by xiao ming on 2020/4/21.
//  Copyright © 2020 xiao ming. All rights reserved.
//

import SwiftUI
import UIKit

struct MemoryKingView: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> TrainingStepController {
        let pageViewController = TrainingStepController()
        return pageViewController
    }
    
    func updateUIViewController(_ uiViewController: TrainingStepController, context: Context) {
    }
    
}

struct MemoryKingView_Previews: PreviewProvider {
    static var previews: some View {
        MemoryKingView()
    }
}
