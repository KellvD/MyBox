//
//  CDMarkFileViewController.swift
//  MyRule
//
//  Created by changdong on 2019/5/22.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit

enum CDMarkType:Int {
    case fileName = 1
    case fileMark = 2
    case waterInfo = 3
    case folderName = 4
}
typealias OnMarkResultHandle = (_ newContent:String?)->Void
class CDMarkFileViewController: CDBaseAllViewController,UITextViewDelegate {

    var oldContent:String! //原来的内容
    var markType:CDMarkType!
    var markHandle:OnMarkResultHandle!
    var maxTextCount:Int = 0
    private var noteTextView:UITextView!
    private var remainNumberLabel:UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .baseBgColor
        noteTextView = UITextView(frame: CGRect(x: 5, y: 15, width: CDSCREEN_WIDTH - 10, height: 150),placeHolder: LocalizedString("Please enter %@ content...", self.title!))
        view.addSubview(noteTextView)
        noteTextView.delegate = self
        noteTextView.addRadius(corners: .allCorners, size: CGSize(width: 4, height: 4))
        noteTextView.font = TextMidFont
        noteTextView.text = oldContent

        noteTextView.becomeFirstResponder()

        let infoLength = oldContent.getLength(needTrimSpaceCheck: true)
        remainNumberLabel = UILabel(frame: CGRect(x: 5, y: noteTextView.frame.maxY, width: CDSCREEN_WIDTH-10, height: 20));
        remainNumberLabel.text = "\(infoLength)/\(maxTextCount)"
        remainNumberLabel.textAlignment = .right
        remainNumberLabel.textColor = CustomBlueColor
        view.addSubview(remainNumberLabel)

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: LocalizedString("sure"), style: .plain, target: self, action: #selector(onSureBtnClick))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white

    }

    @objc func onSureBtnClick(){
        var tmpStr = noteTextView.text
        let len = tmpStr?.getLength(needTrimSpaceCheck: true)
        if len! > maxTextCount {
            CDHUDManager.shared.showText(LocalizedString("The input character length cannot exceed %@ characters", "\(maxTextCount)"))
            return
        }else if len == 0{
            CDHUDManager.shared.showText(LocalizedString("Nothing has been entered"))
            return
        }
        remainNumberLabel.text = "\(len ?? 0)/\(maxTextCount)"

        if markType  == .fileName || markType  == .folderName{
            tmpStr = noteTextView.text.removeSpaceAndNewline()
            if oldContent.count == 0{
                CDHUDManager.shared.showText(LocalizedString("File name cannot be empty"))
                return
            }

            if(oldContent.matches(pattern: symbolExpression) ||
                oldContent.isContainsEmoji()){
                let alert = UIAlertController(title: nil, message: LocalizedString("The name cannot contain emoticons and characters"), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: LocalizedString("Understood"), style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
        markHandle(tmpStr)
        self.navigationController?.popViewController(animated: true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count > 0 {
            let markedRange = textView.markedTextRange;
            if markedRange == nil ||
                markedRange!.isEmpty{
                let tmpStr = textView.text
                let len = tmpStr!.getLength(needTrimSpaceCheck: true)
                
                remainNumberLabel.text = "\(len)/\(maxTextCount)"
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text.count >= maxTextCount {
            textView.text = String(textView.text.prefix(maxTextCount))
            return false
        }
        return true
    }
}
