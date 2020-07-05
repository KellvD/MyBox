//
//  CDReaderViewController.swift
//  MyBox
//
//  Created by changdong cwx889303 on 2020/7/1.
//  Copyright © 2020 (c) Huawei Technologies Co., Ltd. 2012-2019. All rights reserved.
//

import UIKit


class CDReaderViewController: UIViewController {

    public var content:String!
    public var recordModel:CDRecordModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.prefersStatusBarHidden
        self.view.backgroundColor = CDReaderConfig.shared.theme
        self.view.addSubview(self.readView)
        NotificationCenter.default.addObserver(self, selector: #selector(changeTheme(_:)), name: NSNotification.Name("changeTheme"), object: nil)
        
        
    }
    
    @objc private func changeTheme(_ noti:Notification){
        CDReaderConfig.shared.theme = noti.object as? UIColor
        self.view.backgroundColor = CDReaderConfig.shared.theme
    }

    lazy var readView: CDReadView = {
        let readView = CDReadView(frame: CGRect(x: 20, y: 40, width: CDSCREEN_WIDTH - 20 * 2, height: CDSCREEN_HEIGTH - 40 * 2))
        
        readView.frameRef = CDReaderParser.parserContent(content: content, config: CDReaderConfig.shared, bounds: CGRect(x: 0, y: 0, width: readView.frame.width, height: readView.frame.height))
        return readView
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}


class CDReadView: UIView {
    public var frameRef:CTFrame!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        if frameRef == nil {
            return
        }
        
        let context = UIGraphicsGetCurrentContext()
        context?.textMatrix = .identity
        context?.translateBy(x: 0, y: self.bounds.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        CTFrameDraw(frameRef,context!)
    }
}
