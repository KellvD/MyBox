//
//  CDAudioManager.swift
//  MyBox
//
//  Created by changdong on 2021/9/29.
//  Copyright © 2018 changdong. All rights reserved.
//

import Foundation
import AVFoundation

@objc protocol CDAudioManagerDelegate {
    func audioManagerTimerUpdate(current: Double)
    @objc optional func audioPlayFinshed()
}
class CDAudioManager: NSObject, AVAudioPlayerDelegate {
    enum Model {
        case play
        case record
    }

    private weak var delegate: CDAudioManagerDelegate!
    var isRecording: Bool = false
    private var player: AVAudioPlayer!
    private var timer: Timer!
    private var recorder: AVAudioRecorder!
    private var model: Model!
    private var delay: Double!
    private var audioUrl: URL!
    init(audioUrl: URL, delay: Double, model: Model, delegate: CDAudioManagerDelegate?) {
        super.init()
        self.model = model
        self.delay = delay
        self.delegate = delegate

        if model == .play {
            self.audioUrl = audioUrl
            initPlayer(audioUrl: audioUrl)
        } else {
            initRecord(audioUrl: audioUrl)
        }

    }

    private func initPlayer(audioUrl: URL) {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: .defaultToSpeaker)
        try? session.setActive(true)
        stop()
        do {
            player = try AVAudioPlayer(contentsOf: audioUrl)
        } catch {
            CDHUDManager.shared.showText("Audio player create fail".localize)
        }
        player.delegate = self

    }

    private func initRecord(audioUrl: URL) {
        let dict = [AVFormatIDKey: NSNumber(value: kAudioFormatMPEG4AAC),
        AVSampleRateKey: NSNumber(value: 8000),
        AVNumberOfChannelsKey: NSNumber(value: 1),
        AVLinearPCMBitDepthKey: NSNumber(value: 16),
        AVEncoderAudioQualityKey: NSNumber(value: AVAudioQuality.high.rawValue),
        AVLinearPCMIsFloatKey: NSNumber(value: true)]
        stop()
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            try AVAudioSession.sharedInstance().setActive(true)
            try self.recorder = AVAudioRecorder(url: audioUrl, settings: dict)
        } catch {
            CDHUDManager.shared.showFail("音频录制失败".localize)
            CDPrintManager.log("音频录制失败:\(error.localizedDescription)", type: .ErrorLog)
            return
        }

        self.recorder.isMeteringEnabled = true
        self.recorder.prepareToRecord()

    }

    func start() {
        if model == .play {
            if player != nil {
                player.prepareToPlay()
                player.play()
            } else {
                CDHUDManager.shared.showText("播放器创建失败".localize)
            }

        } else {
            if recorder != nil {
                recorder.record()
                isRecording = true
            } else {
                CDHUDManager.shared.showFail("音频录制失败".localize)
            }

        }
        startTimer()
    }

    func pause() {
        if model == .play {
            player.pause()
        } else {
            recorder.pause()
            isRecording = false
        }
        pauseTimer()
    }

    func stop() {
        if model == .play {
            if player != nil {
                player.stop()
                player = nil
            }
        } else {
            if recorder != nil {
                recorder?.stop()
                recorder = nil
                isRecording = false
            }
        }
        stopTimer()
    }

    func autoFinished() {
        if model == .play {
            player.pause()
            player.currentTime = TimeInterval(0)
            pauseTimer()
        }
    }

    func seekPlayTime(seekTime: Float) {
        if player == nil {
            initPlayer(audioUrl: audioUrl)
            player.currentTime = TimeInterval(seekTime)
        } else {
            if player.isPlaying {
                player.pause()
                player.currentTime = TimeInterval(seekTime)
                player.play()
            } else {
                player.currentTime = TimeInterval(seekTime)
            }

        }

    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        autoFinished()
        if delegate != nil {
            delegate.audioPlayFinshed!()
        }

    }

    private func startTimer() {
        if timer == nil {
            updatePlayTime()
            timer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(updatePlayTime), userInfo: nil, repeats: true)
        } else {
            timer.fireDate = .distantPast
        }
    }

    private func stopTimer() {
        if timer != nil && timer.isValid {
            timer.invalidate()
            timer = nil
        }
    }

    private func pauseTimer() {
        if !timer.isValid {
            return
        }
        timer.fireDate = .distantFuture
    }

    @objc func updatePlayTime() {
        let currentTime = model == .play ? player.currentTime : recorder.currentTime
        delegate.audioManagerTimerUpdate(current: currentTime)
    }

}
