//
//  CDBrightView.swift
//  MyRule
//
//  Created by changdong on 2019/6/28.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit

class CDBrightView: UICollectionView,UICollectionViewDelegate,UICollectionViewDataSource {
    var tools:[CDBirghtModel] = []
    var sliderView:CDSliderView!


    init(frame:CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width:(frame.width - 30)/5 , height: 48)
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        layout.scrollDirection = .horizontal
        super.init(frame: frame, collectionViewLayout: layout)
        self.backgroundColor = UIColor.black
        self.delegate = self
        self.dataSource = self
        self.register(CDBrightViewCell.self, forCellWithReuseIdentifier: "CDBrightViewCell")
        let titleArr = ["亮度","对比度","饱和度","色相","曝光度","色温","锐度","黑色暗角","白色暗角"]
        for i in 0..<titleArr.count{
            let model = CDBirghtModel()
            let type = CDBrightType(rawValue: i)
            model.title = titleArr[i]
            model.type = type
            tools.append(model)
        }

        sliderView = CDSliderView(frame: CGRect(x: 0, y: CDSCREEN_HEIGTH, width: CDSCREEN_WIDTH, height: 30))
        CDEditManager.shareInstance().editVC.view.addSubview(sliderView)
        sliderView.isHidden = true
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tools.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CDBrightViewCell", for: indexPath) as! CDBrightViewCell

        let moedl = tools[indexPath.item]
        cell.loadData(itemStr: moedl.title)
        cell.backgroundColor = UIColor.clear
        return cell

    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        UIView.animate(withDuration: 0.25, animations: {
            var rect = self.sliderView.frame
            if self.sliderView.isHidden{
                if indexPath.item < 6{
                    self.sliderView.slider.minimumValue = -50
                    self.sliderView.slider.maximumValue = 50
                }else{
                    self.sliderView.slider.minimumValue = 0
                    self.sliderView.slider.maximumValue = 100
                }
                rect.origin.y = CDSCREEN_HEIGTH - 48 - 30
            }else{
                rect.origin.y = CDSCREEN_HEIGTH
            }
            self.sliderView.frame = rect

        }) { (flag) in
            self.sliderView.isHidden = !self.sliderView.isHidden

        }

        let moedl = tools[indexPath.item]
        CDEditManager.shareInstance().onBrightItemSelected(brightType: moedl.type)

    }

}

class CDBrightViewCell: UICollectionViewCell {

    var itemLabel:UILabel!
    var imageView:UIImageView!
    var isSelect:Bool = false
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isSelected = false
        imageView = UIImageView(frame: CGRect(x: frame.width/2 - 9, y: 9, width: 18, height: 14))
        self.addSubview(imageView)


        itemLabel = UILabel(frame: CGRect(x: 2, y: 28, width: frame.width - 4, height: 16))
        itemLabel.font = UIFont.systemFont(ofSize: 12)
        itemLabel.textColor = UIColor.white
        itemLabel.textAlignment = .center
        self.addSubview(itemLabel)

    }

    func loadData(itemStr:String){

        itemLabel.text = itemStr
        imageView.image = UIImage(named: itemStr)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


class CDSliderView: UIView {

    var slider:UISlider!
    var minLabel:UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 0.5

        minLabel = UILabel(frame: CGRect(x: 15, y: 5, width: 20, height: 20))
        minLabel.textColor = TextGrayColor
        minLabel.backgroundColor = UIColor.clear
        minLabel.font = TextSmallFont
        minLabel.text = "0"
        minLabel.adjustsFontSizeToFitWidth = true
        self.addSubview(minLabel)

        slider = UISlider(frame: CGRect(x: 35, y: 5, width: frame.width - 50, height: 15))
        slider.value = 0
        slider.minimumTrackTintColor = UIColor.red
        slider.maximumTrackTintColor = UIColor.gray
        slider.addTarget(self, action: #selector(sliderChange(slider:)), for: .valueChanged)
        self.addSubview(slider)

        

    }


    @objc func sliderChange(slider:UISlider){

        minLabel.text = "\(Int(slider.value))"
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
