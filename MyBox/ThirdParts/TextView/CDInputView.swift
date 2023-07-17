//
//  CDTextStyleView.swift
//  CDTextViewDemo
//
//  Created by changdong on 2020/9/9.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit

import SnapKit

protocol CDInputViewDelegate: NSObjectProtocol {
    func removeInputView()
}
class CDInputView: UIView {

    weak var delegate: CDInputViewDelegate!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .baseBgColor

        let cancle = UIButton(type: .custom)
        cancle.setImage(UIImage(named: "cancle"), for: .normal)
        cancle.addTarget(self, action: #selector(onDismissStyleView), for: .touchUpInside)
        self.addSubview(cancle)
        cancle.snp.makeConstraints { (make) in
            make.centerY.equalTo(30)
            make.right.equalTo(-15)
            make.size.equalTo(30)
        }

        let headingWidth = (frame.width - 15 * 3 - 30)/3.0
        let bodyButton = createButton(option: .body)
        bodyButton.snp.makeConstraints { (make) in
            make.right.equalTo(cancle.snp.left).offset(-15)
            make.centerY.equalTo(30)
            make.size.equalTo(CGSize(width: headingWidth, height: 48))
        }

        bodyButton.addRadius(corners: [.topRight, .bottomRight], size: CGSize(width: 10, height: 10))

        let headingButton = createButton(option: .heading)
        headingButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.centerY.size.equalTo(bodyButton)
        }
        headingButton.addRadius(corners: [.topLeft, .bottomLeft], size: CGSize(width: 10, height: 10))

        let subheadingButton = createButton(option: .subHeading)
        subheadingButton.snp.makeConstraints { (make) in
            make.right.equalTo(bodyButton.snp.left).offset(-2)
            make.left.equalTo(headingButton.snp.right).offset(2)
            make.centerY.size.equalTo(bodyButton)
        }

        let fontSizeButton = createButton(option: .fontSize)
        fontSizeButton.layer.cornerRadius = 10
        fontSizeButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(bodyButton.snp.centerY).offset(60)
            make.size.equalTo(CGSize(width: 60, height: 48))
        }

        let fontNameButton = createButton(option: .fontName)
        fontNameButton.layer.cornerRadius = 10
        fontNameButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.centerY.height.equalTo(fontSizeButton)
            make.right.equalTo(fontSizeButton.snp.left).offset(-15)

        }

        let bgColorButton = createButton(option: .textBgColor)
        bgColorButton.layer.cornerRadius = 10
        bgColorButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(fontSizeButton.snp.centerY).offset(60)
            make.size.equalTo(CGSize(width: 60, height: 48))

        }

        let textColorButton = createButton(option: .textColor)
        textColorButton.layer.cornerRadius = 10
        textColorButton.snp.makeConstraints { (make) in
            make.centerY.size.equalTo(bgColorButton)
            make.right.equalTo(bgColorButton.snp.left).offset(-15)
        }

        let indentsWidth = (frame.width - 15 * 4 - 60 * 2)/2
        let addIndentsButton = createButton(option: .addIndents)
        addIndentsButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(textColorButton)
            make.right.equalTo(textColorButton.snp.left).offset(-15)
            make.size.equalTo(CGSize(width: indentsWidth, height: 48))
        }
        addIndentsButton.addRadius(corners: [.topRight, .bottomRight], size: CGSize(width: 10, height: 10))

        let subIndentsButton = createButton(option: .subIndents)
        subIndentsButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalTo(addIndentsButton.snp.left).offset(-2)
            make.centerY.size.equalTo(addIndentsButton)
        }
        subIndentsButton.addRadius(corners: [.topLeft, .bottomLeft], size: CGSize(width: 10, height: 10))

        let blodWidth = (frame.width - 15 * 3 - 60 - 4)/3
        let blodButton = createButton(option: .blod)
        blodButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalTo(addIndentsButton.snp.centerY).offset(60)
            make.size.equalTo(CGSize(width: blodWidth, height: 48))
        }
        blodButton.addRadius(corners: [.topLeft, .bottomLeft], size: CGSize(width: 10, height: 10))

        let italicButton = createButton(option: .italic)
        italicButton.snp.makeConstraints { (make) in
            make.left.equalTo(blodButton.snp.right).offset(2)
            make.centerY.size.equalTo(blodButton)
        }

        let underlineButton = createButton(option: .underline)
        underlineButton.snp.makeConstraints { (make) in
            make.left.equalTo(italicButton.snp.right).offset(2)
            make.centerY.size.equalTo(blodButton)
        }
        underlineButton.addRadius(corners: [.topRight, .bottomRight], size: CGSize(width: 10, height: 10))

        let signButton = createButton(option: .paragraphSymbol)
        signButton.layer.cornerRadius = 10
        signButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(blodButton)
            make.size.equalTo(CGSize(width: 60, height: 48))
        }

        NotificationCenter.default.addObserver(self, selector: #selector(onPostChangeFont), name: NSNotification.Name(rawValue: "changeFont"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onPostChangePicker), name: NSNotification.Name(rawValue: "changePickerValue"), object: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "changePickerValue"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "changeFont"), object: nil)

    }

    func createButton(option: CDTextTools) -> UIButton {
        let button = UIButton(type: .custom)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        if option == .fontSize {
            button.setTitle(CDTextViewConfig.share.fontSize, for: .normal)
        } else if option == .fontName {
            button.setTitle(CDTextViewConfig.share.fontName, for: .normal)
        } else {
            button.setImage(UIImage(named: optionArr[option.rawValue]), for: .normal)
        }
        button.tag = option.rawValue + 10
        button.addTarget(self, action: #selector(onHeadButtonClick(sender:)), for: .touchUpInside)
        self.addSubview(button)
        return button
    }

    @objc private func onHeadButtonClick(sender: UIButton) {
        let option = CDTextTools(rawValue: sender.tag - 10)

        switch option {
        case .fontSize, .fontName:
            CDTextViewConfig.share.addInputView(view: CDTextViewConfig.share.textFontView)

        case .textBgColor, .textColor, .paragraphSymbol:
            CDTextViewConfig.share.pickType = CDPickerType(rawValue: option!.rawValue)
            CDTextViewConfig.share.addInputView(view: CDTextViewConfig.share.pickView)

        case .heading, .subHeading, .body:
            CDTextViewConfig.share.titleType = option
            for i in CDTextTools.heading.rawValue...CDTextTools.body.rawValue {
                let btn = self.viewWithTag(i + 10) as! UIButton
                btn.backgroundColor = i == option?.rawValue ? .orange : .white
            }
            CDTextViewConfig.share.updateTextView()
        case .blod, .italic, .underline:
            CDTextViewConfig.share.blodType = option
            for i in CDTextTools.blod.rawValue...CDTextTools.underline.rawValue {
                let btn = self.viewWithTag(i + 10) as! UIButton
                btn.backgroundColor = i == option?.rawValue ? .orange : .white
            }
            CDTextViewConfig.share.updateTextView()
        case .addIndents:
            if CDTextViewConfig.share.indents <= IndentsMin {
                sender.setImage(UIImage(named: "subIndents-gay"), for: .normal)
                break
            }
            CDTextViewConfig.share.indents -= 1
            CDTextViewConfig.share.updateTextView()
        case .subIndents:

            CDTextViewConfig.share.indents += 1
            if CDTextViewConfig.share.indents > IndentsMin {
                let btn = self.viewWithTag(CDTextTools.subIndents.rawValue + 10) as! UIButton
                btn.setImage(UIImage(named: "subIndents"), for: .normal)
            }

            CDTextViewConfig.share.updateTextView()
        case .none:
            break
        }

    }
    @objc private func onDismissStyleView() {
        delegate.removeInputView()
    }

    /**
    *修改字体
    */
    @objc private func onPostChangeFont() {
        let fontSizeBtn = self.viewWithTag(CDTextTools.fontSize.rawValue + 10) as! UIButton
        fontSizeBtn.setTitle(CDTextViewConfig.share.fontSize, for: .normal)

        let fontNameBtn = self.viewWithTag(CDTextTools.fontName.rawValue + 10) as! UIButton
        fontNameBtn.setTitle(CDTextViewConfig.share.fontName, for: .normal)
    }

    /**
    *修改段落符号
    */
    @objc private func onPostChangePicker() {
        if CDTextViewConfig.share.pickType == .textColor {
            let button = self.viewWithTag(CDTextTools.textColor.rawValue + 10)
            button?.backgroundColor = CDTextViewConfig.share.fontColor
        } else if CDTextViewConfig.share.pickType == .textBgColor {
            let button = self.viewWithTag(CDTextTools.textBgColor.rawValue + 10)
            button?.backgroundColor = CDTextViewConfig.share.fontbgColor
        } else {
            let symbolBtn = self.viewWithTag(CDTextTools.paragraphSymbol.rawValue + 10) as! UIButton
            symbolBtn.setImage(CDTextViewConfig.share.paragraphSymbol, for: .normal)
        }

    }
}
