//
//  CDNewTextViewController.swift
//  MyRule
//
//  Created by changdong on 2018/12/28.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit


class CDNewTextViewController: CDBaseAllViewController,UITextViewDelegate {

    var textView:CDTextView!
    var menuView:UIToolbar!
    var folderId = 0


    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "新文本"
        self.view.backgroundColor = UIColor.white
        let doneBtn = UIButton(type: .custom)
        doneBtn.frame = CGRect(x: 0, y: 0, width: 60, height: 44)
        doneBtn.setTitle("保存", for: .normal)
        doneBtn.addTarget(self, action: #selector(saveBtnClick), for: .touchUpInside)
        doneBtn.setTitleColor(UIColor.white, for: .normal)
        doneBtn.contentHorizontalAlignment = .right
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneBtn)

        textView = CDTextView(frame: CGRect(x: 10, y: 0, width: CDSCREEN_WIDTH - 20, height: CDViewHeight), subViewController: self)
        
        textView.becomeFirstResponder()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notic:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notic:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notic:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

    }



    @objc func saveBtnClick(sender:UIButton){
        let contentStr:String = textView.text.removeSpaceAndNewline()
        if contentStr.isEmpty{
            CDHUDManager.shared.showText(text: "啥也没写呢")
            return
        }
        sender.isUserInteractionEnabled = false
        textView.resignFirstResponder()
        var fileName = contentStr
        fileName = contentStr.count > 6 ? contentStr.AsNSString().substring(to: 6) : contentStr
        let fileInfo:CDSafeFileInfo = CDSafeFileInfo()
        fileInfo.userId = CDUserId()
        fileInfo.folderId = folderId
        fileInfo.fileName = fileName
        fileInfo.createTime = GetTimestamp()
        fileInfo.modifyTime = GetTimestamp()
        fileInfo.accessTime = GetTimestamp()
        fileInfo.fileType = NSFileType.PlainTextType
        CDSqlManager.shared.addSafeFileInfo(fileInfo: fileInfo)
        self.navigationController?.popViewController(animated: true);
    }


    //MARK:UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if menuView == nil {
            menuView = UIToolbar(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: 44))
            menuView.barStyle = .default

            let pasteBtn = UIButton(type: .custom)
            pasteBtn.frame = CGRect(x: 0, y: 0, width: 60, height: 44)
            pasteBtn.setTitle("粘贴", for: .normal)
            pasteBtn.setTitleColor(CustomBlueColor, for: .normal)
            pasteBtn.addTarget(self, action: #selector(readFromPasteboard), for: .touchUpInside)
            pasteBtn.setTitleColor(UIColor.white, for: .normal)
            pasteBtn.contentHorizontalAlignment = .right
            let pastrItem = UIBarButtonItem(customView: pasteBtn)

            let space = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

            let doneBtn = UIButton(type: .custom)
            doneBtn.frame = CGRect(x: 0, y: 0, width: 60, height: 44)
            doneBtn.setTitle("完成", for: .normal)
            doneBtn.setTitleColor(CustomBlueColor, for: .normal)
            doneBtn.addTarget(self, action: #selector(disKeyBoard), for: .touchUpInside)
            doneBtn.setTitleColor(UIColor.white, for: .normal)
            doneBtn.contentHorizontalAlignment = .right
            let doneItem = UIBarButtonItem(customView: doneBtn)
            menuView.setItems([pastrItem,space,doneItem], animated: true)


        }
    }

    @objc func readFromPasteboard(){
        let pasteStr = UIPasteboard.general.string!
        textView.text = textView.text + pasteStr


    }

    @objc func disKeyBoard(){

        textView.resignFirstResponder()
    }


    @objc func keyboardWillShow(notic:Notification){


    }
    @objc func keyboardWillHide(notic:Notification){


    }


    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }



}
