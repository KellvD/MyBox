//
//  CDMusicManager.swift
//  MyRule
//
//  Created by changdong on 2019/4/19.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit
import AVFoundation

@objc protocol CDMusicPlayDelegate{
    @objc func onUpdateMusicPlayCurrentTime(current:Float)
}
class CDMusicManager: NSObject,AVAudioPlayerDelegate {
    
    
    var player:AVAudioPlayer!
    var musicTimer:Timer!
    var currentPlayList:[CDMusicInfo] = []
    var currentPlayIndex:Int!
    var musicPlayDelegate:CDMusicPlayDelegate!
    static let instance = CDMusicManager()
    class func shareInstance() -> CDMusicManager {

       
        return instance
    }

    func addDefaultClass() {


    }
    func playWithMusic(musicInfo:CDMusicInfo) {

        let musicPath = String.RootPath().appendingPathComponent(str: musicInfo.musicPath)

        let session = AVAudioSession.sharedInstance()
        do {
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
        } catch  {

        }
        if player != nil {
            player.stop()
            player = nil;
            stopTimer()
        }
        do {

            try player = AVAudioPlayer(data: Data(contentsOf: URL(fileURLWithPath:musicPath)))

        } catch  {
            print("error = \(error)")
        }
        do{
            if player == nil {
                try player = AVAudioPlayer(contentsOf: URL(fileURLWithPath:musicPath))
            }
        }catch{

        }
        player.delegate = self
        player.play()
        starTimer()
    }

    //MARK:Player
    func starPlayer(){
        if player != nil{
            player.play()
            starTimer()
        }
    }
    func stopPlayer(){
        stopTimer()
    }
    func pausePlayer() {
        player.pause()
        pauseTimer()
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {

//        let musicInfo = currentPlayList[currentPlayIndex]
//        playWithMusic(musicInfo: musicInfo)
//        if getCurrentCircleType() == .CDCircle_Queue { //顺序循环
//            currentPlayIndex += 1
//            if currentPlayIndex == currentPlayList.count {
//                currentPlayIndex = 0
//            }
//        }else if getCurrentCircleType() == .CDCircle_Random{
//            let count:UInt32 = UInt32(currentPlayList.count)
//            currentPlayIndex  = Int(arc4random() % count) + 1
//        }

        
    }
    //MARK:Timer
    func starTimer(){
        if musicTimer == nil{
            musicTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updatePlayTime), userInfo: nil, repeats: true)
        }else{
            musicTimer.fireDate = .distantPast
        }
    }
    func stopTimer(){
        if musicTimer != nil && musicTimer.isValid {
            musicTimer.invalidate()
            musicTimer = nil
        }

    }
    func pauseTimer(){
        if !musicTimer.isValid {
            return
        }
        musicTimer.fireDate = Date.distantFuture
    }
    @objc func updatePlayTime() {
        let currentTime = Float(player.currentTime)
        if musicPlayDelegate != nil {
            musicPlayDelegate.onUpdateMusicPlayCurrentTime(current: currentTime)

        }
    }



}
//@inline(__always)func getCurrentMusicId() ->Int{
//    let musicId = CDConfigFile.getIntValueFromConfigWith(key: CD_CurrentMusicIdKey)
//    return musicId
//}
//@inline(__always)func getCurrentClassId() ->Int{
//    let classId = CDConfigFile.getIntValueFromConfigWith(key: CD_CurrentClassIdKey)
//    return classId
//}
//@inline(__always)func getCurrentCircleType() ->CDCircleType {
//    let curcleTypeInt = CDConfigFile.getIntValueFromConfigWith(key: CD_CurrentCircleKey)
//
//    let circleType:CDCircleType = CDCircleType(rawValue: curcleTypeInt) ?? .CDCircle_Queue
//    return circleType
//}
