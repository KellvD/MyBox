//
//  CDWaterMarkView.swift
//  PhotoEdit
//
//  Created by changdong on 2019/5/14.
//  Copyright © 2019 baize. All rights reserved.
//

import UIKit

let waterViewHeight:CGFloat = 70.0
class CDWaterMarkView: UIView {

    var imagePthes:[String] = []
    var scroller:UIScrollView!
    var _seclectBlock:ImageBlock!
    var _addBlock:VoidBlock!

    var addNewImageView:UIImageView!
    var imageViews:[UIImageView] = []



    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func buildUI() {
        self.backgroundColor = CDEdit.trunRGBToUIColor(red: 244, green: 244, blue: 244, alpha: 1)
        scroller = UIScrollView(frame: self.bounds)
        self.addSubview(scroller)

        addNewImageView = UIImageView(image: UIImage(named: ""), highlightedImage: UIImage(named: ""))
        addNewImageView.isUserInteractionEnabled = true
        scroller.addSubview(addNewImageView)

        let tap = UIGestureRecognizer(target: self, action: #selector(addNewMark))
        addNewImageView.addGestureRecognizer(tap)
    }

    func setImagePthes(imagePthes:[String]) {
        refresh()
        let marginY:CGFloat = 10.0
        let marginX:CGFloat = 15.0
        let imageHeight = self.frame.height - 2 * marginY
        let imageWidth:CGFloat = CGFloat(imageHeight * 1.2)
        for i in 0..<imagePthes.count {
            let imageX = CGFloat(i+1) * marginX + CGFloat(i) * imageWidth
            let imageView = UIImageView(frame: CGRect(x: imageX, y: marginY, width: imageWidth, height: imageHeight))
            scroller.addSubview(imageView)
            imageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapMethod(gesture:)))
            imageView.addGestureRecognizer(tap)
            imageView.layer.cornerRadius = 5.0
            imageView.layer.masksToBounds = true
            imageView.tag = i
            imageView.layer.borderColor = UIColor.black.cgColor
            imageView.backgroundColor = UIColor.clear
            imageView.image = UIImage(contentsOfFile: imagePthes[i])
            imageViews.append(imageView)
        }

        let X:CGFloat =  CGFloat(imagePthes.count + 1) * marginX + CGFloat(imagePthes.count) * imageWidth



        addNewImageView.frame = CGRect(x:X, y: marginY, width: imageWidth, height: imageHeight)
        scroller.contentSize = CGSize(width: addNewImageView.frame.minX + marginX, height: 0)



    }
    func refresh() {
        for view:UIView in scroller.subviews {
            if view == addNewImageView{
                continue
            }
        }
        imageViews.removeAll()
    }

    @objc func imageTapMethod(gesture:UITapGestureRecognizer) {
        for imageView:UIImageView in imageViews {
            imageView.layer.borderWidth = 0
        }
        let imageView = gesture.view as! UIImageView
        imageView.layer.borderWidth = 1.5

        _seclectBlock(imageView.image)

    }

    @objc func addNewMark() {
        _addBlock()
    }

    func addWaterMarkSelected(imageBlock:@escaping ImageBlock,voidBlock:@escaping VoidBlock) {

        _seclectBlock = imageBlock
        _addBlock = voidBlock
    }

}
