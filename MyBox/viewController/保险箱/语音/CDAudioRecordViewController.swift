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



class CDAudioRecordViewController: CDBaseAllViewController {

    public var folderId = 0
    private var cancleBtn:UIButton!
    private var saveBtn:UIButton!
    private var recordBtn:UIButton!
    private var leftFirstLine:UIImageView!
    private var rightFirstLine:UIImageView!
    private var leftSecondLine:UIImageView!
    private var rightSecondLine:UIImageView!
    private var textField:UITextField!
    var circleView:CDCircleProcess!
    private var lineTimer:Timer!
    private var newFilePath:String!
    private var hasRechedMaxTimeLength:Bool!
    private var recorder:AVAudioRecorder!
    private var timerCount:Int = 0
    private let max_Time = 60 * 20

    deinit {
        self.cancleBtn = nil
        self.saveBtn = nil
        self.recordBtn = nil
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
        if CDSignalTon.shared.isViewDisappearStopRecording {
            recordStop()
        }
        CDSignalTon.shared.isViewDisappearStopRecording = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "录音"
        configUI()
        CDSignalTon.shared.isViewDisappearStopRecording = true

    }
    func configUI() {

        let breakLine = UIView(frame: CGRect(x: 0.0, y: (CDViewHeight - 64.0) * 0.6, width: CDSCREEN_WIDTH, height: 1.0))
        breakLine.backgroundColor = UIColor(red: 225/225.0, green: 225/225.0, blue: 225/225.0, alpha: 1)
        self.view.addSubview(breakLine)

        self.leftFirstLine = UIImageView(frame: CGRect(x: -CDSCREEN_WIDTH, y: 35.0, width: CDSCREEN_WIDTH + 1, height: CDSCREEN_WIDTH * 70 / 750))
        leftFirstLine.image = LoadImage(imageName: "record_line1", type: "png")
        leftFirstLine.isHidden = true
        self.view.addSubview(leftFirstLine)

        self.leftSecondLine = UIImageView(frame: CGRect(x: -CDSCREEN_WIDTH, y: 35.0, width: CDSCREEN_WIDTH + 1, height: CDSCREEN_WIDTH * 104 / 750))
        leftSecondLine.image = LoadImage(imageName: "record_line2", type: "png")
        leftSecondLine.isHidden = true
        self.view.addSubview(leftSecondLine)

        self.rightFirstLine = UIImageView(frame: CGRect(x: 0.0, y: 35.0, width: CDSCREEN_WIDTH + 1, height: CDSCREEN_WIDTH * 70 / 750))
        rightFirstLine.image = LoadImage(imageName: "record_line1", type: "png")
        rightFirstLine.isHidden = true
        self.view.addSubview(rightFirstLine)

        self.rightSecondLine = UIImageView(frame: CGRect(x: 0, y: 35.0, width: CDSCREEN_WIDTH + 1, height: CDSCREEN_WIDTH * 104 / 750))
        rightSecondLine.image = LoadImage(imageName: "record_line2", type: "png")
        rightSecondLine.isHidden = true
        self.view.addSubview(rightSecondLine)

        self.circleView = CDCircleProcess(frame: CGRect(x: CDSCREEN_WIDTH/2 - 132.0/2, y: 100, width: 132.0, height: 132.0))
        self.circleView.textLabel.text = "00:00"
        self.view.addSubview(circleView)

        self.recordBtn = UIButton(type: .custom)
        recordBtn.frame = CGRect(x: CDSCREEN_WIDTH/2 - 83/2, y: (CDViewHeight - 64.0) * 0.6 + (CDViewHeight - 64.0) * 0.4 / 2 - 83.0 / 2 - 5.0, width: 83.0, height: 83.0)
        recordBtn.setImage(LoadImage(imageName: "record_unrecord", type: "png"), for: .normal)
        recordBtn.setImage(LoadImage(imageName: "record_recording", type: "png"), for: .selected)
        recordBtn.addTarget(self, action: #selector(startRecordClick), for: .touchUpInside)
        self.view.addSubview(recordBtn)

        
        
        self.saveBtn = UIButton(type: .custom)
        saveBtn.frame = CGRect(x: CDSCREEN_WIDTH - 90.0, y: recordBtn.frame.minY + 83.0/2 - 60.0/2, width: 50, height: 50)
        saveBtn.setImage(LoadImage(imageName: "record_sure", type: "png"), for: .normal)
        saveBtn.setImage(LoadImage(imageName: "record_sure_grey", type: "png"), for: .disabled)
        saveBtn.isEnabled = false
        saveBtn.addTarget(self, action: #selector(finishRecordClick), for: .touchUpInside)
        self.view.addSubview(saveBtn)

        self.cancleBtn = UIButton(type: .custom)
        cancleBtn.frame = CGRect(x: 40.0, y: recordBtn.frame.minY + 83.0/2 - 60.0/2, width: 50, height: 50)
        cancleBtn.setImage(LoadImage(imageName: "record_cancle", type: "png"), for: .normal)
        cancleBtn.setImage(LoadImage(imageName: "record_sure_grey", type: "png"), for: .disabled)
        cancleBtn.isEnabled = false
        cancleBtn.addTarget(self, action: #selector(cancleReocrdClick), for: .touchUpInside)
        self.view.addSubview(cancleBtn)
    }

    @objc func cancleReocrdClick() {
        if circleView.gProgress > 0.0 {
            let alert = UIAlertController(title: "警告", message: "您要放弃本次录音么？", preferredStyle: .alert)
        
            alert.addAction(UIAlertAction(title: "否", style: .cancel, handler: { (action) in }))
            alert.addAction(UIAlertAction(title: "是", style: .default, handler: { (action) in
                self.recordStop()
                DeleteFile(filePath: self.newFilePath)
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)

        }
    }
    func recordStart() {
        recorder.record()
        lineTimer.fireDate = .distantPast
        cancleBtn.isEnabled = false
        saveBtn.isEnabled = false
        recordBtn.isSelected = true
    }
    func recordPause(){
        recorder.pause()
        lineTimer.fireDate = .distantFuture
        cancleBtn.isEnabled = true
        saveBtn.isEnabled = true
        recordBtn.isSelected = false
    }
    func recordStop(){

        recorder?.stop()
        recorder = nil
        destoryTimer()

    }
    func destoryTimer() {
        if lineTimer != nil{
            lineTimer.invalidate()
            lineTimer = nil
        }
    }
    @objc func finishRecordClick() {

        let alert = UIAlertController(title: "存储语音", message: "语音名称不能超过30个字符", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "否", style: .cancel, handler: { (action) in }))
        alert.addTextField { (textFil) in
            textFil.text = "未命名"
            self.textField = textFil

        }
        alert.addAction(UIAlertAction(title: "是", style: .default, handler: { (action) in

            if self.textField != nil{
                let tmpStr = self.textField.text!
                let len = tmpStr.getLength(needTrimSpaceCheck: true)
                if len > 30 {
                    CDHUDManager.shared.showText(text: "文件名不能超过30个字符")
                    return
                }
                self.recordStop()
                self.textField.resignFirstResponder()
                let audioPath = String.AudioPath().appendingPathComponent(str:"\(tmpStr).aac")

                //从录音路劲拷贝到重命名路径
                try! FileManager.default.copyItem(atPath: self.newFilePath, toPath: audioPath)
                try! FileManager.default.removeItem(atPath: self.newFilePath)
                CDSignalTon.shared.saveSafeFileInfo(tmpFileUrl: URL(fileURLWithPath: audioPath), folderId: self.folderId, subFolderType: .AudioFolder)
                
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)

                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    @objc func startRecordClick(){
        checkPermission(type: .micorphone) { (isAllow) in
            if isAllow {
                DispatchQueue.main.async {
                    if self.recorder != nil && self.recorder.isRecording{
                        self.recordPause()
                    }else{
                        if self.recorder == nil { //recorder不存在，创建，存在接着录音
                            self.newFilePath = String.AudioPath().appendingPathComponent(str: "\(GetTimestamp()).aac")
                            let dict = [AVFormatIDKey:NSNumber(value: kAudioFormatMPEG4AAC),
                            AVSampleRateKey:NSNumber(value: 8000),
                            AVNumberOfChannelsKey:NSNumber(value: 1),
                            AVLinearPCMBitDepthKey:NSNumber(value: 16),
                            AVEncoderAudioQualityKey:NSNumber(value: AVAudioQuality.high.rawValue),
                            AVLinearPCMIsFloatKey:NSNumber(value: true)]
                            
                            do{
                                try AVAudioSession.sharedInstance().setCategory(.playAndRecord)
                                try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
                                try AVAudioSession.sharedInstance().setActive(true)
                                try self.recorder = AVAudioRecorder(url: URL.init(string: self.newFilePath)!, settings:dict)
                            }catch{
                                
                            }
                            
                            self.recorder.isMeteringEnabled = true
                            self.recorder.prepareToRecord()
                            
                            self.destoryTimer()
                            self.lineTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.controllerMove), userInfo: nil, repeats: true)
                            self.lineTimer.fireDate = .distantFuture
                        }
                        self.recordStart()
                    }
                }
            }else{
                openPermission(type: .micorphone, viewController: self)
            }
        }
    }

    

    @objc func controllerMove(){

        timerCount += 1
        if timerCount == 10 {
            timerCount = 0
            let timeLength = Int(recorder.currentTime)
            let hours = Int(timeLength / 3600)
            let minutes = Int((timeLength - hours * 3600 ) / 60)
            let seconds = Int(timeLength - hours * 3600 - minutes * 60)
            if timeLength > max_Time {
                startRecordClick()
            }
            self.circleView.changeProgress(progress: Double(timeLength) / Double(max_Time), text: String(format:"%.2d:%.2d", minutes, seconds))
        }
        if leftFirstLine.isHidden {
            leftFirstLine.isHidden = false
        }
        if leftSecondLine.isHidden {
            leftSecondLine.isHidden = false
        }
        if recorder.isRecording {
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
}
