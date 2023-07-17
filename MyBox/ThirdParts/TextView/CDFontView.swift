//
//  CDFontView.swift
//  CDTextViewDemo
//
//  Created by changdong on 2020/9/9.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit

class CDFontView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {

    private var fontView: UIPickerView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .baseBgColor
        fontView = UIPickerView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height - 48))
        fontView.delegate = self
        fontView.dataSource = self
        self.addSubview(fontView)
        fontView.selectRow(2, inComponent: 0, animated: false)
        fontView.selectRow(10, inComponent: 1, animated: false)

        let button = UIButton(type: .custom)
        button.setTitle("确定".localize, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(onHandleFontConfig(sender:)), for: .touchUpInside)
        button.layer.cornerRadius = 10
        self.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.centerX.equalTo(frame.width/2 )
            make.size.equalTo(CGSize(width: 60, height: 48))
        }

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy private var fontArr: [[String]] = {
        let arr = [["楷体", "简体", "草书", "违背楷体"],
                   ["9", "10", "11", "12", "13", "14", "18", "24", "36", "48", "64"]]
        return arr
    }()

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return fontArr.count
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return fontArr[component].count
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 48
    }

    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return component == 0 ? frame.width / 3 * 2 : frame.width / 3
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return fontArr[component][row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            CDTextViewConfig.share.fontName = fontArr[0][row]
        } else {
            CDTextViewConfig.share.fontSize = fontArr[1][row]
        }
        CDTextViewConfig.share.updateTextView()
    }

    @objc func onHandleFontConfig(sender: UIButton) {

        CDTextViewConfig.share.removeInputView(view: self)

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeFont"), object: nil)

    }

}
