//
//  PECorpRectView.swift
//  PhotoEdit
//
//  Created by changdong on 2019/5/20.
//  Copyright © 2019 baize. All rights reserved.
//

import UIKit

protocol PECropRectViewDelegate {
    func cropRectViewDidBeginEditing(cropRectView: PECropRectView)
    func cropRectViewEditingChanged(cropRectView: PECropRectView)
    func cropRectViewDidEndEditing(cropRectView: PECropRectView)

}
class PECropRectView: UIView {

    var showsGridMajor:Bool!
    var showsGridMinor:Bool!
    var keepingAspectRatio:Bool!
    var delegate:PECropRectViewDelegate!




    

}
