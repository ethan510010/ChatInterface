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
    
    //本地端接受Firebase的message的
    var messages:[Message] = []{
        didSet{
            DispatchQueue.main.async {
                self.chatTableView.reloadData()
            }
        }
    }
    
    //根參考點
    let rootReference = Database.database().reference()
    
    //用來接前面一個畫面傳過來的roomID還有更下面的roomName
    var selectedChatRoom:ChatRoom?
    
    //    let messages = [Message(speaker: "s1", content: "對這個世界如果你有太多的抱怨跌倒了就不敢繼續往前走為什麼人要這麼的脆弱 墮落請你打開電視看看多少人為生命在努力勇敢的走下去我們是不是該知足珍惜一切就算沒有擁有//////////////////", chatType: "mine", messageImage: nil), Message(speaker: "s2", content: "還記得你說家是唯一的城堡 隨著稻香河流繼續奔跑微微笑 小時候的夢我知道不要哭讓螢火蟲帶著你逃跑 鄉間的歌謠永遠的依靠回家吧 回到最初的美好", chatType: "someone", messageImage: nil),Message(speaker: "s2", content: "不要這麼容易就想放棄 就像我說的追不到的夢想 換個夢不就得了為自己的人生鮮艷上色 先把愛塗上喜歡的顏色///////////", chatType: "someone", messageImage: nil),Message(speaker: "s1", content: "笑一個吧 功成名就不是目的讓自己快樂快樂這才叫做意義//////////", chatType: "mine", messageImage: nil), Message(speaker: "s1", content: nil, chatType: "mine", messageImage: "s1"),Message(speaker: "s1", content: nil, chatType: "mine", messageImage: "s15"),Message(speaker: "s1", content: "笑一個吧 功成名就不是目的讓自己快樂快樂這才叫做意義//////////", chatType: "mine", messageImage: nil), Message(speaker: "s2", content: nil, chatType: "someone", messageImage: "s15")]
    
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
        let size = CGSize(width: 320, height: image.size.height * 320 / image.size.width)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let imageData = UIImageJPEGRepresentation(resizeImage!, 0.8) else { return }
        print(imageData)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        //創建訊息群的Ref
        let messagesRef = rootReference.child("Messages")
        //創建訊息Ref
        guard let selectedChatRoomID = self.selectedChatRoom?.autoID else { return }
        let singleMessageAutoRef = messagesRef.child(selectedChatRoomID)
        let singleMessageRef = singleMessageAutoRef.childByAutoId()
        let postMessage: [String:Any] = ["text":textField.text!,"imageURL":"","uid":Auth.auth().currentUser?.uid,"timeStamp":ServerValue.timestamp()]
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
        guard let selectedChatRoom = selectedChatRoom else { return }
//        print("傳過來的聊天室\(selectedChatRoom.autoID) && \(selectedChatRoom.chatRoomName)")
        //把firebase的資料載下來，但要限制是只有該room的id有對應到選擇的id
        let messagesRef = rootReference.child("Messages")
        
        messagesRef.observe(.value) { (snapshot) in
            self.messages = []
            //找出裡面全部的訊息
            for messageRoom in snapshot.children.allObjects as! [DataSnapshot]{
                print(messageRoom)
                //在這邊判斷messageRoom的key值是不是為selectedChatRoom傳過來的ID，是的話去載入對應的資料
                if messageRoom.key == selectedChatRoom.autoID{
                    for eachMessage in messageRoom.children.allObjects as! [DataSnapshot]{
                        guard let snapshotValue = eachMessage.value as? Dictionary<String,Any> else {return}
                        print(snapshotValue)
                        guard let contentText = snapshotValue["text"] as? String, let sendImageURL = snapshotValue["imageURL"] as? String, let timeStamp = snapshotValue["timeStamp"] as? Double, let userID = snapshotValue["uid"] as? String else {return}
                        let eachMessage = Message(text: contentText, imageURL: sendImageURL, uid: userID, timeStamp: timeStamp, autoID: eachMessage.key)
                        self.messages.append(eachMessage)
                    }
                }
                
                //                guard let snapshotValue = eachMessage.value as? Dictionary<String,Any> else {return}
                //                print(snapshotValue)
                //                guard let contentText = snapshotValue["text"] as? String, let sendImageURL = snapshotValue["imageURL"] as? String, let timeStamp = snapshotValue["timeStamp"] as? Double, let userID = snapshotValue["uid"] as? String else {return}
                //                let eachMessage = Message(text: contentText, imageURL: sendImageURL, uid: userID, timeStamp: timeStamp, autoID: eachMessage.key)
                //                self.messages.append(eachMessage)
            }
            
        }
        
        chatTableView.separatorStyle = .none
        chatTableView.delegate = self
        chatTableView.dataSource = self
        //cell自適應
        chatTableView.estimatedRowHeight = self.view.frame.height * (100/667)
        chatTableView.rowHeight = UITableViewAutomaticDimension
        //監聽鍵盤事件
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
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
        print("the keyboard will appear")
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
        print("the keyboard will hide")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
extension ChatViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
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
        }
        //        if messages[indexPath.row].chatType == "mine" && messages[indexPath.row].messageImage == nil{
        //            let sendCell = tableView.dequeueReusableCell(withIdentifier: "SendMessageCell", for: indexPath) as! SendMessageTableViewCell
        //            sendCell.updateUI(sendMessage: messages[indexPath.row])
        //            sendCell.makeCircleAvatar()
        //            return sendCell
        //        }else if messages[indexPath.row].chatType == "mine" && messages[indexPath.row].messageImage != nil {
        //            let sendImageCell = tableView.dequeueReusableCell(withIdentifier: "SendImageCell", for: indexPath) as! SendImageMessageTableViewCell
        //            sendImageCell.updateUI(imageMessage: messages[indexPath.row])
        //            return sendImageCell
        //        }else if messages[indexPath.row].chatType == "someone" && messages[indexPath.row].messageImage != nil{
        //            let receiveImageCell = tableView.dequeueReusableCell(withIdentifier: "RecieveImageCell", for: indexPath) as! RecieveImageMessageTableViewCell
        //            receiveImageCell.updateUI(receiveImageMessage: messages[indexPath.row])
        //            return receiveImageCell
        //        }else{
        //            let recieveCell = tableView.dequeueReusableCell(withIdentifier: "RecieveMessageCell", for: indexPath) as! RecieveMessageTableViewCell
        //            recieveCell.updateUI(recieveMessage: messages[indexPath.row])
        //            recieveCell.makeCircleAvatar()
        //            return recieveCell
        //        }
        return UITableViewCell()
    }
    
    
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
//                    self.messages.remove(at: indexPath.row)
                }
            })

        }
    }
    
}
