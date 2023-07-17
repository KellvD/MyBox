//
//  UIButton+extension.swift
//  CDLog
//
//  Created by changdong on 2020/11/23.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit

extension UIButton {
    convenience init(frame: CGRect, text: String?, textColor: UIColor?, target: Any?, function: Selector) {
        self.init(type: .custom)
        self.frame = frame
        setTitle(text, for: .normal)
        setTitleColor(textColor, for: .normal)
        addTarget(target, action: function, for: .touchUpInside)
    }

    convenience init(frame: CGRect, text: String?, textColor: UIColor?, imageNormal: String?, target: Any?, function: Selector, supView: UIView) {
        self.init(type: .custom)
        self.frame = frame
        setTitle(text, for: .normal)
        setTitleColor(textColor, for: .normal)
        setImage(UIImage(named: imageNormal ?? ""), for: .normal)
        addTarget(target, action: function, for: .touchUpInside)
        supView.addSubview(self)
    }

    /// 设置按钮图片位置
    /// - Parameters:
    ///   - edge: 图片位置
    ///   - space: 图片和文字的距离
    func setImagePosition(edge: UIRectEdge, space: CGFloat) {

        let imageWidth = self.imageView!.frame.width - self.imageEdgeInsets.left - self.imageEdgeInsets.right
        let imageHeight = self.imageView!.frame.height - self.imageEdgeInsets.top - self.imageEdgeInsets.bottom
        let labelWidth = self.titleLabel!.intrinsicContentSize.width
        let labelHeight = self.titleLabel!.intrinsicContentSize.height

        var imageEdge = UIEdgeInsets.zero
        var labelEdge = UIEdgeInsets.zero

        switch edge {
        case .top:
            imageEdge = UIEdgeInsets(top: -labelHeight - space/2.0, left: 0, bottom: 0, right: -labelWidth)
            labelEdge = UIEdgeInsets(top: 0, left: -imageWidth, bottom: -imageHeight - space/2.0, right: 0)
        case .left:
            imageEdge = UIEdgeInsets(top: 0, left: -space/2.0, bottom: 0, right: space/2.0)
            labelEdge = UIEdgeInsets(top: 0, left: space/2.0, bottom: 0, right: -space/2.0)
        case .bottom:
            imageEdge = UIEdgeInsets(top: 0, left: 0, bottom: -labelHeight - space/2.0, right: -labelWidth)
            labelEdge = UIEdgeInsets(top: -imageHeight - space/2.0, left: -imageWidth, bottom: 0, right: 0)
        case .right:
            imageEdge = UIEdgeInsets(top: self.imageEdgeInsets.top, left: labelWidth + space/2.0, bottom: self.imageEdgeInsets.bottom, right: -labelWidth - space/2.0)
            labelEdge = UIEdgeInsets(top: 0, left: -imageWidth - space/2.0, bottom: 0, right: imageWidth + space/2.0)
        default:
            break
        }

        self.imageEdgeInsets = imageEdge
        self.titleEdgeInsets = labelEdge
    }

    func setTitleSpace(title: String, space: CGFloat) {
        let attr = NSMutableAttributedString(string: title)
        attr.addAttribute(.kern, value: space, range: NSRange(location: 0, length: title.count))
        self.setAttributedTitle(attr, for: .normal)
    }
}
