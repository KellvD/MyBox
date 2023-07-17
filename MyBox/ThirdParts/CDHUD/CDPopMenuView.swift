//
//  CDPopMenuView.swift
//  MyRule
//
//  Created by changdong on 2019/4/23.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit

@objc protocol CDPopMenuViewDelegate {
    @objc func onSelectedPopMenu(title: String)
}
private let tableBgViewWidth: CGFloat = 160
private let tableBgViewY: CGFloat = 0
class CDPopMenuView: UIView, UITableViewDelegate, UITableViewDataSource {
    let cellHeight = 48
    enum CDOrientation: Int {
        case leftUp
        case rightUp
    }

    weak var popDelegate: CDPopMenuViewDelegate!
    var tableView: UITableView!
    var tableBgView: UIImageView!

    var tableBgViewHeight: CGFloat = 0
    var _cellTitleArr: [String] = []
    var _cellImageArr: [String] = []
    var _orientation: CDOrientation!
    init(frame: CGRect, imageArr: [String], titleArr: [String], orientation: CDOrientation) {
        super.init(frame: frame)
        let backGroundView = UIView(frame: frame)
        backGroundView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissPopView))
        backGroundView.addGestureRecognizer(tap)
        backGroundView.alpha = 0.3
        addSubview(backGroundView)

        // 毛玻璃效果
        let blurEffect = UIBlurEffect(style: .dark)
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.frame = backGroundView.bounds
        backGroundView.addSubview(effectView)

        _cellTitleArr = titleArr
        _cellImageArr = imageArr
        var tableViewHeight: CGFloat = CGFloat(cellHeight * imageArr.count)
        tableViewHeight = tableViewHeight > frame.height/2 ? frame.height/2 :tableViewHeight
        _orientation = orientation

        let startX: CGFloat = orientation == .leftUp ? 10 : frame.width - tableBgViewWidth - 10
        let bgImageName = orientation == .leftUp ? "leftUp":"rightUp"
        let bgImage = LoadImage(bgImageName)!

        tableBgView = UIImageView(frame: CGRect(x: startX, y: tableBgViewY - (tableViewHeight + 12.0), width: tableBgViewWidth, height: tableViewHeight + 12.0))
        tableBgView.isUserInteractionEnabled = true
        tableBgView.image = bgImage.stretchableImage(withLeftCapWidth: Int(bgImage.size.width/2), topCapHeight: Int(bgImage.size.height/2))
        self.addSubview(tableBgView)

        tableView = UITableView(frame: CGRect(x: 2, y: 12, width: tableBgView.frame.width - 4, height: tableViewHeight), style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.clear
        tableView.estimatedRowHeight = 0
        tableBgView.addSubview(tableView)
        tableView.rowHeight = CGFloat(cellHeight)
        tableView.isScrollEnabled = false
    }

    func reloadTableViewWithCellArr(titleArr: [String], imageArr: [String]) {
        _cellTitleArr = titleArr
        _cellImageArr = imageArr
        var tableViewHeight = CGFloat(cellHeight * imageArr.count)
        tableViewHeight = tableViewHeight > frame.height/2 ? frame.height/2 :tableViewHeight

        let startX: CGFloat = _orientation == .leftUp ? 10 : frame.width - tableBgViewHeight - 10

        let bgImageV = self.viewWithTag(999) as! UIImageView
        bgImageV.frame = CGRect(x: startX, y: tableBgViewY - (tableViewHeight + 12.0), width: tableBgViewWidth, height: tableViewHeight + 12.0)
        tableView.frame = CGRect(x: 2, y: 10, width: tableBgViewWidth - 4.0, height: tableViewHeight)
        tableView.reloadData()

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _cellTitleArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "CDPopMenuViewIdentify")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "CDPopMenuViewIdentify")
            let view = UIView()
            cell.selectedBackgroundView = view
            cell.selectedBackgroundView?.backgroundColor = .cellSelectColor

            let imageV = UIImageView(frame: CGRect(x: 15, y: 9, width: 30, height: 30))
            imageV.tag = 101
            cell.addSubview(imageV)

            let titleL = UILabel(frame: CGRect(x: imageV.frame.maxX+15, y: 9, width: 200, height: 30))
            titleL.textColor = .textBlack
            titleL.font = .mid
            titleL.tag = 102
            cell.addSubview(titleL)

            let sperateLine = UIView(frame: CGRect(x: titleL.frame.minX, y: 47, width: CDSCREEN_WIDTH - titleL.frame.minX, height: 1))
            sperateLine.tag = 103
            sperateLine.backgroundColor = .separatorColor
            cell.addSubview(sperateLine)
        }
        let titleV = cell.viewWithTag(102) as! UILabel
        let imageV = cell.viewWithTag(101) as! UIImageView
        let lineView = cell.viewWithTag(103)!
        let title = _cellTitleArr[indexPath.row]
        let imageName = _cellImageArr[indexPath.row]
        titleV.text = title
        imageV.image = LoadImage(imageName)
        lineView.isHidden = indexPath.row == _cellImageArr.count-1

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let title = _cellTitleArr[indexPath.row]
        self.popDelegate.onSelectedPopMenu(title: title)
        dismissPopView()
    }

    func showPopView() {
        if self.tableBgView.minY == tableBgViewY {
            dismissPopView()
        } else {
            UIView.animate(withDuration: 0.25, animations: {
                self.isHidden = false
                self.tableBgView.minY = tableBgViewY
            }) { (_) in}
        }
    }
    @objc func dismissPopView() {

        UIView.animate(withDuration: 0.25, animations: {
            self.tableBgView.minY = tableBgViewY - self.tableBgView.height
        }) { (_) in
            self.isHidden = true
        }
    }
}
