//
//  CDAudioRecordViewController.swift
//  MyRule
//
//  Created by changdong on 2019/1/1.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

@objc protocol CDRecordSuccessDelegate {
    @objc optional func reloadAudioList()
}

class CDAudioRecordViewController: CDBaseAllViewController {

    var cancleBtn:UIButton!
    var saveBtn:UIButton!
    var recordBtn:UIButton!
    var timeLabel:UILabel!

    var leftFirstLine:UIImageView!
    var rightFirstLine:UIImageView!
    var leftSecondLine:UIImageView!
    var rightSecondLine:UIImageView!
    var textField:UITextField!
    var circleView:CDCircleView!

    var lineTimer:Timer!
    var isReocrding:Bool = false
    var isPause:Bool = false
    var createTime:Int!
    var hasRechedMaxTimeLength:Bool!
    var recorder:AVAudioRecorder!

    var timerCount:Int = 0
    var folderId = 0



    weak var audioDelete:CDRecordSuccessDelegate?

    let max_Time = 60 * 60

    deinit {
        self.cancleBtn = nil
        self.saveBtn = nil
        self.recordBtn = nil
        self.timeLabel = nil
        self.leftFirstLine = nil
        self.leftSecondLine = nil
        self.rightFirstLine = nil
        self.rightSecondLine = nil
        self.circleView = nil
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.leftFirstLine.isHidden = false
        self.leftSecondLine.isHidden = false
        self.rightFirstLine.isHidden = false
        self.rightSecondLine.isHidden = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.leftFirstLine.isHidden = true
        self.leftSecondLine.isHidden = true
        self.rightFirstLine.isHidden = true
        self.rightSecondLine.isHidden = true
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if CDSignalTon.shareInstance().isViewDisappearStopRecording {
            stopRecord()
        }
        CDSignalTon.shareInstance().isViewDisappearStopRecording = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "录音"
        configUI()
        createTime = getCurrentTimestamp()
        CDSignalTon.shareInstance().isViewDisappearStopRecording = true

    }
    func configUI() {

        let breakLine = UIView(frame: CGRect(x: 0.0, y: (CDViewHeight - 64.0) * 0.6, width: CDSCREEN_WIDTH, height: 1.0))
        breakLine.backgroundColor = UIColor(red: 225/225.0, green: 225/225.0, blue: 225/225.0, alpha: 1)
        self.view.addSubview(breakLine)

        self.leftFirstLine = UIImageView(frame: CGRect(x: -CDSCREEN_WIDTH, y: 35.0, width: CDSCREEN_WIDTH + 1, height: CDSCREEN_WIDTH * 70 / 750))
        leftFirstLine.image = LoadImageByName(imageName: "record_line1", type: "png")
        leftFirstLine.isHidden = true
        self.view.addSubview(leftFirstLine)

        self.leftSecondLine = UIImageView(frame: CGRect(x: -CDSCREEN_WIDTH, y: 35.0, width: CDSCREEN_WIDTH + 1, height: CDSCREEN_WIDTH * 104 / 750))
        leftSecondLine.image = LoadImageByName(imageName: "record_line2", type: "png")
        leftSecondLine.isHidden = true
        self.view.addSubview(leftSecondLine)

        self.rightFirstLine = UIImageView(frame: CGRect(x: 0.0, y: 35.0, width: CDSCREEN_WIDTH + 1, height: CDSCREEN_WIDTH * 70 / 750))
        rightFirstLine.image = LoadImageByName(imageName: "record_line1", type: "png")
        rightFirstLine.isHidden = true
        self.view.addSubview(rightFirstLine)

        self.rightSecondLine = UIImageView(frame: CGRect(x: 0, y: 35.0, width: CDSCREEN_WIDTH + 1, height: CDSCREEN_WIDTH * 104 / 750))
        rightSecondLine.image = LoadImageByName(imageName: "record_line2", type: "png")
        rightSecondLine.isHidden = true
        self.view.addSubview(rightSecondLine)

        let timeProgress = UIImageView(frame: CGRect(x: CDSCREEN_WIDTH/2 - 132.0/2, y: 100, width: 132.0, height: 132.0))
        timeProgress.image = LoadImageByName(imageName: "record_timeProgressBG", type: "png")
        self.view.addSubview(timeProgress)

        self.circleView = CDCircleView(frame: CGRect(x: timeProgress.frame.minX, y: timeProgress.frame.minY, width: 132.0, height: 132.0))
        self.view.addSubview(circleView)

        self.timeLabel = UILabel(frame: CGRect(x: timeProgress.frame.minX + 132/2 - 90/2, y: timeProgress.frame.minY + 132.0/2 - 50.0/2, width: 90.0, height: 50.0))
        timeLabel.font = UIFont.systemFont(ofSize: 32.0)
        timeLabel.textColor = UIColor(red: 120/225.0, green: 120/225.0, blue: 120/225.0, alpha: 1)
        timeLabel.text = "00:00"
        timeLabel.textAlignment = .center
        self.view.addSubview(timeLabel)



        self.recordBtn = UIButton(type: .custom)
        recordBtn.frame = CGRect(x: CDSCREEN_WIDTH/2 - 83/2, y: (CDViewHeight - 64.0) * 0.6 + (CDViewHeight - 64.0) * 0.4 / 2 - 83.0 / 2 - 5.0, width: 83.0, height: 83.0)
        recordBtn.setBackgroundImage(LoadImageByName(imageName: "record_unrecord", type: "png"), for: .normal)
        recordBtn.addTarget(self, action: #selector(startRecordClick), for: .touchUpInside)
        self.view.addSubview(recordBtn)

        self.saveBtn = UIButton(type: .custom)
        saveBtn.frame = CGRect(x: CDSCREEN_WIDTH - 90.0, y: recordBtn.frame.minY + 83.0/2 - 60.0/2, width: 50, height: 50)
        saveBtn.setBackgroundImage(LoadImageByName(imageName: "ic_safe_save_recording_unclickable", type: "png"), for: .normal)
        saveBtn.isEnabled = false
        saveBtn.alpha = 0.5
        saveBtn.addTarget(self, action: #selector(finishRecordClick), for: .touchUpInside)
        self.view.addSubview(saveBtn)

        self.cancleBtn = UIButton(type: .custom)
        cancleBtn.frame = CGRect(x: 40.0, y: recordBtn.frame.minY + 83.0/2 - 60.0/2, width: 50, height: 50)
        cancleBtn.setBackgroundImage(LoadImageByName(imageName: "ic_safe_cancel_unclickable", type: "png"), for: .normal)
        cancleBtn.isEnabled = false
        cancleBtn.alpha = 0.5
        cancleBtn.addTarget(self, action: #selector(cancleReocrdClick), for: .touchUpInside)
        self.view.addSubview(cancleBtn)
    }

    @objc func cancleReocrdClick() {
        if circleView.progress > 0.0 {
            let alert = UIAlertController(title: "tips", message: "你要放弃本次录音么？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "否", style: .cancel, handler: { (action) in
            }))
            alert.addAction(UIAlertAction(title: "是", style: .default, handler: { (action) in
                self.stopRecord()
                self.deleteRecord()
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)

        }
    }
    func stopRecord(){

        recorder?.stop()
        stopTimer()

    }
    func deleteRecord() {

        let createFileName = String(format: "%ld.aac", createTime)
        let tmpAudioPath = String.AudioPath().appendingPathComponent(str: createFileName)
        fileManagerDeleteFileWithFilePath(filePath: tmpAudioPath)
    }
    @objc func finishRecordClick() {

        let alert = UIAlertController(title: "存储语音", message: "语音名称不能超过30个字符", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "否", style: .cancel, handler: { (action) in
        }))
        alert.addTextField { (textFil) in
            textFil.text = "未命名"
            self.textField = textFil

        }
        alert.addAction(UIAlertAction(title: "是", style: .default, handler: { (action) in

            if self.textField != nil{
                let tmpStr = self.textField.text!
                let len = getLengthOfStr(text: tmpStr, needTrimSpaceCheck: true)
                if len > 60 {
                    CDHUD.showText(text: "文件名不能超过28个字符")
                }
                self.textField.resignFirstResponder()
                self.isReocrding = false
                let fileName = String(format: "%ld.aac", self.createTime)
                let tmpAudioPath = String.AudioPath().appendingPathComponent(str: fileName)
                let audioPath = String.AudioPath().appendingPathComponent(str: fileName)

                let timeLen = getTimeLenWithVideoPath(path: tmpAudioPath)

                let fileInfo:CDSafeFileInfo = CDSafeFileInfo()
                fileInfo.userId = CDUserId()
                fileInfo.folderId = self.folderId
                fileInfo.fileName = tmpStr
                fileInfo.filePath = String.changeFilePathAbsoluteToRelectivepPath(absolutePath: audioPath )
                fileInfo.fileSize = getFileSizeAtPath(filePath: audioPath)
                fileInfo.createTime = self.createTime
                fileInfo.fileType = .AudioType
                fileInfo.timeLength = timeLen
                CDSqlManager.instance().addSafeFileInfo(fileInfo: fileInfo)

                self.audioDelete?.reloadAudioList!()
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)

                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    @objc func startRecordClick(){
        if isReocrding {
            stopRecord()
            cancleBtn.setBackgroundImage(LoadImageByName(imageName: "ic_safe_cancel_clickable", type: "png"), for: .normal)
            saveBtn.setBackgroundImage(LoadImageByName(imageName: "ic_safe_save_recording_clickable", type: "png"), for: .normal)
            cancleBtn.isEnabled = true
            saveBtn.isEnabled = true

            cancleBtn.alpha = 1.0
            saveBtn.alpha = 1.0
            isReocrding = false
            isPause = true
            recordBtn.setBackgroundImage(LoadImageByName(imageName: "record_unrecord", type: "png"), for: .normal)
            recordBtn.isEnabled = false

        }else{
            createTime = getCurrentTimestamp()
            let createFileName = String(format: "%ld.aac", createTime)
            let tmpAudioUrl = String.AudioPath().appendingPathComponent(str: createFileName)
            do{
                try AVAudioSession.sharedInstance().setCategory(.playAndRecord)
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
                try AVAudioSession.sharedInstance().setActive(true)
            }catch{

            }
            let dict = [AVFormatIDKey:NSNumber(value: kAudioFormatMPEG4AAC),
                        AVSampleRateKey:NSNumber(value: 8000),
                        AVNumberOfChannelsKey:NSNumber(value: 1),
                        AVLinearPCMBitDepthKey:NSNumber(value: 16),
                        AVEncoderAudioQualityKey:NSNumber(value: AVAudioQuality.high.rawValue),
                        AVLinearPCMIsFloatKey:NSNumber(value: true)]

            do{
                try recorder = AVAudioRecorder(url: URL.init(string: tmpAudioUrl)!, settings:dict)
            }catch{

            }
            recorder.isMeteringEnabled = true
            recorder.prepareToRecord()
//            let audioRoutOverride = kAudioSessionOverrideAudioRoute_Speaker
//            AudioSessionSetProperty(k)
            recorder.record()
            startTimer()
            cancleBtn.setBackgroundImage(LoadImageByName(imageName: "ic_safe_cancel_unclickable", type: "png"), for: .normal)
            saveBtn.setBackgroundImage(LoadImageByName(imageName: "ic_safe_save_recording_unclickable", type: "png"), for: .normal)
            cancleBtn.isEnabled = false
            saveBtn.isEnabled = false
            cancleBtn.alpha = 0.5
            saveBtn.alpha = 0.5
            isReocrding = true
            recordBtn.setBackgroundImage(LoadImageByName(imageName: "record_recording", type: "png"), for: .normal)
        }
    }


    func startTimer(){

        if lineTimer == nil {
            lineTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(controllerMove), userInfo: nil, repeats: true)
        }
    }

    func stopTimer() {
        if lineTimer != nil{
            lineTimer.invalidate()
            lineTimer = nil
        }
    }

    @objc func controllerMove(){

        timerCount += 1
        if timerCount == 20 {
            timerCount = 0
            let timeLength = Int(recorder.currentTime)
            let hours = Int(timeLength / 3600)
            let minutes = Int((timeLength - hours * 3600 ) / 60)
            let seconds = Int(timeLength - hours * 3600 - minutes * 60)

            timeLabel.text = String(format:"%.2d:%.2d", minutes, seconds)


            if timeLength > max_Time {
                startRecordClick()

            }

            self.circleView.changeProgress(progr:Double(timeLength) / Double(max_Time))
        }

        if leftFirstLine.isHidden {
            leftFirstLine.isHidden = false
        }
        if leftSecondLine.isHidden {
            leftSecondLine.isHidden = false
        }
        if isReocrding {
            var rect = leftFirstLine.frame
            rect.origin.x += 30.0
            leftFirstLine.frame = rect

            rect = leftSecondLine.frame
            rect.origin.x += 30.0
            leftSecondLine.frame = rect

            rect = rightFirstLine.frame
            rect.origin.x += 30.0
            rightFirstLine.frame = rect

            rect = rightSecondLine.frame
            rect.origin.x += 30.0
            rightSecondLine.frame = rect

            if leftFirstLine.frame.origin.x > 0.0 && leftFirstLine.frame.origin.x < CDSCREEN_WIDTH{

                rect = rightFirstLine.frame
                rect.origin.x = leftFirstLine.frame.origin.x - CDSCREEN_WIDTH + 1.0
                rightFirstLine.frame = rect

                rect = rightSecondLine.frame
                rect.origin.x = leftFirstLine.frame.origin.x - CDSCREEN_WIDTH + 1.0
                rightSecondLine.frame = rect
            }

            if rightFirstLine.frame.origin.x > 0.0 && rightFirstLine.frame.origin.x < CDSCREEN_WIDTH{

                rect = leftFirstLine.frame
                rect.origin.x = rightFirstLine.frame.origin.x - CDSCREEN_WIDTH + 1.0
                leftFirstLine.frame = rect

                rect = leftSecondLine.frame
                rect.origin.x = rightFirstLine.frame.origin.x - CDSCREEN_WIDTH + 1.0
                leftSecondLine.frame = rect
            }

        }

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
