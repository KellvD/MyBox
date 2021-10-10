//
//  CDToolBar.swift
//  MyRule
//
//  Created by changdong on 2019/6/18.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit

enum CDToolsType:Int {
    case ImageTools
    case VideoTools
    case AudioTools
    case TextTools
    case ImageScrollerTools
    case VideoScrollerTools
}

class CDToolBar: UIImageView {

    var inputItem:UIButton!  //导入
    var takeItem:UIButton!   //拍照片,写文字，导入照片
    var documentItem:UIButton! //沙盒导入
    
    var outputItem:UIButton!  //导出
    var shareItem:UIButton!  //分享
    var moveItem:UIButton!  //移动
    var deleteItem:UIButton!  //删除
    var appendItem:UIButton! //拼图
    var loveItem:UIButton!
    var editItem:UIButton!
    
    var gBarType:CDToolsType!
    var isPreviewMedia:Bool = false
    var normalArr:[UIButton] = []
    var editArr:[UIButton] = []
    var target:CDBaseAllViewController!
    
    init(frame:CGRect ,barType: CDToolsType, superVC: CDBaseAllViewController) {
        super.init(frame: frame)
        gBarType = barType
        isUserInteractionEnabled = true
        image = UIImage(named: "下导航-bg")
        target = superVC;
        //沙盒导入
        documentItem = createButton(imageName: "menu_addFile", disabledImageName: nil, action: "documentItemClick")
    
        //拍照
        takeItem = createButton(imageName: "menu_camera", disabledImageName: nil, action: "takePhotoClick")
    
        
        //图库,录音，编辑文字
        
        var imageName = "menu_input"
        if barType == .TextTools {
            imageName = "menu_addText"
        } else if barType == .AudioTools {
            imageName = "menu_record"
        }
        inputItem = createButton(imageName: imageName, disabledImageName: nil, action: "importItemClick")
        
        /*--------------------------批量按钮元素------------------------*/
        //分享
        shareItem = createButton(imageName: "menu_forward", disabledImageName: "menu_forward_grey", action: "shareBarItemClick")
    
        //移动
        moveItem = createButton(imageName: "menu_move", disabledImageName: "menu_move_grey", action: "moveBarItemClick")

        //导出
        outputItem = createButton(imageName: "menu_output", disabledImageName: nil, action: "outputBarItemClick")
        
        //删除
        deleteItem = createButton(imageName: "menu_delete", disabledImageName: "menu_delete_grey", action: "deleteBarItemClick")
       
        appendItem = createButton(imageName: "menu_append", disabledImageName: "menu_append_grey", action: "appendItemClick")
        
        //收藏
        loveItem = createButton(imageName: "menu_love_normal", disabledImageName: nil, action: "loveItemClick")
        
        //编辑
        editItem = createButton(imageName: "menu_meitu", disabledImageName: nil, action: "editItemClick")
              
        let _Y:CGFloat = 1.5
        let _width:CGFloat = 45.0
        let _height:CGFloat = 45.0
        switch barType {
        case .ImageTools,.VideoTools:
            normalArr = [documentItem,takeItem,inputItem]
            editArr = [shareItem,moveItem,outputItem,deleteItem,appendItem]
            break
        case .AudioTools:
            normalArr = [documentItem,inputItem]
            editArr = [shareItem,moveItem,deleteItem,appendItem] //分享，移动，删除，拼接，导出
            break
        case .TextTools:
            normalArr = [documentItem,inputItem]
            editArr = [shareItem,moveItem,deleteItem]//分享，移动，删除
            break
        case .ImageScrollerTools,.VideoScrollerTools:
            normalArr = [shareItem,loveItem,editItem,deleteItem]
            break
        }
        
        let space0:CGFloat = (frame.width - CGFloat(editArr.count) * _width) / CGFloat(editArr.count + 1);
        for i in 0..<editArr.count {
            let btn = editArr[i]
            let _X = CGFloat(space0 * CGFloat(i + 1)) + _width * CGFloat(i)
            btn.frame = CGRect(x: _X, y: _Y, width: _width, height: _height)
        }
        
        let space1:CGFloat = (frame.width - CGFloat(normalArr.count) * _width) / CGFloat(normalArr.count + 1);
        for i in 0..<normalArr.count {
            let btn = normalArr[i]
            let _X = CGFloat(space1 * CGFloat(i + 1)) + _width * CGFloat(i)
            btn.frame = CGRect(x: _X, y: _Y, width: _width, height: _height)
        }
        hiddenReloadBar(isMulit: false)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func hiddenReloadBar(isMulit:Bool) {

        //批量按钮点击了，导入按钮（沙盒，拍照，录音等）隐藏，批量元素（分享，删除，拼接等）显示，置灰不可点
        //批量按钮取消了，导入按钮显示，批量元素隐藏
        normalArr.forEach { (sender) in
            sender.isHidden = isMulit
        }
        editArr.forEach { (sender) in
            sender.isHidden = !isMulit
        }
    }
    
    //选中了文件，批量按钮元素全部有效可点
    func enableReloadBar(isEnable:Bool) {
        deleteItem.isEnabled = isEnable
        moveItem.isEnabled = isEnable
        outputItem.isEnabled = isEnable
        shareItem.isEnabled = isEnable
        appendItem.isEnabled = isEnable
    }

    
    func createButton(imageName:String?,disabledImageName:String?,action:String)->UIButton{
        let button = UIButton(type:.custom)
        button.frame = CGRect.zero
        if disabledImageName != nil {
            button.setImage(UIImage(named: disabledImageName!), for: .disabled)
        }
        button.setImage(UIImage(named: imageName!), for: .normal)
        let selector = Selector(action)
        button.addTarget(target, action: selector, for: .touchUpInside)
        addSubview(button)
        return button
    }

    @objc func documentItemClick(){}
    
    @objc func takePhotoClick(){}
    
    @objc func importItemClick(){}
    
    @objc func shareBarItemClick(){}
    
    @objc func moveBarItemClick(){}
    
    @objc func outputBarItemClick(){}
    
    @objc func deleteBarItemClick(){}
    
    @objc func appendItemClick(){}
    
    @objc func addDirItemClick(){}
    
    @objc func loveItemClick(){}
    
    @objc func editItemClick(){}
}
