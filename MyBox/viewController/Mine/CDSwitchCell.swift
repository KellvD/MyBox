//
//  CDSwitchCell.swift
//  MyBox
//
//  Created by changdong on 2020/11/12.
//  Copyright © 2020 changdong. All rights reserved.
//

import UIKit
import SnapKit
typealias SwitchBlock = (_ swi: UISwitch) -> Void
class CDSwitchCell: UITableViewCell {

    public var swi: UISwitch!
    public var titleLabel: UILabel!
    public var valueLabel: UILabel!
    private var separatorLine: UIView!
    public var swiBlock: SwitchBlock!
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        let view = UIView()
        self.selectedBackgroundView = view
        self.selectedBackgroundView?.backgroundColor = .cellSelectColor

        titleLabel = UILabel()
        titleLabel.textColor = .textBlack
        titleLabel.font = .mid
        titleLabel.textAlignment = .left
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15.0)
            make.centerY.equalToSuperview()

        }

        swi = UISwitch()
        swi.addTarget(self, action: #selector(onSwitchClick(swi:)), for: .valueChanged)
        self.contentView.addSubview(swi)
        swi.isHidden = true
        swi.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-15.0)
            make.width.equalTo(50.0)
            make.height.equalTo(30.0)
        }

        valueLabel = UILabel()
        valueLabel.font = .mid
        valueLabel.textColor = .textLightBlack
        valueLabel.textAlignment = .right
        valueLabel.lineBreakMode = .byTruncatingMiddle
        valueLabel.numberOfLines = 0
        self.contentView.addSubview(valueLabel)
        valueLabel.isHidden = true
        valueLabel.snp.makeConstraints { (make) in
            make.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(15.0)
            make.centerY.equalTo(titleLabel)
            make.right.equalToSuperview().offset(-15.0)
        }

        separatorLine = UIView()
        separatorLine.backgroundColor = .separatorColor
        self.addSubview(separatorLine)
        separatorLine.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
            make.left.equalToSuperview().offset(15.0)
            make.right.equalToSuperview().offset(-15.0)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func onSwitchClick(swi: UISwitch) {
        swiBlock(swi)
    }

    public func valueLabelIsAtBottom() {
        valueLabel.isHidden = false
        valueLabel.snp.removeConstraints()
        valueLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15.0)
            make.top.equalTo(titleLabel.snp.bottom)
        }
        valueLabel.font = .small
        valueLabel.textAlignment = .left
    }

    // 分割线是否隐藏
    var separatorLineIsHidden: Bool {
        set {
            separatorLine.isHidden = newValue
        }
        get {
            return false
        }
    }
}
