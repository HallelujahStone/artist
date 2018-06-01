//
//  AssetsHandling.swift
//  ARText2
//
//  Created by 石黒晴也 on 2018/06/02.
//  Copyright © 2018年 Haruya Ishiguro. All rights reserved.
//
import Photos

class AssetsHandling {
    
    // PHAssetからURLを取得する関数(使い方は癖があるけど，URLはresponseURLに入り，type(自作)にimage(0)かvideo(0)かが入る)
    func getURL(ofPhotoWith mPhasset: PHAsset, completionHandler : @escaping ((_ responseURL: URL?, _ type: Int?) -> Void)) {
        
        if mPhasset.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            mPhasset.requestContentEditingInput(with: options, completionHandler: { (contentEditingInput, info) in
                completionHandler(contentEditingInput!.fullSizeImageURL, 0)
            })
        } else if mPhasset.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: mPhasset, options: options, resultHandler: { (asset, audioMix, info) in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl = urlAsset.url
                    completionHandler(localVideoUrl, 1)
                } else {
                    completionHandler(nil, nil)
                }
            })
        }
    }
}
