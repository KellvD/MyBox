//
//  CDEditManager.swift
//  MyRule
//
//  Created by changdong on 2019/6/28.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit

enum NSEditStep {
    case NOTEdit
    case WillEdit
    case DidEdit

}
class CDEditManager: NSObject {

    var editStep:NSEditStep!
    var editType:CDEditorsType!

    var naviBar:CDNavigationBar!

    var editVC:CDImageEditViewController!
    var image:UIImage!

    var lastTranform:CATransform3D!
    var tranformArr:[CATransform3D] = []


    static let instance:CDEditManager = CDEditManager()
    class func shareInstance()->CDEditManager {
        objc_sync_enter(self)

        

        objc_sync_exit(self)
        return instance
    }


    //旋转
    func onRoateBarDidSelected(rotate:NSRotateType){

        tranformArr.append(lastTranform)
        naviBar.backwardItem.isEnabled = true
        switch rotate {
        case .vertical:
//            verticalIndex = verticalIndex == -1 ? 1: -1
            UIView.animate(withDuration: 1) {
                let transform = CATransform3DGetAffineTransform(self.lastTranform).scaledBy(x: 1, y:-1 )
                self.editVC.scroller.transform = transform
            }
        case .horizontal:
//            horizontalIndex = horizontalIndex == -1 ? 1: -1
            UIView.animate(withDuration: 1) {
                let transform = CATransform3DGetAffineTransform(self.lastTranform).scaledBy(x: -1, y:1 )
                self.editVC.scroller.transform = transform
            }
        case .left:
            UIView.animate(withDuration: 2) {
                let transform = CATransform3DGetAffineTransform(self.lastTranform).rotated(by: CGFloat(-Double.pi / 2))
                self.editVC.scroller.transform = transform
            }
        case .right:
            UIView.animate(withDuration: 2) {
                let transform = CATransform3DGetAffineTransform(self.lastTranform).rotated(by: CGFloat(Double.pi / 2))
                self.editVC.scroller.transform = transform
            }
        }
        lastTranform = self.editVC.scroller.layer.transform

    }

    //撤销操作
    func dropEditHandle(){

        if editType == CDEditorsType.Rotate {
//            if tranformArr.count > 0{
//                let transform3D = tranformArr.last
//                let transform = CATransform3DGetAffineTransform(transform3D!).rotated(by: CGFloat(Double.pi / 2))
//                editVC.scroller.transform = transform
//                tranformArr.remove(at: tranformArr.count - 1)
//                if tranformArr.count == 0{
//                    naviBar.backwardItem.isEnabled = false
//                }else{
//                    naviBar.backwardItem.isEnabled = true
//                }
//            }
            editVC.scroller.transform = CGAffineTransform.identity
            naviBar.backwardItem.isEnabled = false

        }
    }

    func cancleEditHandle(){
        if editType == CDEditorsType.Rotate {
            editVC.scroller.transform = CGAffineTransform.identity
            naviBar.backwardItem.isEnabled = false
        }
    }

    func doneEditHandle(){
        if editType == CDEditorsType.Rotate {

//            let rect =  CGRectMake(0, 0, srcImage.size.width , srcImage.size.height);//创建矩形框
//            //根据size大小创建一个基于位图的图形上下文
//            UIGraphicsBeginImageContextWithOptions(rect.size, false, 2)
//            let currentContext =  UIGraphicsGetCurrentContext();//获取当前quartz 2d绘图环境
//            CGContextClipToRect(currentContext, rect);//设置当前绘图环境到矩形框
//            CGContextRotateCTM(currentContext, CGFloat(M_PI)); //旋转180度
//            //平移， 这里是平移坐标系，跟平移图形是一个道理
//            CGContextTranslateCTM(currentContext, -rect.size.width, -rect.size.height);
//            CGContextDrawImage(currentContext, rect, srcImage.CGImage);//绘图
        }
    }

    func onBrightItemSelected(brightType:CDBrightType) {
        switch brightType {
        case .Bright: break

        default: break
            
        }
    }
}
