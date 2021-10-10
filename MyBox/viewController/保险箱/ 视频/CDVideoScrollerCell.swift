//
//  CDVideoScrollerCell.swift
//  MyRule
//
//  Created by changdong on 2019/5/12.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit
import AVFoundation
class CDVideoScrollerCell: UICollectionViewCell {

    var videoSizeL:UILabel!
    var videoTap:UITapGestureRecognizer?
    var videoView:CDVideoPlayerView!


    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
        
        videoView = CDVideoPlayerView(frame: self.bounds)
        self.addSubview(videoView)

        videoSizeL = UILabel(frame: CGRect(x: videoView.frame.width-100, y: 5, width: 85, height: 20))
        videoSizeL.textAlignment = .right
        videoSizeL.font = .small
        videoSizeL.textColor = UIColor.white
        videoView.addSubview(videoSizeL)
        videoSizeL.isHidden = true

    }


    func setVideoToView(fileInfo:CDSafeFileInfo) {

        videoView.videoPath = String.RootPath().appendingPathComponent(str: fileInfo.filePath)
        videoSizeL.text = GetSizeFormat(fileSize: fileInfo.fileSize)

    }
    
    func stopPlayer() {
        videoView.dellocPlayer()
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
