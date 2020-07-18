//
//  CDLogPreviewViewController.swift
//  MyBox
//
//  Created by changdong on 2020/7/13.
//  Copyright changdong 2012-2019. All rights reserved.
//

import UIKit

class CDLogPreviewViewController: CDBaseAllViewController {

    private var textView:UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        var content  = "当前内容不可查看"
        do {
            content = try String(contentsOfFile: CDSignalTon.shared.logbBean.logPath)
            content = content.isEmpty ? "暂无日志记录" : content
        } catch  {
            
        }
        
        textView = UITextView(frame: self.view.bounds)
        textView.scrollRangeToVisible(NSRange(location: content.count, length: 1))
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
