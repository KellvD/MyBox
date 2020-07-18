//
//  CDPlayerBar.swift
//  MyRule
//
//  Created by changdong on 2019/6/24.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit

class CDPlayerBar: UIView,CDMusicPlayDelegate {
    func onUpdateMusicPlayCurrentTime(current: Float) {
        
    }


    var imageView:UIImageView!
    var nameLabel:UILabel!
    var artistLabel:UILabel!
    var slider:UISlider!
    var playBtn:UIButton!
    let player = CDMusicManager.shareInstance().player


    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView(frame: CGRect(x: 15, y: 0, width: frame.height, height: frame.height))
        imageView.layer.cornerRadius = frame.height/2
        self.addSubview(imageView)

        slider = UISlider(frame: CGRect(x: imageView.frame.maxX + 5, y: 5, width: frame.width - (imageView.frame.maxX + 20), height: 15))
        slider.addTarget(self, action: #selector(sliderChangeTime(slider:)), for: .valueChanged)
        slider.minimumValue = 0
        self.addSubview(slider)

        nameLabel = UILabel(frame: CGRect(x: imageView.frame.maxX + 5, y: 25, width: slider.frame.width, height: 20))
        nameLabel.font = UIFont.systemFont(ofSize: 14)
        nameLabel.textColor = TextLightGrayColor
        self.addSubview(nameLabel)

        artistLabel = UILabel(frame: CGRect(x: imageView.frame.maxX + 5, y: 50, width: slider.frame.width/2, height: 20))
        artistLabel.font = UIFont.systemFont(ofSize: 12)
        artistLabel.textColor = TextLightGrayColor
        artistLabel.alpha = 0.8
        self.addSubview(artistLabel)

        playBtn = UIButton(type: .custom)
        playBtn.frame = CGRect(x: frame.width - 20 * 2 - 35 * 3 - 15, y: 25, width: 35, height: 35)
        if CDMusicManager.shareInstance().player.isPlaying{
            playBtn.setImage(LoadImageByName(imageName: "bar_stop", type: "png"), for: .normal)
        }else{
            playBtn.setImage(LoadImageByName(imageName: "bar_play", type: "png"), for: .normal)

        }
        playBtn.addTarget(self, action: #selector(playBtnClick(sender:)), for: .touchUpInside)
        self.addSubview(playBtn)

        let nextBtn = UIButton(type: .custom)
        nextBtn.frame = CGRect(x: frame.width - 20 - 35 * 2 - 15, y: 25, width: 35, height: 35)
        nextBtn.setImage(LoadImageByName(imageName: "下一首播放", type: "png"), for: .normal)
        nextBtn.addTarget(self, action: #selector(onNextPlayClick), for: .touchUpInside)
        self.addSubview(nextBtn)

        let listBtn = UIButton(type: .custom)
        listBtn.frame = CGRect(x: frame.width - 35 - 15, y: 25, width: 35, height: 35)
        listBtn.addTarget(self, action: #selector(onPopListBtnClick), for: .touchUpInside)
        listBtn.setImage(LoadImageByName(imageName: "bar_list", type: "png"), for: .normal)
        self.addSubview(listBtn)

        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onPopPlayViewController)))
    }

    @objc func sliderChangeTime(slider:UISlider){
        if player!.isPlaying {
            player?.stop()
        }

        player!.currentTime = TimeInterval(slider.value)
        if playBtn.tag == 210 {
            player!.play()
        }
    }
    @objc func playBtnClick(sender:UIButton){
//        let status = CDConfigFile.getBoolValueFromConfigWith(key: CD_MusicPlayerStatus)

        if player!.isPlaying {
            playBtn.setBackgroundImage(LoadImageByName(imageName: "bar_stop", type: "png"), for: .normal)
            player!.pause()

        }else{
            playBtn.setBackgroundImage(LoadImageByName(imageName: "bar_play", type: "png"), for: .normal)
            player!.play()
        }
    }
    @objc func onNextPlayClick(){

    }
    @objc func onPopListBtnClick(){

    }

    @objc func onPopPlayViewController(){

    }
    func loadMusicInfo(music:CDMusicInfo) {

        slider.maximumValue = Float(music.musicTimeLength)
        nameLabel.text = music.musicName
        artistLabel.text = music.musicSinger

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
