//
//  CDAessetSelectionDelegate.swift
//  MyRule
//
//  Created by changdong on 2019/5/6.
//  Copyright © 2019 changdong. All rights reserved.
//

import Foundation
protocol CDAessetSelectionDelagete{
    func selectedAssets(assets:[CDPHAsset])
}

protocol CDAssetDelegate {
    func assetSelected(asset:CDPHAsset)
}
