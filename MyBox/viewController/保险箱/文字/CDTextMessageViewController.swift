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
    var textView:UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = fileInfo.fileName

        let editItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editItemClick))
        self.navigationItem.rightBarButtonItem = editItem

        textView = UITextView(frame: CGRect(x: 10, y: 0, width: CDSCREEN_WIDTH - 20, height: CDViewHeight))
        textView.backgroundColor = UIColor.clear
        textView.font = TextMidFont
        textView.textColor = UIColor.black

        textView.layoutManager.allowsNonContiguousLayout = false
        self.view.addSubview(textView)

        if CDEmojiHandle.hasEmojiWithText(text: fileInfo.fileText) {
            
        }else{
             textView.text = fileInfo.fileText
        }

        textView.isEditable = false
    }
    @objc func editItemClick(){
        let editItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveItemClick))
        self.navigationItem.rightBarButtonItem = editItem
    }

    @objc func saveItemClick(){

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
