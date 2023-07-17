//
//  CDTextView.swift
//  CDTextViewDemo
//
//  Created by changdong on 2020/9/9.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit

class CDTextView: UITextView, CDInputViewDelegate {

    private var isTuYa = false
    private var pathArr: [UIBezierPath] = []
    private var path: UIBezierPath!
    private var isShowKeyBoard = false
    init(frame: CGRect, subViewController: UIViewController) {
        super.init(frame: frame, textContainer: nil)

        CDTextViewConfig.share.superVC = subViewController
        CDTextViewConfig.share.textView = self
//        self.inputAccessoryView = CDTextViewConfig.share.accessoryView
        self.layoutManager.allowsNonContiguousLayout = false

//        CDTextViewConfig.share.updateTextView()
        subViewController.view.addSubview(self)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: UIResponder.keyboardWillHideNotification, object: nil)

    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)

    }

    @objc func keyboardDidHide() {
        if isShowKeyBoard {
            DispatchQueue.main.async {
                self.becomeFirstResponder()
            }

            isShowKeyBoard = false
        }

    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func removeInputView() {
        isShowKeyBoard = true
        self.resignFirstResponder()
        self.inputAccessoryView = CDTextViewConfig.share.accessoryView
        self.inputView = nil

    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isTuYa {
            for tmpTouch in touches {
                let curP = tmpTouch.location(in: self)

                path = UIBezierPath()
                path.move(to: curP)
                path.lineWidth = 1

                pathArr.append(path)
            }
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

        if isTuYa {
            for tmpTouch in touches {
                let curP = tmpTouch.location(in: self)

                path.addLine(to: curP)
                self.setNeedsDisplay()
            }
        }
    }
    override func draw(_ rect: CGRect) {
        if isTuYa {
            for path in pathArr {
                path.stroke()
            }
        }
    }
}
