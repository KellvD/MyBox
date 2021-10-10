//
//  CDAudioRecordViewController.swift
//  MyRule
//
//  Created by changdong on 2019/1/1.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit

class CDAudioRecordViewController: CDBaseAllViewController,CDAudioManagerDelegate {

    public var folderId = 0
    private var cancleBtn:UIButton!
    private var saveBtn:UIButton!
    private var recordBtn:UIButton!
    private var leftFirstLine:UIImageView!
    private var rightFirstLine:UIImageView!
    private var leftSecondLine:UIImageView!
    private var rightSecondLine:UIImageView!
    private var textField:UITextField!
    private var circleView:CDCircleProcess!
    private var lineTimer:Timer!
    private var newFilePath:String!
    private var hasRechedMaxTimeLength:Bool!
    private var timerCount:Int = 0
    private let max_Time = 60 * 20
    private var audioManager:CDAudioManager!
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

        self.title = "录音".localize
        configUI()
        CDSignalTon.shared.isViewDisappearStopRecording = true

    }
    func configUI() {

        let breakLine = UIView(frame: CGRect(x: 0.0, y: (CDViewHeight - 64.0) * 0.6, width: CDSCREEN_WIDTH, height: 1.0))
        breakLine.backgroundColor = UIColor(red: 225/225.0, green: 225/225.0, blue: 225/225.0, alpha: 1)
        self.view.addSubview(breakLine)

        self.leftFirstLine = UIImageView(frame: CGRect(x: -CDSCREEN_WIDTH, y: 35.0, width: CDSCREEN_WIDTH + 1, height: CDSCREEN_WIDTH * 70 / 750))
        leftFirstLine.image = LoadImage("record_line1")
        leftFirstLine.isHidden = true
        self.view.addSubview(leftFirstLine)

        self.leftSecondLine = UIImageView(frame: CGRect(x: -CDSCREEN_WIDTH, y: 35.0, width: CDSCREEN_WIDTH + 1, height: CDSCREEN_WIDTH * 104 / 750))
        leftSecondLine.image = LoadImage("record_line2")
        leftSecondLine.isHidden = true
        self.view.addSubview(leftSecondLine)

        self.rightFirstLine = UIImageView(frame: CGRect(x: 0.0, y: 35.0, width: CDSCREEN_WIDTH + 1, height: CDSCREEN_WIDTH * 70 / 750))
        rightFirstLine.image = LoadImage("record_line1")
        rightFirstLine.isHidden = true
        self.view.addSubview(rightFirstLine)

        self.rightSecondLine = UIImageView(frame: CGRect(x: 0, y: 35.0, width: CDSCREEN_WIDTH + 1, height: CDSCREEN_WIDTH * 104 / 750))
        rightSecondLine.image = LoadImage("record_line2")
        rightSecondLine.isHidden = true
        self.view.addSubview(rightSecondLine)

        self.circleView = CDCircleProcess(frame: CGRect(x: CDSCREEN_WIDTH/2 - 132.0/2, y: 100, width: 132.0, height: 132.0))
        self.circleView.textLabel.text = "00:00"
        self.view.addSubview(circleView)

        self.recordBtn = UIButton(type: .custom)
        recordBtn.frame = CGRect(x: CDSCREEN_WIDTH/2 - 83/2, y: (CDViewHeight - 64.0) * 0.6 + (CDViewHeight - 64.0) * 0.4 / 2 - 83.0 / 2 - 5.0, width: 83.0, height: 83.0)
        recordBtn.setImage(LoadImage("record_unrecord"), for: .normal)
        recordBtn.setImage(LoadImage("record_recording"), for: .selected)
        recordBtn.addTarget(self, action: #selector(startRecordClick), for: .touchUpInside)
        self.view.addSubview(recordBtn)

        self.saveBtn = UIButton(type: .custom)
        saveBtn.frame = CGRect(x: CDSCREEN_WIDTH - 90.0, y: recordBtn.frame.minY + 83.0/2 - 60.0/2, width: 50, height: 50)
        saveBtn.setImage(LoadImage("record_sure"), for: .normal)
        saveBtn.setImage(LoadImage("record_sure_grey"), for: .disabled)
        saveBtn.isEnabled = false
        saveBtn.addTarget(self, action: #selector(finishRecordClick), for: .touchUpInside)
        self.view.addSubview(saveBtn)

        self.cancleBtn = UIButton(type: .custom)
        cancleBtn.frame = CGRect(x: 40.0, y: recordBtn.frame.minY + 83.0/2 - 60.0/2, width: 50, height: 50)
        cancleBtn.setImage(LoadImage("record_cancle"), for: .normal)
        cancleBtn.setImage(LoadImage("record_cancle_grey"), for: .disabled)
        cancleBtn.isEnabled = false
        cancleBtn.addTarget(self, action: #selector(cancleReocrdClick), for: .touchUpInside)
        self.view.addSubview(cancleBtn)
    }

    @objc func cancleReocrdClick() {
        if circleView.gProgress > 0.0 {
            let alert = UIAlertController(title: "警告".localize, message: "您要放弃本次录音么？".localize, preferredStyle: .alert)
        
            alert.addAction(UIAlertAction(title: "否".localize, style: .cancel, handler: { (action) in }))
            alert.addAction(UIAlertAction(title: "是".localize, style: .default, handler: { (action) in
                self.recordStop()
                self.newFilePath.delete()
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)

        }
    }
    func recordStart() {
        audioManager.start()
        cancleBtn.isEnabled = false
        saveBtn.isEnabled = false
        recordBtn.isSelected = true
    }
    func recordPause(){
        audioManager.pause()
        cancleBtn.isEnabled = true
        saveBtn.isEnabled = true
        recordBtn.isSelected = false
    }
    func recordStop(){
        audioManager.stop()
    }
    
    @objc func finishRecordClick() {

        let alert = UIAlertController(title: "存储语音".localize, message: "语音名称不能超过30个字符".localize, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "否".localize, style: .cancel, handler: { (action) in }))
        alert.addTextField { (textFil) in
            textFil.text = "未命名".localize
            self.textField = textFil

        }
        alert.addAction(UIAlertAction(title: "是".localize, style: .default, handler: { (action) in

            if self.textField != nil{
                let tmpStr = self.textField.text!
                let len = tmpStr.getLength(needTrimSpaceCheck: true)
                if len > 30 {
                    CDHUDManager.shared.showText("语音名称不能超过30个字符".localize)
                    return
                }
                self.recordStop()
                self.textField.resignFirstResponder()
                let audioPath = String.AudioPath().appendingPathComponent(str:"\(tmpStr).aac")

                //从录音路劲拷贝到重命名路径
                try! FileManager.default.copyItem(atPath: self.newFilePath, toPath: audioPath)
                try! FileManager.default.removeItem(atPath: self.newFilePath)
                CDSignalTon.shared.saveFileWithUrl(fileUrl: audioPath.url, folderId: self.folderId, subFolderType: .AudioFolder,isFromDocment: false)
                
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
                DispatchQueue.main.async { [self] in
                    if self.audioManager != nil{
                        if self.audioManager.isRecording {
                            self.recordPause()
                        }else{
                            self.recordStart()
                        }
                        
                    }else{
                        self.newFilePath = String.AudioPath().appendingPathComponent(str: "\(GetTimestamp(nil)).aac")
                        self.audioManager = CDAudioManager(audioUrl: self.newFilePath.url, delay: 0.1, model: .record, delegate: self)
                        self.recordStart()
                    }
                }
            }else{
                openPermission(type: .micorphone, viewController: self)
            }
        }
    }

    func audioManagerTimerUpdate(current: Double) {
        timerCount += 1
        if timerCount == 10 {
            timerCount = 0
            let timeLength = Int(current)
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
        if audioManager.isRecording {
            leftFirstLine.minX += 30.0
            leftSecondLine.minX += 30.0
            
            rightFirstLine.minX += 30.0
            rightSecondLine.minX += 30.0

            if leftFirstLine.minX > 0.0 && leftFirstLine.minX < CDSCREEN_WIDTH{

                rightFirstLine.minX = leftFirstLine.minX - CDSCREEN_WIDTH + 1.0
                rightSecondLine.minX = leftFirstLine.minX - CDSCREEN_WIDTH + 1.0
            }

            if rightFirstLine.minX > 0.0 && rightFirstLine.minX < CDSCREEN_WIDTH{

                leftFirstLine.minX = rightFirstLine.minX - CDSCREEN_WIDTH + 1.0
                leftSecondLine.minX = rightFirstLine.minX - CDSCREEN_WIDTH + 1.0

            }

        }

    }
}
