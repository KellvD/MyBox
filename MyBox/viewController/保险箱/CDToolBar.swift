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

    var addItem:UIButton! //增加录音，文字
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
        self.isUserInteractionEnabled = true
        self.image = UIImage(named: "下导航-bg")
        var spqce0:CGFloat = 0.0
        if foldertype == .ImageFolder ||
            foldertype == .VideoFolder{
            spqce0 = (frame.width - 45*3)/4
            //
            self.takeItem = UIButton(type:.custom)
            self.takeItem.frame = CGRect(x: spqce0 * 2 + 45 , y: 1.5, width: 45, height: 45)
            self.takeItem.setImage(UIImage(named: "camera"), for: .normal)
            self.takeItem.addTarget(superVC, action: #selector(takePhotoClick), for: .touchUpInside)
            self.addSubview(self.takeItem)
            //
            self.inputItem = UIButton(type:.custom)
            self.inputItem.frame = CGRect(x: spqce0 * 3 + 45 * 2, y: 1.5, width: 45, height: 45)
            self.inputItem.setImage(UIImage(named: "input"), for: .normal)
            self.inputItem.addTarget(superVC, action: #selector(inputItemClick), for: .touchUpInside)
            self.addSubview(self.inputItem)
        }else{
            self.addItem = UIButton(type:.custom)
            if foldertype == .TextFolder {
                spqce0 = (frame.width - 45*3)/4
                self.addItem.setImage(UIImage(named: "addText"), for: .normal)
            }else{
                spqce0 = (frame.width - 45*2)/3
                self.addItem.setImage(UIImage(named: "record"), for: .normal)
            }
            self.addItem.frame = CGRect(x: spqce0 * 2 + 45, y: 1.5, width: 45, height: 45)
            self.addItem.addTarget(superVC, action: #selector(addItemClick), for: .touchUpInside)
            self.addSubview(self.addItem)
        }
        self.documentItem = UIButton(type:.custom)
        self.documentItem.frame = CGRect(x: spqce0, y: 1.5, width: 45, height: 45)
        self.documentItem.setImage(UIImage(named: "addFile"), for: .normal)
        self.documentItem.addTarget(superVC, action: #selector(documentItemClick), for: .touchUpInside)
        self.addSubview(self.documentItem)


        let width:CGFloat = 45.0
        var space:CGFloat = 0;
        if foldertype == .TextFolder {
            space = (frame.width - 4 * width) / 5;
        }else{
            space = (frame.width - 5 * width) / 6;
        }
        //分享
        self.shareItem = UIButton(type:.custom)
        self.shareItem.frame = CGRect(x: space, y: 1.5, width: width, height: 45)
        self.shareItem.setImage(UIImage(named: "menu_forward"), for: .normal)
        self.shareItem.addTarget(superVC, action: #selector(shareBarItemClick), for: .touchUpInside)
        self.addSubview(self.shareItem)
        //移动
        self.moveItem = UIButton(type:.custom)
        self.moveItem.frame = CGRect(x: space*2+width, y: 1.5, width: width, height: 45)
        self.moveItem.setImage(UIImage(named: "menu_move"), for: .normal)
        self.moveItem.setImage(UIImage(named: "menu_move_grey"), for: .disabled)
        self.moveItem.addTarget(superVC, action: #selector(moveBarItemClick), for: .touchUpInside)
        self.addSubview(self.moveItem)
        //导出
        self.outputItem = UIButton(type:.custom)
        self.outputItem.frame = CGRect(x: space*3+width*2, y: 1.5, width: width, height: 45)
        self.outputItem.setImage(UIImage(named: "output"), for: .normal)
        self.outputItem.addTarget(superVC, action: #selector(outputBarItemClick), for: .touchUpInside)
        self.addSubview(self.outputItem)
        //分享
        self.deleteItem = UIButton(type:.custom)
        self.deleteItem.frame = CGRect(x: space*4+width*3, y: 1.5, width: width, height: 45)
        self.deleteItem.setImage(UIImage(named: "menu_delete_grey"), for: .disabled)
        self.deleteItem.setImage(UIImage(named: "menu_delete"), for: .normal)
        self.deleteItem.addTarget(superVC, action: #selector(deleteBarItemClick), for: .touchUpInside)
        self.addSubview(self.deleteItem)

        self.appendItem = UIButton(type:.custom)
        self.appendItem.frame = CGRect(x: space*5+width*4, y: 1.5, width: width, height: 45)
        self.appendItem.setImage(UIImage(named: "append_grey"), for: .disabled)
        self.appendItem.setImage(UIImage(named: "append"), for: .normal)
        self.appendItem.addTarget(superVC, action: #selector(appendItemClick), for: .touchUpInside)
        self.addSubview(self.appendItem)

        hiddenReloadBar(isMulit: false)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func hiddenReloadBar(isMulit:Bool) {

        if isMulit {
            if _foldertype == .ImageFolder ||
                _foldertype == .VideoFolder{
                takeItem.isHidden = true
                inputItem.isHidden = true
                documentItem.isHidden = true
            }else{
                documentItem.isHidden = true
                addItem.isHidden = true
            }
            shareItem.isHidden = false
            moveItem.isHidden = false
            outputItem.isHidden = false
            deleteItem.isHidden = false
            appendItem.isHidden = false

            shareItem.isEnabled = false
            moveItem.isEnabled = false
            outputItem.isEnabled = false
            deleteItem.isEnabled = false
            appendItem.isEnabled = false
        }else{

            if _foldertype == .ImageFolder ||
                _foldertype == .VideoFolder{
                takeItem.isHidden = false
                inputItem.isHidden = false
                documentItem.isHidden = false
            }else{
                documentItem.isHidden = false
                addItem.isHidden = false
            }

            shareItem.isHidden = true
            moveItem.isHidden = true
            outputItem.isHidden = true
            deleteItem.isHidden = true
            appendItem.isHidden = true

        }
        if _foldertype == .TextFolder {
            appendItem.isHidden = true
        }

    }
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
    @objc func addItemClick(){

    }
    @objc func addDirItemClick(){

    }
}
