//
//  SoundPlayer.swift
//  MemoryKing
//
//  Created by ming on 2019/9/26.
//  Copyright © 2019 雏虎科技. All rights reserved.
//

import UIKit
import AVFoundation

let sound_buttonClick = "Sound_WaterDrop"           //.m4a
let sound_correct = "Sound_Correct"                 //.m4a
let sound_error = "Sound_Error"                     //.m4a
let sound_keyboard = "threeWord_keyboardVoice"      //.m4a
let sound_victoryCheers = "sound_victoryCheers"     //.m4a

public class SoundPlayer: NSObject {
    static let sharedInstance = SoundPlayer()
    var player: AVAudioPlayer?
    
    private override init() {
        super.init()

    }
    
    //直接加载并播放
    func playSound(name: String, type: String) {
        player?.stop()
        player = nil
        if let filePath = Bundle.main.path(forResource: name, ofType: type),
            let fileURL = URL.init(string: filePath) {
            player =  try? AVAudioPlayer.init(contentsOf: fileURL)
            player?.prepareToPlay()
            player?.numberOfLoops = 0   //-1 代表无限循环
            player?.play()
            print("try play sound")
        }
    }
    
    //预加载模式
    func loadSound(name: String, type: String) {
        if let filePath = Bundle.main.path(forResource: name, ofType: type),
            let fileURL = URL.init(string: filePath) {
            player =  try? AVAudioPlayer.init(contentsOf: fileURL)
            player?.prepareToPlay()
            player?.numberOfLoops = 0   //-1 代表无限循环
        }
    }
}

