//
//  sceneView.swift
//  ARText2
//
//  Created by 石黒晴也 on 2018/05/04.
//  Copyright © 2018年 Haruya Ishiguro. All rights reserved.
//

import UIKit
import SceneKit
import SpriteKit
import ARKit
import SnapKit

class ARViewController: UIViewController, ARSCNViewDelegate, UITextFieldDelegate {
    
    var sceneView: ARSCNView!
    var shutterButton:    UIButton! // シャッターボタン
    var toPutTextButton:  UIButton! // 文字追加用ボタン
    var toPutImageButton: UIButton! // イメージ追加用ボタン
        
    var testTextField: UITextField! // 文字追加用ボタンを押した時に出る文字入力欄
    
    var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ARSCNViewを定義
        sceneView = ARSCNView()
        sceneView.delegate = self
        view.addSubview(sceneView)
        // シャッターボタンを定義
        shutterButton = UIButton()
        shutterButton.setImage(UIImage(named: "shutter"), for: .normal)
        shutterButton.addTarget(self, action: #selector(ARViewController.onClickShutterButton(_:)), for: .touchUpInside)
        view.addSubview(shutterButton)
        // 文字追加用ボタンを定義
        toPutTextButton = UIButton()
        toPutTextButton.setImage(UIImage(named: "toPutText"), for: .normal)
        toPutTextButton.tintColor = Style().white
        toPutTextButton.addTarget(self, action: #selector(ARViewController.onClickToPutTextButton(_:)), for: .touchUpInside)
        view.addSubview(toPutTextButton)
        // イメージ追加用ボタンを定義
        toPutImageButton = UIButton()
        toPutImageButton.setImage(UIImage(named: "toPutImage"), for: .normal)
        toPutImageButton.tintColor = Style().white
        toPutImageButton.addTarget(self, action: #selector(ARViewController.onClickToPutImageButton(_:)), for: .touchUpInside)
        view.addSubview(toPutImageButton)
        // 文字追加用ボタンを押した時に出る文字入力欄を定義
        testTextField = UITextField()
        testTextField.borderStyle = UITextBorderStyle.roundedRect // 枠を表示する
        testTextField.delegate = self
        view.addSubview(testTextField)
        testTextField.isHidden = true
        
        // 大きさと座標
        // ARSCNView
        sceneView.snp.makeConstraints{(make) in
            make.width.equalTo(view.snp.width)
            make.height.equalTo(view.snp.height)
        }
        // シャッターボタン
        shutterButton.snp.makeConstraints{(make) in
            make.width.equalTo(70)
            make.height.equalTo(70)
            make.centerX.equalTo(view.snp.centerX)
            make.bottom.equalTo(view.snp.bottom).offset(-10)
        }
        // 文字追加用ボタン
        toPutTextButton.snp.makeConstraints{(make) in
            make.width.equalTo(50)
            make.height.equalTo(50)
            make.right.equalTo(view.snp.right).offset(-20)
            make.centerY.equalTo(shutterButton.snp.centerY)
        }
        // イメージ追加用ボタン
        toPutImageButton.snp.makeConstraints{(make) in
            make.width.equalTo(50)
            make.height.equalTo(50)
            make.left.equalTo(view.snp.left).offset(20)
            make.centerY.equalTo(shutterButton.snp.centerY)
        }
        // 文字追加用ボタンを押した時に出る文字入力欄
        testTextField.snp.makeConstraints { (make) in
            make.width.equalTo(200)
            make.height.equalTo(30)
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.snp.centerY)
        }
        
        // 影を表現する機能をオンにする
        sceneView.autoenablesDefaultLighting = true
        
        
        // 画面タップのレコナイザを定義(タップされたらhandleTapを呼ぶ)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    // 文字追加用ボタンが押された時に呼ばれる関数
    @objc private func onClickToPutTextButton(_ sender: UIButton){
        testTextField.isHidden = false
        testTextField.becomeFirstResponder()
    }
    
    // return(改行)が押された時にキーボード閉じるやつ(TextFieldのDelegate呼ばないと呼ばれない)
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        testTextField.isHidden = true
        textShow3D(moji: testTextField.text!)
        return true
    }
    // TextField以外の部分をタッチした時にキーボード閉じるやつ
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        testTextField.isHidden = true
        //textShow3D(moji: testTextField.text!)
    }
    
    // SceneKitで文字を表示する関数
    private func textShow3D(moji: String){
        //スマホの座標に更新する
        if let camera = sceneView.pointOfView {
            let position = SCNVector3(x: 0, y: 0, z: -1) // z軸は正面がマイナス
            let convertPosition = camera.convertPosition(position, to: nil)
            let angle = camera.eulerAngles // カメラのオイラー角に更新する
            
            let text = SCNText(string: moji, extrusionDepth: 1)
            text.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 20)
            // マテリアルオブジェクトを作成して，色，マテリアルに文字を与える
            let material = SCNMaterial()
            material.diffuse.contents = Style().white
            text.materials = [material]
            
            // ノードオブジェクトを作成して座標，大きさ，文字を定義する
            let node = SCNNode()
            node.position    = convertPosition
            node.eulerAngles = angle
            node.scale       = SCNVector3(x: 0.01, y: 0.01, z: 0.000001)
            node.geometry    = text
            
            // sceneViewにノードを追加
            sceneView.scene.rootNode.addChildNode(node)
        }
    }
    
    // シャッターボタンが押された時に呼ばれる関数
    @objc func onClickShutterButton(_ sender: UIButton){
        if isRecording { // 録画終了
        }
        else{ // 録画開始
            // ARSCNViewがフレームを検知できなければ処理を終了する
            guard let currentFrame = self.sceneView.session.currentFrame else{
                return
            }
            
            /* 動画ノード表示用
            // SpriteKitのフレームワークの一つでビデオノードを生成し，再生する
            let videoNode = SKVideoNode(fileNamed: "IMG_2006.MOV")
            videoNode.play()
            
            // SKVideoNodeはSpriteKitシーンにのみ追加できるため，SpriteKitシーンを生成
            // ビデオノードはSpriteKitシーンと同じ大きさにする
            let skScene = SKScene(size: CGSize(width: 640, height: 480))
            skScene.addChild(videoNode)
            videoNode.position = CGPoint(x: skScene.size.width/2, y: skScene.size.height/2)
            videoNode.size = skScene.size
            */
            
            /* WebView表示用
            // UIWevViewを表示させることもできる
            let webView = UIWebView(frame: CGRect(x: 0, y: 0, width: 640, height: 480))
            let request = URLRequest(url: URL(string: "https://www.kumamoto-u.ac.jp/")!)
            
            webView.loadRequest(request)
            */
            
            let myLabel = SKLabelNode(fontNamed: "AppleSDGothicNeo-Bold")
            myLabel.text = "SpriteKit"
            myLabel.fontSize = 40
            myLabel.fontColor = Style().white
            let skScene = SKScene(size: CGSize(width: 640, height: 480))
            skScene.backgroundColor = Style().invisivle // 透明にしても文字とSKSceneとの境界がSceneの色になることに注意
            myLabel.position = CGPoint(x: skScene.size.width/2, y: skScene.size.height/2)
            skScene.addChild(myLabel)
            
            
            // SceneKitの世界(3Dの世界)で2D平面のSCNPlaneオブジェクトを生成する
            let tvPlane = SCNPlane(width: 1.0, height: 0.75)
            //let tvPlane = SCNSphere(radius: 0.2) //
            tvPlane.name = myLabel.text
            // diffuse.contentsを使ってtvPlaneに貼り付けてる
            //tvPlane.firstMaterial?.diffuse.contents = skScene
            //tvPlane.firstMaterial?.diffuse.contents = webView
            let material = SCNMaterial()
            material.diffuse.contents = Style().skyblue
            tvPlane.materials = [material]
            tvPlane.firstMaterial?.diffuse.contents = skScene
            
            tvPlane.firstMaterial?.isDoubleSided = true
            
            let tvPlaneNode = SCNNode(geometry: tvPlane)
            
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -0.5
            
            tvPlaneNode.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
            tvPlaneNode.eulerAngles = SCNVector3(Double.pi, 0, 0)
            //tvPlaneNode.eulerAngles = SCNVector3(0, 0, 0)
            
            self.sceneView.scene.rootNode.addChildNode(tvPlaneNode)
        }
        isRecording = !isRecording
    }
    
    // イメージ追加ボタンが押された時に呼ばれる関数
    @objc private func onClickToPutImageButton(_ sender: UIButton){
        // ImagesViewControllerのインスタンスを定義する
        let imagesViewController: UIViewController = ImagesViewController()
        // アニメーションを設定する
        imagesViewController.modalTransitionStyle = .coverVertical // 下からスライド（他３種類）
        // Viewを移動する
        self.present(imagesViewController, animated: true, completion: nil)
    }
    
    // 画面がタップされた時に呼ばれる関数(tapGestureから)
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer){
        // ARSCNViewがフレームを検知できなければ処理を終了する
        guard let currentFrame = self.sceneView.session.currentFrame else{
            return
        }
        // sceneViewのどこがタップされたかを返す
        let p = gestureRecognize.location(in: sceneView)
        // どのノードがタップされたかをhitResults(配列)に返す
        let hitResults = sceneView.hitTest(p, options: [:])
        
        // タップされたノードがある場合
        if hitResults.count > 0 {
            // タップされたノードの1番目
            let result: AnyObject = hitResults[0]
            
            // 即席だからやり方は雑
            let myLabel = SKLabelNode(fontNamed: "AppleSDGothicNeo-Bold")
            myLabel.text = "タップされましたよ"
            myLabel.fontSize = 40
            myLabel.fontColor = Style().white
            let skScene = SKScene(size: CGSize(width: 640, height: 480))
            skScene.backgroundColor = Style().invisivle // 透明にしても文字とSKSceneとの境界がSceneの色になることに注意
            myLabel.position = CGPoint(x: skScene.size.width/2, y: skScene.size.height/2)
            skScene.addChild(myLabel)
            
            result.node!.geometry!.firstMaterial!.diffuse.contents = skScene
        
            print("当たってますよ")
        }
    }
    
    
    //(以下デフォルト)-------------------------------------------------------------------------------
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    // 画面から非表示になる直前に呼ばれる(ARSCNのデフォルト)
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // メモリー不足でインスタンスが記される直前に呼ばれる(ARSCNのデフォルト)
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        print(error)
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
    
}
