//
//  CDPopMenuView.swift
//  MyRule
//
//  Created by changdong on 2019/4/23.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit

enum CDOrientation:Int {
    case leftDown
    case leftUp
    case rightDown
    case rightUp
}

@objc protocol CDPopMenuViewDelegate{
    @objc func onSelectedPopMenu(title:String)
    @objc func closePopMenuView()
}

class CDPopMenuView: UIView,UITableViewDelegate,UITableViewDataSource {
    let cellHeight = 48


    weak var popDelegate:CDPopMenuViewDelegate!
    var tableView:UITableView!
    var tableBgView:UIImageView!
    var backGroundView:UIView!

    var tableBgViewWidth:CGFloat!
    var tableBgViewHeight:CGFloat!
    var _cellTitleArr:[String] = []
    var _cellImageArr:[String] = []
    var _orientation:CDOrientation!
    init(frame: CGRect, imageArr: [String], titleArr:[String], orientation:CDOrientation) {
        super.init(frame: frame)

        backGroundView = UIView(frame: frame)
        backGroundView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissPopView))
        backGroundView.addGestureRecognizer(tap)
       
        self.addSubview(backGroundView)

        _cellTitleArr = titleArr
        _cellImageArr = imageArr
        var tableViewHeight:CGFloat = CGFloat(cellHeight * imageArr.count)
        if tableViewHeight > frame.height{
            tableViewHeight = frame.height
        }

        let tableWidth:CGFloat = 160

        _orientation = orientation
        tableBgViewHeight = tableViewHeight + 12.0
        tableBgViewWidth = tableWidth
        let result = getFrameFromOrientation(orientation: orientation)
        let startX:CGFloat = result.startX;
        let startY:CGFloat = result.startY;
        let menuY:CGFloat = result.menuY;
        let bgImageName = result.bgImageName;
        let bgImage = LoadImageByName(imageName: bgImageName, type: "png")



        tableBgView = UIImageView(frame: CGRect(x: startX, y: startY, width: tableWidth, height: tableViewHeight+12))
        tableBgView.isUserInteractionEnabled = true
        tableBgView.image = bgImage.stretchableImage(withLeftCapWidth: Int(bgImage.size.width/2), topCapHeight: Int(bgImage.size.height/2))
        self.addSubview(tableBgView)
        tableBgView.tag = 999
        tableBgViewWidth = tableWidth

        tableView = UITableView(frame: CGRect(x: 2, y: menuY, width: tableWidth-5, height: tableViewHeight), style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.clear
        tableView.estimatedRowHeight = 0
        tableBgView.addSubview(tableView)
        tableView.rowHeight = CGFloat(cellHeight)
        tableView.isScrollEnabled = false
    }

    func getFrameFromOrientation(orientation:CDOrientation) ->(startX:CGFloat,startY:CGFloat,menuY:CGFloat,bgImageName:String) {
        var startX:CGFloat = 0
        var startY:CGFloat = 0
        var menuY:CGFloat = 0
        let bgImageName:String!
        switch orientation {
        case .leftDown:
            startX = 10
            startY = frame.height - tableBgViewHeight
            menuY = 0
            bgImageName = "leftDown"
        case .leftUp:
            startX = 10
            startY = 10
            menuY = 12
            bgImageName = "leftUp"
        case .rightUp:
            startX = frame.width - tableBgViewHeight - 10
            startY = 10
            menuY = 12
            bgImageName = "rightUp"
        case .rightDown:
            startX = frame.width - tableBgViewWidth - 10
            startY = frame.height - tableBgViewHeight
            menuY = 0
            bgImageName = "rightDown"
        }
        return(startX,startY,menuY,bgImageName)

    }
    func reloadTableViewWithCellArr(titleArr:[String], imageArr:[String]) -> Void {
        _cellTitleArr = titleArr
        _cellImageArr = imageArr
        var tableViewHeight = CGFloat(cellHeight * imageArr.count)
        if tableViewHeight > frame.height{
            tableViewHeight = frame.height
        }
        let result = getFrameFromOrientation(orientation: _orientation)
        let startX:CGFloat = result.startX;

        tableBgViewHeight = tableViewHeight + 12.0
        let bgImageV = self.viewWithTag(999) as! UIImageView;
        bgImageV.frame = CGRect(x: startX, y: 0, width: tableBgViewWidth, height: tableViewHeight + 12)
        tableView.frame = CGRect(x: 2
            , y: 10, width: tableBgViewWidth - 5.0, height: tableViewHeight)
        tableView.reloadData()

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _cellTitleArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell:UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "CDPopMenuViewIdentify")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "CDPopMenuViewIdentify")
            let view = UIView()
            cell.selectedBackgroundView = view
            cell.selectedBackgroundView?.backgroundColor = LightBlueColor

            let imageV = UIImageView(frame: CGRect(x: 15, y: 9, width: 30, height: 30))
            imageV.tag = 101
            cell.addSubview(imageV)

            let titleL = UILabel(frame: CGRect(x: imageV.frame.maxX+15, y: 9, width: 200, height: 30))
            titleL.textColor = TextBlackColor
            titleL.font = TextMidFont
            titleL.tag = 102
            cell.addSubview(titleL)

            let sperateLine = UIView(frame: CGRect(x: imageV.frame.maxX, y: 47, width: CDSCREEN_WIDTH - imageV.frame.maxX, height: 1))
            sperateLine.tag = 103
            sperateLine.backgroundColor = SeparatorLightGrayColor
            cell.addSubview(sperateLine)
        }
        let titleV = cell.viewWithTag(102) as! UILabel
        let imageV = cell.viewWithTag(101) as! UIImageView
        let lineView = cell.viewWithTag(103) as! UIView
        let title = _cellTitleArr[indexPath.row]
        let imageName = _cellImageArr[indexPath.row]
        titleV.text = title
        imageV.image = LoadImageByName(imageName: imageName, type: "png")

        if (indexPath.row == _cellImageArr.count-1) {
            lineView.isHidden = true;
        }else
        {
            lineView.isHidden = false;
        }

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let title = _cellTitleArr[indexPath.row]
        self.popDelegate.onSelectedPopMenu(title: title)
    }

    @objc func dismissPopView(){
        
        self.popDelegate.closePopMenuView()
    }
}
