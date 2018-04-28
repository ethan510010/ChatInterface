//
//  ViewController.swift
//  ChatInterface
//
//  Created by EthanLin on 2018/4/14.
//  Copyright © 2018年 EthanLin. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var getMore = true

    var currentTimeStamp:Double?
    var currentKey:String?
    
    
    //舊的訊息
    var oldMessages:[Message] = [Message]()
    //Users/ethanlin/Desktop/IOS學習/重要/ChatInterface/ChatInterface.xcodeproj
    //本地端接受Firebase的message的
    var messages:[Message] = []{
        didSet{
//            DispatchQueue.main.async {
//                self.chatTableView.reloadData()
//
//            }
        }
    }
    //tableView自動滾動到最後一行
    func scrollToBottom(){
            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
            self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    //根參考點
    let rootReference = Database.database().reference()
    
    //用來接前面一個畫面傳過來的roomID還有更下面的roomName
    var selectedChatRoom:ChatRoom?
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var buttonsAndTextFieldManagerView: UIView!
    
    
    //開啟相機
    @IBAction func openCamera(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    //從相簿選
    @IBAction func openPhotoLibrary(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    //拍完照片或選相片後執行的事
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        //選完後放到Firebase Storage
        //1.先找到Database中的messages的節點
        let messagesRef = rootReference.child("Messages")
        guard let selectedChatRoomID = self.selectedChatRoom?.autoID else { return }
        let singleMessageAutoRef = messagesRef.child(selectedChatRoomID)
        let singleMessageRef = singleMessageAutoRef.childByAutoId()
        //2. 建立Storage放照片的Ref
        let imageMessageStorageRef = Storage.storage().reference().child("photos").child("\(singleMessageRef.key).jpg")
        //3. 調整圖片大小
        let scaledImage = image.scale(newWidth: 640)
        //4. 壓縮圖片
        guard let imageData = UIImageJPEGRepresentation(scaledImage, 0.7) else { return }
        //5. 建立檔案metaData
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        //6. 上傳任務準備
        let uploadTask = imageMessageStorageRef.putData(imageData, metadata: metaData)
        //7. 寫入到Database
        uploadTask.observe(.success) { (snapshot) in
            guard let imageURL = snapshot.metadata?.downloadURL()?.absoluteString else {return}
            //8. 設定這種情況下的訊息沒有文字為純相片訊息去寫進Database
            let postImageMessage :[String:Any] = ["text":"","imageURL":imageURL,"uid":Auth.auth().currentUser?.uid,"timeStamp":ServerValue.timestamp()]
            singleMessageRef.setValue(postImageMessage)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    //送出訊息（寫入到Firebase）
    @IBAction func sendMessage(_ sender: UIButton) {
        //創建訊息群的Ref
        let messagesRef = rootReference.child("Messages")
        //創建訊息Ref
        guard let selectedChatRoomID = self.selectedChatRoom?.autoID else { return }
        let singleMessageAutoRef = messagesRef.child(selectedChatRoomID)
        let singleMessageRef = singleMessageAutoRef.childByAutoId()
        print("按下送出\(singleMessageRef.key)")
        guard let content = textField.text else {return}
        guard content != "" else {return}
        let postMessage: [String:Any] = ["text":content,"imageURL":"","uid":Auth.auth().currentUser?.uid,"timeStamp":ServerValue.timestamp()]
        //寫入到Firebase
        singleMessageRef.setValue(postMessage)
        
        textField.text = ""
        textField.resignFirstResponder()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.rootReference.removeAllObservers()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        chatTableView.separatorStyle = .none
        chatTableView.delegate = self
        chatTableView.dataSource = self
//        //cell自適應
//        chatTableView.estimatedRowHeight = self.view.frame.height * (100/667)
//        chatTableView.rowHeight = UITableViewAutomaticDimension
        //監聽鍵盤事件
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    //從firebase上載入訊息
    func getMessage(){
        if currentKey == nil{
            print("getMessag ", self.currentTimeStamp)

            guard let selectedChatRoom = selectedChatRoom else { return }
            //把firebase的資料載下來，但要限制是只有該room的id有對應到選擇的id
            let messagesRef = rootReference.child("Messages")
            //要到選擇的聊天室的節點
            let chooseMessageRoomRef = messagesRef.child(selectedChatRoom.autoID)
            print("到選擇的聊天室節點:\(chooseMessageRoomRef)")
            //過濾及顯示特定筆數的設定
            //1. 過濾條件
            let request = chooseMessageRoomRef.queryOrdered(byChild: "timeStamp")
            //2. 顯示最新的十筆
            request.queryLimited(toLast: 20).observe(.value) { (snapshot) in
                print("request.queryLimited")
                if snapshot.childrenCount > 0{
                    
                    if snapshot.childrenCount == 1 {
                        self.getMore = false
                    }
                    
                    let first = snapshot.children.allObjects.first as! DataSnapshot
                    print("此key\(first.key)")
                    self.messages = []
                    for eachMessage in snapshot.children.allObjects as! [DataSnapshot]{
                        guard let snapshotValue = eachMessage.value as? Dictionary<String,Any> else {return}
                        print(snapshotValue)
                        guard let contentText = snapshotValue["text"] as? String, let sendImageURL = snapshotValue["imageURL"] as? String, let timeStamp = snapshotValue["timeStamp"] as? Double, let userID = snapshotValue["uid"] as? String else {return}
                        let eachMessage = Message(text: contentText, imageURL: sendImageURL, uid: userID, timeStamp: timeStamp, autoID: eachMessage.key)
                        //加到本地端
                        self.messages.append(eachMessage)
                    }
                    self.currentKey = first.key
                    self.currentTimeStamp = first.childSnapshot(forPath: "timeStamp").value as! Double
                    self.chatTableView.reloadData()
                    self.chatTableView.scrollToRow(at: IndexPath(row: self.messages.count-1, section: 0), at: UITableViewScrollPosition.bottom, animated: false)
                } else {
                    self.getMore = false
                    
                }
            }
        }else {
            print("getMessag ", self.currentTimeStamp)

            guard let selectedChatRoom = selectedChatRoom else { return }
            //把firebase的資料載下來，但要限制是只有該room的id有對應到選擇的id
            let messagesRef = rootReference.child("Messages")
            //要到選擇的聊天室的節點
            let chooseMessageRoomRef = messagesRef.child(selectedChatRoom.autoID)
            print("到選擇的聊天室節點:\(chooseMessageRoomRef)")
            //過濾及顯示特定筆數的設定
            //1. 過濾條件
            let request = chooseMessageRoomRef.queryOrdered(byChild: "timeStamp")
        
            
            request.queryEnding(atValue: self.currentTimeStamp).queryLimited(toLast: 20).observe(.value) { (snapshot) in
                print("request.queryEnding")
                if snapshot.childrenCount > 1 {
                    
                    print("new messags count", snapshot.childrenCount)
                    
                    let first = snapshot.children.allObjects.first as! DataSnapshot
                    let number = snapshot.childrenCount - 2

                    guard let array = snapshot.children.allObjects as? [DataSnapshot] else {
                        return
                    }
                    
                    let last =  array[Int(number)]
                    
                    guard let snapshotValue = last.value as? Dictionary<String,Any> ,  let lastTimeStamp = snapshotValue["timeStamp"] as? Double, lastTimeStamp < self.currentTimeStamp! else {
                        return
                        
                    }
                  
                   
                    
                    for eachMessage in snapshot.children.allObjects as! [DataSnapshot]{
                        guard let snapshotValue = eachMessage.value as? Dictionary<String,Any> else {return}
                        print(snapshotValue)
                        guard let contentText = snapshotValue["text"] as? String, let sendImageURL = snapshotValue["imageURL"] as? String, let timeStamp = snapshotValue["timeStamp"] as? Double, let userID = snapshotValue["uid"] as? String else {return}
                        let eachMessage = Message(text: contentText, imageURL: sendImageURL, uid: userID, timeStamp: timeStamp, autoID: eachMessage.key)
                        //加到本地端
                        self.oldMessages.append(eachMessage)
//                        self.messages.insert(eachMessage, at: 0)
//                        self.messages.append(eachMessage)
                    }
                    self.messages.insert(contentsOf: self.oldMessages, at: 0)
                    self.currentKey = first.key
                    self.currentTimeStamp = first.childSnapshot(forPath: "timeStamp").value as! Double
                    self.chatTableView.reloadData()
                } else {
                    self.getMore = false
                    
                }
            }
            

        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getMessage()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        //cell自適應
//        chatTableView.estimatedRowHeight = UITableViewAutomaticDimension
        chatTableView.estimatedRowHeight = self.view.frame.height * (100/667)
        chatTableView.rowHeight = UITableViewAutomaticDimension
        
        
    }
    
    //鍵盤出現的事件
    @objc func keyboardWillShow(notification: NSNotification){
        let userInfo  = notification.userInfo as! NSDictionary
        var  keyBoardBounds = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        var keyBoardBoundsRect = self.view.convert(keyBoardBounds, to:nil)
        var keyBoardViewFrame = buttonsAndTextFieldManagerView.frame
        var deltaY = keyBoardBounds.size.height
        let animations:(() -> Void) = {
            self.buttonsAndTextFieldManagerView.transform = CGAffineTransform(translationX: 0,y: -deltaY)
        }
        if duration > 0 {
            let options = UIViewAnimationOptions(rawValue: UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
            UIView.animate(withDuration: duration, delay: 0, options:options, animations: animations, completion: nil)
        }else{
            animations()
        }
//        print("the keyboard will appear")
    }
    
    //鍵盤要消失的事件
    @objc func keyboardWillHide(notification: NSNotification){
        let userInfo  = notification.userInfo as! NSDictionary
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let animations:(() -> Void) = {
            self.buttonsAndTextFieldManagerView.transform = CGAffineTransform.identity
        }
        if duration > 0 {
            let options = UIViewAnimationOptions(rawValue: UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
            UIView.animate(withDuration: duration, delay: 0, options:options, animations: animations, completion: nil)
        }else{
            animations()
        }
//        print("the keyboard will hide")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
extension ChatViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        print(indexPath.row)
        
        if indexPath.row == 0 && getMore {
            getMessage()
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.messages[indexPath.row].uid == Auth.auth().currentUser?.uid && messages[indexPath.row].imageURL == ""{
            let sendCell = tableView.dequeueReusableCell(withIdentifier: "SendMessageCell", for: indexPath) as! SendMessageTableViewCell
            sendCell.updateUI(sendMessage: messages[indexPath.row])
            return sendCell
        }else if self.messages[indexPath.row].uid != Auth.auth().currentUser?.uid && messages[indexPath.row].imageURL == ""{
            let recieveCell = tableView.dequeueReusableCell(withIdentifier: "RecieveMessageCell", for: indexPath) as! RecieveMessageTableViewCell
            recieveCell.updateUI(recieveMessage: messages[indexPath.row])
            return recieveCell
        }else if self.messages[indexPath.row].uid == Auth.auth().currentUser?.uid && messages[indexPath.row].imageURL != ""{
            let sendImageCell = tableView.dequeueReusableCell(withIdentifier: "SendImageCell", for: indexPath) as! SendImageMessageTableViewCell
            sendImageCell.updateUI(imageMessage: self.messages[indexPath.row], tableView: tableView)
            return sendImageCell
        }else if self.messages[indexPath.row].uid != Auth.auth().currentUser?.uid && messages[indexPath.row].imageURL != ""{
             let receiveImageCell = tableView.dequeueReusableCell(withIdentifier: "RecieveImageCell", for: indexPath) as! RecieveImageMessageTableViewCell
            receiveImageCell.updateUI(receiveImageMessage: messages[indexPath.row], tableView: tableView)
            return receiveImageCell
        }else{
            return UITableViewCell()
        }
    }
    
   
    
    //實現無線滾動
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if indexPath.row == self.messages.count - 10{
//            self.getMessage()
//        }
//    }
//
    /*
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y
        let maxOffset = scrollView.contentSize.height - scrollView.frame.size.height

        if maxOffset - currentOffset <= 100{
            getMessage()
        }
    }
    */
    //刪除訊息的功能
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            //刪除Firebase端的資料
            
            //找到總messages的key
            let allMessagesRef = rootReference.child("Messages")
            //找到對應特定房間的訊息key，也就是一開始我們設計傳進來的selectedChatRoom的autoID
            guard let selectedChatRoomID = selectedChatRoom?.autoID else {return}
            let messageRoomKey = allMessagesRef.child(selectedChatRoomID)
            //去找到要刪除的message的key，但必須是那個人才可以刪除自己的訊息不能刪別人的
            //以下做法現在是不好的，因為這樣如果有人改我的code就可以改變，正確做法應該是在firebase去規則那邊控制，前端這邊應該只能去做如果不是我發的我不能滑開那個tableView的cell選刪除
            let messageKey = messageRoomKey.child(messages[indexPath.row].autoID)
            print(messageKey)
            
            messageKey.observe(.value, with: { (snapshot) in
                //uid裡面的值剛好為登入的user的uid
                if let correctUserUID = snapshot.childSnapshot(forPath: "uid").value as? String, correctUserUID == Auth.auth().currentUser?.uid{
                    messageKey.removeValue()
                    //刪除本地端資料
                    self.messages.remove(at: indexPath.row)
                }
            })

        }
    }
    
}
