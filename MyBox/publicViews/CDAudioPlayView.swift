//
//  CDAudioPlayView.swift
//  MyRule
//
//  Created by changdong on 2019/1/5.
//  Copyright © 2019 changdong. All rights reserved.
//


import UIKit
import AVFoundation

@objc protocol CDAudioPlayDelegate {
   @objc func audioFinishPlay()
}
class CDAudioPlayView: UIImageView,AVAudioPlayerDelegate {

    var remainTimeLab:UILabel!
    var sliderView:UISlider!

    var pause:UIButton!
    var player:AVAudioPlayer!
    var timer:Timer!
    var timeLength:Double = 0
    weak var Adelegate:CDAudioPlayDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.image = LoadImageByName(imageName: "下导航-bg", type: "png")
        self.isUserInteractionEnabled = true
        pause = UIButton(type: .custom)
        pause.frame = CGRect(x: 10, y: 9, width: 30, height: 30)
        pause.addTarget(self, action: #selector(onAudioBtnPressed), for: .touchUpInside)
        self.addSubview(pause)

        sliderView = UISlider(frame: CGRect(x: pause.frame.maxX+5, y: 14, width: CDSCREEN_WIDTH-130, height: 20))
        sliderView.minimumValue = 0
        sliderView.setThumbImage(LoadImageByName(imageName: "sliderThumb", type: "png"), for: .normal)
        sliderView.addTarget(self, action: #selector(changePlayTime), for: .valueChanged)
        self.addSubview(sliderView)

        remainTimeLab = UILabel(frame: CGRect(x: sliderView.frame.maxX + 5, y: 14, width: 35, height: 20))
        remainTimeLab.textColor = TextGrayColor
        remainTimeLab.backgroundColor = UIColor.clear
        remainTimeLab.font = TextSmallFont
        remainTimeLab.adjustsFontSizeToFitWidth = true
        self.addSubview(remainTimeLab)
        
        let stopBtn = UIButton(type: .custom)
        stopBtn.frame = CGRect(x: CDSCREEN_WIDTH - 40, y: 9, width: 30, height: 30)
        stopBtn.setImage(LoadImageByName(imageName: "record_cancle", type: "png"), for: .normal)
        stopBtn.addTarget(self, action: #selector(stopPlayer), for: .touchUpInside)
        self.addSubview(stopBtn)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createPlayer(audioPath:String){

        pause.setBackgroundImage(LoadImageByName(imageName: "audiostop", type: "png"), for: .normal)
        pause.tag = 210
        updatePlayerTimeViewWithCurrentTime(current: 0.0)
        timeLength = getTimeLenWithVideoPath(path: audioPath)
        sliderView.maximumValue = Float(timeLength)

        let session = AVAudioSession.sharedInstance()
        do {
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
        } catch  {

        }
        if player != nil {
            player.stop()
            player = nil
        }
        do{
            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath))
        }catch{

        }
        if player == nil {
            let audioData = NSData(contentsOfFile: audioPath)
            do{
                try player = AVAudioPlayer(data: audioData! as Data)
            }catch{
                
            }
        }

        player.delegate = self
        player.play()
        startTimer()
    }
    @objc func onAudioBtnPressed(btn:UIButton) {
        if btn.tag == 210 {
            pause.setBackgroundImage(LoadImageByName(imageName: "audioplay", type: "png"), for: .normal)
            pause.tag = 201
            player.pause()
            pauseTimer()

        }else{
            pause.setBackgroundImage(LoadImageByName(imageName: "audiostop", type: "png"), for: .normal)
            pause.tag = 210
            player.play()
            startTimer()
        }
    }

    @objc func changePlayTime(){
        player.stop()
        player.currentTime = TimeInterval(sliderView.value)
        if pause.tag == 210 {
            player.play()
        }

    }
    @objc func updatePlayTime(){

        let currentTime = player.currentTime
        updatePlayerTimeViewWithCurrentTime(current: Float(currentTime))


    }
    func updatePlayerTimeViewWithCurrentTime(current:Float) {

        let currentT = Double(current + 0.5)
        self.sliderView.value = current
        self.remainTimeLab.text = getMMSSFromSS(second: currentT)

    }
    func startTimer() {
        if timer == nil {
            updatePlayTime()
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updatePlayTime), userInfo: nil, repeats: true)
        }else{
            timer.fireDate = Date.distantPast
        }
    }
    func stopTimer() {
        if timer != nil && timer.isValid {
            timer.invalidate()
            timer = nil
        }
    }
    func pauseTimer() {
        if !timer.isValid {
            return
        }
        timer.fireDate = Date.distantFuture
    }

    @objc func stopPlayer() {

        stopTimer()
        Adelegate?.audioFinishPlay()

    }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {

        stopPlayer()
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch  {

        }

    }

}
