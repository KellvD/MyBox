//
//  CDTextView.swift
//  MyRule
//
//  Created by changdong on 2019/6/28.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit

class CDPhotoEditTextView: UIImageView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        self.image = UIImage(named: "下导航-bg")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
