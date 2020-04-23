//
//  SoundPlayer.swift
//  MemoryKing
//
//  Created by ming on 2019/9/26.
//  Copyright © 2019 雏虎科技. All rights reserved.
//

import UIKit
import AVFoundation

//文件格式：.m4a
let sound_buttonClick = "Sound_WaterDrop"           //水滴下落
let sound_correct = "Sound_Correct"                 //正确
let sound_error = "Sound_Error"                     //错误
let sound_keyboard = "threeWord_keyboardVoice"      //键盘
let sound_score = "sound_score"                     //得分
let sound_eat = "sound_eat"                         //吃
let sound_victoryMogic = "sound_victoryMogic"       //胜利魔法棒
let sound_victoryCheers = "sound_victoryCheers"     //胜利欢呼声



public enum SoundType: String {
    case SoundTypeM4A = "m4a"
    case SoundTypeMP3 = "mp3"
    case SoundTypeWAV = "wav"
}

class SoundPlayer: NSObject {
    static public let sharedInstance = SoundPlayer()
    public var player: AVAudioPlayer?
    
    private override init() {
        super.init()

    }
    
    public func playSound(name: String, type: SoundType) {
        player?.stop()
        player = nil
        if let filePath = Bundle.main.path(forResource: name, ofType: type.rawValue),
            let fileURL = URL.init(string: filePath) {
            player =  try? AVAudioPlayer.init(contentsOf: fileURL)
            player?.prepareToPlay()
            player?.numberOfLoops = 0   //-1 代表无限循环
            player?.play()
            print("try play sound")
        }
    }
}

