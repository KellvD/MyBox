//
//  CDAttendanceViewController.swift
//  MyBox
//
//  Created by changdong on 2021/8/21.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit

class CDAttendanceViewController: CDBaseAllViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.tipsView)
        self.view.addSubview(self.dayView)
        self.view.addSubview(self.monthView)

    }
    @objc func onSelectedAttendance() {

    }

    lazy var tipsView: CDTipsView = {
        let tipV = CDTipsView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: 48), tips: ["本日打卡", "本月打卡"])
        tipV.selectedHandle = {(_) in

        }
        return tipV
    }()

    lazy var dayView: CDDayAttendanceView = {
        let dayV = CDDayAttendanceView(frame: CGRect(x: 0, y: self.tipsView.maxY, width: CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH - self.tipsView.maxY))

        return dayV
    }()

    lazy var monthView: CDMonthAttendanceView = {
        let monthV = CDMonthAttendanceView(frame: CGRect(x: 0, y: self.tipsView.maxY, width: CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH - self.tipsView.maxY))
        monthV.isHidden = true
        return monthV
    }()

}
