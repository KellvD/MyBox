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

        let seprtorViewFirst = UIView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: 15))
        seprtorViewFirst.backgroundColor = SeparatorGrayColor
        view.addSubview(seprtorViewFirst)

        noteTextView = UITextView(frame: CGRect(x: 5, y: 15, width: CDSCREEN_WIDTH - 10, height: 150))
        view.addSubview(noteTextView)
        noteTextView.delegate = self
        noteTextView.font = TextMidFont
        noteTextView.text = oldContent

        noteTextView.becomeFirstResponder()
        let seprtorViewLast = UIView(frame: CGRect(x: 0, y: noteTextView.frame.maxY, width: CDSCREEN_WIDTH, height: 1))
        seprtorViewLast.backgroundColor = SeparatorGrayColor
        view.addSubview(seprtorViewLast)

        let infoLength = oldContent.getLength(needTrimSpaceCheck: true)
        remainNumberLabel = UILabel(frame: CGRect(x: 0, y: noteTextView.frame.maxY, width: CDSCREEN_WIDTH, height: 20));
        remainNumberLabel.text = "\(infoLength)/\(maxTextCount)"
        remainNumberLabel.textAlignment = .right
        remainNumberLabel.textColor = CustomBlueColor
        view.addSubview(remainNumberLabel)

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "确定", style: .plain, target: self, action: #selector(onSureBtnClick))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white

    }

    @objc func onSureBtnClick(){
        var tmpStr = noteTextView.text
        let len = tmpStr?.getLength(needTrimSpaceCheck: true)


        if len! > maxTextCount {
            CDHUDManager.shared.showText(text: "输入字符长度不能超过\(maxTextCount)个字符")
            return
        }
        remainNumberLabel.text = "\(len ?? 0)/\(maxTextCount)"

        if markType  == .fileName || markType  == .folderName{
            tmpStr = noteTextView.text.removeSpaceAndNewline()
            if oldContent.count == 0{
                CDHUDManager.shared.showText(text: "文件名不能为空")
                return
            }

            if(oldContent.matches(pattern: symbolExpression) ||
                oldContent.isContainsEmoji()){
                let alert = UIAlertController(title: nil, message: "名称中不能包含表情及字符", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "知道了", style: .cancel, handler: nil))
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


}
