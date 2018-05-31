//
//  CameraRollCollectionViewCell.swift
//  ARText2
//
//  Created by 石黒晴也 on 2018/05/15.
//  Copyright © 2018年 Haruya Ishiguro. All rights reserved.
//

import UIKit
import Photos

class CustomCollectionViewCell: UICollectionViewCell {

    var imageView: UIImageView! // Cellにイメージを表示するView
    
    var howLongLabel: UILabel! // ビデオの長さを表示する用のラベル
    var playCircleImageView: UIImageView! // ビデオのマークを表示する用のView
     
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // 画像を表示する
    func setConfigure(assets: PHAsset) {

        // Cellのイメージを表示するViewを定義
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        // ビデオの長さを表示する用のラベルを定義
        howLongLabel = UILabel(frame: CGRect(x: frame.width*2/5, y: frame.height*6.5/10, width: frame.width/4, height: frame.height/4))
        howLongLabel.adjustsFontSizeToFitWidth = true // UILabelのフォントサイズをLabelのサイズに合わせて動的に変更する
        howLongLabel.textColor = Style().white
        // ビデオのマークを表示する用のViewを定義
        playCircleImageView = UIImageView(frame: CGRect(x: frame.width*7/10, y: frame.height*7/10, width: frame.width/5, height: frame.height/5))
        let playCircleImage = UIImage(named: "playCircle")
        playCircleImageView.image = playCircleImage

        let manager = PHImageManager()
        manager.requestImage(for: assets,
                             targetSize: frame.size,
                             contentMode: .aspectFill,
                             options: nil,
                             resultHandler: { [weak self] (image, info) in
                                // wselfは各セルのViewを指す
                                guard let wself = self, let outImage = image else {
                                    return
                                }
                                wself.imageView.image = image
                                
                                // 各アセットがビデオの時
                                if (assets.value(forKey: "isVideo") as? Int) == 1{
                                    wself.contentView.addSubview(wself.playCircleImageView)
                                    // 以下ビデオの長さを”1:23”の形式で表示する演算
                                    var sec = Int((assets.value(forKey: "duration") as? Double)!)
                                    let min = sec / 60
                                    sec -= min * 60
                                    let sec_string = String(format: "%02d", sec)
                                    let min_string = String(min)
                                    wself.howLongLabel.text = min_string + ":" + sec_string
                                    
                                    wself.contentView.addSubview(wself.howLongLabel)
                                }
        })
        
        self.contentView.addSubview(imageView)
    }
}
