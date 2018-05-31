

import UIKit
import Photos

class ImagesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    var imagesCollectionView: UICollectionView! // 写真・動画のイメージ表示用
    var imagesAssets: Array! = [PHAsset]() // PhotosのAssetを格納するための配列
    
    var virtualHeader: UILabel! // ヘッダの役割のラベル
    var backButton: UIButton! // 撮影画面に戻るためのボタン→おいおいスライドで戻れるようにしたい
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // CollectionViewのレイアウトを生成
        let layout = UICollectionViewFlowLayout()
        // Cell一つ一つの大きさ
        layout.itemSize = CGSize(width: view.bounds.width / 3 - 3, height: view.bounds.width / 3 - 3)
        // Cellのマージン
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0) // top, left, bottom, right
        layout.minimumInteritemSpacing = 3 // アイテム間(この辺定義しないとデフォルトで隙間が空く)
        layout.minimumLineSpacing = 3 // 行間
        // セクション毎のヘッダーサイズ
        layout.headerReferenceSize = CGSize(width:100,height:60)
        layout.sectionHeadersPinToVisibleBounds = true
        
        // CollectionViewを生成
        imagesCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        // Cellに使われるクラスを登録
        imagesCollectionView.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: "MyCell")
        imagesCollectionView.backgroundColor = Style().dark_gray
        imagesCollectionView.delegate = self
        imagesCollectionView.dataSource = self
        view.addSubview(imagesCollectionView)
        
        // ヘッダの役割のラベルの定義
        virtualHeader = UILabel()
        virtualHeader.backgroundColor = Style().dark_gray
        imagesCollectionView.addSubview(virtualHeader)
        // 撮影画面に戻るボタンの定義
        backButton = UIButton()
        backButton.setImage(UIImage(named: "back2PhotoGraphing"), for: .normal)
        backButton.tintColor = Style().background_gray
        backButton.addTarget(self, action: #selector(ImagesViewController.onClickBackButton(_:)), for: .touchUpInside)
        imagesCollectionView.addSubview(backButton)
        
        // ヘッダの役割のラベル
        virtualHeader.snp.makeConstraints{(make) in
            make.width.equalTo(view.snp.width)
            make.height.equalTo(70)
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(view.snp.top) // これがないとCollectionViewと一緒に流れてしまう(固定されない)
        }
        // 戻るボタン
        backButton.snp.makeConstraints{(make) in
            make.width.equalTo(75)
            make.height.equalTo(15)
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(view.snp.top).offset(40) // これがないとCollectionViewと一緒に流れてしまう(固定されない)
        }
        
        // カメラロールへのアクセス許可をする関数
        libraryRequestAuthorization()
    }
    
    @objc func onClickBackButton(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
        print("tapped")
    }
    
    // カメラロールへのアクセス許可をする関数
    private func libraryRequestAuthorization(){
        PHPhotoLibrary.requestAuthorization({ [weak self] status in
            guard let wself = self else {
                return
            }
            switch status {
            case .authorized:
                wself.getAllPhotosInfo()
            case .denied:
                wself.showDeniedAlert()
            case .notDetermined:
                print("NotDetermined")
            case .restricted:
                print("Restricted")
            }
        })
    }
    // カメラロールから全て取得する
    fileprivate func getAllPhotosInfo() {
        // 写真と動画は一気に取れないっぽいから別々で取得してから後でソートする
        let assetsImage: PHFetchResult = PHAsset.fetchAssets(with: .image, options: nil)
        let assetsVideo: PHFetchResult = PHAsset.fetchAssets(with: .video, options: nil)
        
        // 作成日付でソートするための辞書
        var dateDictionary = [Int:Date]()
        // インデックス参照用
        var count = 0
        
        // カメラロールからデータを取得(写真)
        assetsImage.enumerateObjects({ [weak self] (asset, index, stop) -> Void in
            guard let wself = self else {
                return
            }
            wself.imagesAssets.append(asset as PHAsset)
            dateDictionary[count] = asset.value(forKey: "creationDate") as? Date // Date型なるものがある
            count += 1
        })
        // カメラロールからデータを取得(動画)
        assetsVideo.enumerateObjects({ [weak self] (asset, index, stop) -> Void in
            guard let wself = self else {
                return
            }
            wself.imagesAssets.append(asset as PHAsset)
            dateDictionary[count] = asset.value(forKey: "creationDate") as? Date
            count += 1
        })
        
        // 作成日付をもとにソートした辞書を定義
        let sortedDateDictionary = dateDictionary.sorted{$0.value > $1.value}
        // ソート後のimageAssetsを初期化
        var sortedImagesAssets: Array! = [PHAsset]()
        
        // 作成日付に基づいて写真と動画を一緒にした配列を生成
        for(index, _) in sortedDateDictionary{
            sortedImagesAssets.append(imagesAssets[index])
        }

        // imageAssetsを更新
        self.imagesAssets = sortedImagesAssets
        
        // サブスレッドで実行(これやらないと遅くなる)
        DispatchQueue.global(qos: .default).async {
            // サブスレッド(バックグラウンド)で実行する方の処理
            DispatchQueue.main.async {
                self.imagesCollectionView.reloadData()
            }
        }
    }
    
    // カメラロールへのアクセスが拒否されている場合のアラート
    fileprivate func showDeniedAlert() {
        let alert: UIAlertController = UIAlertController(title: "エラー",
                                                         message: "「写真」へのアクセスが拒否されています。設定より変更してください。",
                                                         preferredStyle: .alert)
        let cancel: UIAlertAction = UIAlertAction(title: "キャンセル",
                                                  style: .cancel,
                                                  handler: nil)
        let ok: UIAlertAction = UIAlertAction(title: "設定画面へ",
                                              style: .default,
                                              handler: { [weak self] (action) -> Void in
                                                guard let wself = self else {
                                                    return
                                                }
                                                wself.transitionToSettingsApplition()
        })
        alert.addAction(cancel)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func transitionToSettingsApplition() {
        let url = URL(string: UIApplicationOpenSettingsURLString)
        if let url = url {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    // Cellに値を設定する
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Num: \(indexPath.row)")
    }
    // Cellに値を設定する
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesAssets.count
    }
    // Cellに値を設定する
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : CustomCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as! CustomCollectionViewCell
        cell.setConfigure(assets: imagesAssets[indexPath.row])
        
        return cell
    }
    
}
