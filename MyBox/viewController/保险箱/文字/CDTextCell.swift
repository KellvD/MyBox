//
//  CDTextCell.swift
//  MyRule
//
//  Created by changdong on 2018/12/28.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit

class CDTextCell: UITableViewCell {

    var titleLabel:UILabel!
    var bottomLine:UIView!
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        titleLabel = UILabel(frame: CGRect(x: 0, y: 4, width: frame.width, height: 40))
        titleLabel.font = TextMidSmallFont
        self.addSubview(titleLabel)
        bottomLine = UIView(frame: CGRect(x: 0, y: 46, width: frame.width, height: 2))
        bottomLine.backgroundColor = CustomBlueColor
        self.addSubview(bottomLine)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
