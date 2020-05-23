//
//  CDToolBar.swift
//  MyRule
//
//  Created by changdong on 2019/6/18.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit


class CDToolBar: UIImageView {

    var inputItem:UIButton!  //导入
    var takeItem:UIButton!   //拍照片,写文字，导入照片
    var documentItem:UIButton! //沙盒导入
    
    var outputItem:UIButton!  //导出
    var shareItem:UIButton!  //分享
    var moveItem:UIButton!  //移动
    var deleteItem:UIButton!  //删除
    var appendItem:UIButton! //拼图
    var _foldertype:NSFolderType!

    
    init(frame: CGRect, foldertype: NSFolderType, superVC: CDBaseAllViewController) {
        super.init(frame: frame)
        _foldertype = foldertype
        isUserInteractionEnabled = true
        image = UIImage(named: "下导航-bg")
        
        //沙盒导入
        documentItem = UIButton(type:.custom)
        documentItem.frame = CGRect.zero
        documentItem.setImage(UIImage(named: "addFile"), for: .normal)
        documentItem.addTarget(superVC, action: #selector(documentItemClick), for: .touchUpInside)
        addSubview(documentItem)
        
        //拍照
        takeItem = UIButton(type:.custom)
        takeItem.frame = CGRect.zero
        takeItem.setImage(UIImage(named: "camera"), for: .normal)
        takeItem.addTarget(superVC, action: #selector(takePhotoClick), for: .touchUpInside)
        addSubview(takeItem)
        
        //图库,录音，编辑文字
        inputItem = UIButton(type:.custom)
        inputItem.frame = CGRect.zero
        inputItem.setImage(UIImage(named: "input"), for: .normal)
        inputItem.addTarget(superVC, action: #selector(inputItemClick), for: .touchUpInside)
        addSubview(inputItem)
        
        /*--------------------------批量按钮元素------------------------*/
        //分享
        shareItem = UIButton(type:.custom)
        shareItem.frame = CGRect.zero
        shareItem.setImage(UIImage(named: "menu_forward"), for: .normal)
        shareItem.addTarget(superVC, action: #selector(shareBarItemClick), for: .touchUpInside)
        addSubview(shareItem)
        //移动
        moveItem = UIButton(type:.custom)
        moveItem.frame = CGRect.zero
        moveItem.setImage(UIImage(named: "menu_move"), for: .normal)
        moveItem.setImage(UIImage(named: "menu_move_grey"), for: .disabled)
        moveItem.addTarget(superVC, action: #selector(moveBarItemClick), for: .touchUpInside)
        addSubview(moveItem)
        
        //导出
        outputItem = UIButton(type:.custom)
        outputItem.frame = CGRect.zero
        outputItem.setImage(UIImage(named: "output"), for: .normal)
        outputItem.addTarget(superVC, action: #selector(outputBarItemClick), for: .touchUpInside)
        addSubview(outputItem)
        
        //删除
        deleteItem = UIButton(type:.custom)
        deleteItem.frame = CGRect.zero
        deleteItem.setImage(UIImage(named: "menu_delete_grey"), for: .disabled)
        deleteItem.setImage(UIImage(named: "menu_delete"), for: .normal)
        deleteItem.addTarget(superVC, action: #selector(deleteBarItemClick), for: .touchUpInside)
        addSubview(deleteItem)
       
        appendItem = UIButton(type:.custom)
        appendItem.frame = CGRect.zero
        appendItem.setImage(UIImage(named: "append_grey"), for: .disabled)
        appendItem.setImage(UIImage(named: "append"), for: .normal)
        appendItem.addTarget(superVC, action: #selector(appendItemClick), for: .touchUpInside)
        addSubview(appendItem)
        
        
        
        
        var space0:CGFloat = 0.0
        let _Y:CGFloat = 1.5
        let _width:CGFloat = 45.0
        let _height:CGFloat = 45.0
        if foldertype == .ImageFolder || foldertype == .VideoFolder{
            space0 = (frame.width - 45*3)/4
            documentItem.frame = CGRect(x: space0, y: _Y, width: _width, height: _height)
            takeItem.frame = CGRect(x: space0 * 2 + _width, y: _Y, width: _width, height: _height)
            inputItem.frame = CGRect(x: space0 * 3 + _width * 2, y: _Y, width: _width, height: _height)
        }else{
            space0 = (frame.width - 45*2)/3
            documentItem.frame = CGRect(x: space0, y: _Y, width: _width, height: _height)
            inputItem.frame = CGRect(x: space0 * 2 + _width, y: _Y, width: _width, height: _height)
            if foldertype == .TextFolder {
                inputItem.setImage(UIImage(named: "addText"), for: .normal)
            } else if foldertype == .AudioFolder {
                inputItem.setImage(UIImage(named: "record"), for: .normal)
            }
            
        }
        
        var buttonArr:[UIButton] = []
        if foldertype == .TextFolder { //分享，移动，删除
            space0 = (frame.width - 3 * _width) / 4;
            buttonArr = [shareItem,moveItem,deleteItem]
        } else if foldertype == .AudioFolder { //分享，移动，删除，拼接
            space0 = (frame.width - 4 * _width) / 5;
            buttonArr = [shareItem,moveItem,deleteItem,appendItem]
        } else { //分享，移动，删除，拼接，导出
            space0 = (frame.width - 5 * _width) / 6;
            buttonArr = [shareItem,moveItem,outputItem,deleteItem,appendItem]
        }
        
        for i in 0..<buttonArr.count {
            let btn = buttonArr[i]
            let _X = CGFloat(space0 * CGFloat(i + 1)) + _width * CGFloat(i)
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
        inputItem.isHidden = isMulit
        documentItem.isHidden = isMulit
        if _foldertype == .ImageFolder || _foldertype == .VideoFolder{
            takeItem.isHidden = isMulit
            
        }

        shareItem.isHidden = !isMulit
        moveItem.isHidden = !isMulit
        outputItem.isHidden = !isMulit
        deleteItem.isHidden = !isMulit
        appendItem.isHidden = !isMulit

    }
    
    //选中了文件，批量按钮元素全部有效可点
    func enableReloadBar(isSelected:Bool) {
        deleteItem.isEnabled = isSelected
        moveItem.isEnabled = isSelected
        outputItem.isEnabled = isSelected
        shareItem.isEnabled = isSelected
        appendItem.isEnabled = isSelected
    }


    @objc func documentItemClick(){

    }
    @objc func takePhotoClick(){
        
    }
    @objc func inputItemClick(){

    }
    @objc func shareBarItemClick(){

    }
    @objc func moveBarItemClick(){

    }
    @objc func outputBarItemClick(){

    }
    @objc func deleteBarItemClick(){

    }
    @objc func appendItemClick(){

    }
    
    @objc func addDirItemClick(){

    }
}
