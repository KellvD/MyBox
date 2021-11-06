//
//  CDTextMessageViewController.swift
//  MyRule
//
//  Created by changdong on 2018/12/28.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit

class CDTextMessageViewController: CDBaseAllViewController {

    var fileInfo:CDSafeFileInfo!
    var textView:CDTextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = fileInfo.fileName
        
        let editItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editItemClick))
        editItem.tintColor = .white
        self.navigationItem.rightBarButtonItem = editItem

        textView = CDTextView(frame: CGRect(x: 10, y: 0, width: CDSCREEN_WIDTH - 20, height: CDViewHeight), subViewController: self)


        if CDEmojiHandle.hasEmojiWithText(text: fileInfo.fileText) {
            
        }else{
             textView.text = fileInfo.fileText
        }

        textView.isEditable = false
    }
    
    @objc func editItemClick(){
        textView.isEditable = true
        textView.becomeFirstResponder()
        let editItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveItemClick))
        editItem.tintColor = .white
        self.navigationItem.rightBarButtonItem = editItem
        
    }

    @objc func saveItemClick(){
        
        textView.resignFirstResponder()
        let contentStr:String = textView.text.removeSpaceAndNewline()
        if contentStr.isEmpty{
            CDHUDManager.shared.showText("尚未输入内容".localize)
            return
        }
        let fileName = contentStr.count > 6 ? contentStr.subString(to: 6) : contentStr
    

        fileInfo.fileName = fileName
        fileInfo.fileText = contentStr
        fileInfo.modifyTime = GetTimestamp(nil)
        CDSqlManager.shared.updateOneSafeFileInfo(fileInfo: fileInfo)
        CDHUDManager.shared.showComplete("编辑成功！")
        self.navigationController?.popViewController(animated: true)
        
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
