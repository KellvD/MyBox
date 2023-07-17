//
//  CDAudioPlayViewController.swift
//  MyBox
//
//  Created by changdong on 2021/10/8.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit

class CDAudioPlayViewController: CDBaseAllViewController {

    public var audioPath: String!
    public var fileName: String!
    public var timeLength: Double!
    private var rippleView: CDRippleView!
    private var playBtn: UIButton!
    private var audioManager: CDAudioManager!
    private var isPlaying = false
    private var mediaSlider: CDMediaSlider!

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isPlaying {
            stopPlay()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = fileName
        audioManager = CDAudioManager(audioUrl: audioPath.url, delay: 1.0, model: .play, delegate: self)

        let centerWidth = CDSCREEN_WIDTH/3.0
        rippleView = CDRippleView(frame: CGRect(x: 0, y: CDViewHeight/2.0 - CDSCREEN_WIDTH/2.0, width: CDSCREEN_WIDTH, height: CDSCREEN_WIDTH), fillColor: UIColor.red, minRadius: 50, waveCount: 5, timeInterval: 1, duration: 4)
        self.view.addSubview(rippleView)

        playBtn = UIButton(type: .custom)
        playBtn.frame = CGRect(x: CDSCREEN_WIDTH/2.0 - centerWidth/2.0, y: CDViewHeight/2.0 - centerWidth/2.0, width: centerWidth, height: centerWidth)
        playBtn.setBackgroundImage(LoadImage("voice_play_nor"), for: .normal)
        playBtn.setBackgroundImage(LoadImage("voice_play_pressed"), for: .selected)
        playBtn.addTarget(self, action: #selector(onAudioBtnPressed), for: .touchUpInside)
        self.view.addSubview(playBtn)

        mediaSlider = CDMediaSlider(frame: CGRect(x: 10, y: CDViewHeight - 30 - 100, width: CDSCREEN_WIDTH - 20, height: 30), timeLength: timeLength)
        mediaSlider.delegate = self
        self.view.addSubview(mediaSlider)
    }

    @objc private func onAudioBtnPressed() {
        if isPlaying {
            stopPlay()
        } else {
            startPlay()
        }
        isPlaying = !isPlaying
    }

    private func startPlay() {
        audioManager.start()
        rippleView.startAnimating()
        playBtn.setBackgroundImage(LoadImage("voice_pause_nor"), for: .normal)
        playBtn.setBackgroundImage(LoadImage("voice_pause_pressed"), for: .selected)
    }

    private func stopPlay() {

        audioManager.pause()
        rippleView.stopAnimating()
        playBtn.setBackgroundImage(LoadImage("voice_play_nor"), for: .normal)
        playBtn.setBackgroundImage(LoadImage("voice_play_pressed"), for: .selected)
    }

}

extension CDAudioPlayViewController: CDAudioManagerDelegate {

    func audioManagerTimerUpdate(current: Double) {
        mediaSlider.updateProcess(process: current)
    }

    func audioPlayFinshed() {
        mediaSlider.updateProcess(process: 0)
        rippleView.stopAnimating()
        playBtn.setBackgroundImage(LoadImage("voice_play_nor"), for: .normal)
        playBtn.setBackgroundImage(LoadImage("voice_play_pressed"), for: .selected)
        isPlaying = false
    }
}

extension CDAudioPlayViewController: CDMediaSliderDelegate {

    func sliderDidChange(value: Float) {
        audioManager.seekPlayTime(seekTime: value)
    }

}
