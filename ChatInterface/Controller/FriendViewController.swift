//
//  FriendViewController.swift
//  ChatInterface
//
//  Created by EthanLin on 2018/4/16.
//  Copyright © 2018年 EthanLin. All rights reserved.
//

import UIKit
import Firebase

class FriendViewController: UIViewController {
    
    //根參考點
    let rootReference = Database.database().reference()
    //用來接受Firebase端傳下來的
    var chatRooms:[ChatRoom] = []{
        didSet{
            DispatchQueue.main.async {
                self.friendTableView.reloadData()
            }
        }
    }
    
    var roomName:String?
    var roomID:String?
    
    @IBOutlet weak var createChatRoomTextField: UITextField!
    @IBAction func createChatRoomAction(_ sender: UIButton) {
        //創建聊天室，寫入到Firebase
        guard let chatRoomName = createChatRoomTextField.text else { return }
        //輸入的字串不為空
        guard chatRoomName != "" else {return}
        //總聊天室
        let chatRoomsReference = rootReference.child("chatRooms")
        //內部子聊天室
        //1.內部每個子聊天室要有一個自動id可以做區隔，避免聊天室名字重複
        //所以在每個聊天室創建之前先有一個ID
        let eachChatRoomRef = chatRoomsReference.childByAutoId()
        //創建聊天室
        let eachChatRoom:[String:Any] = ["chatRoomName":chatRoomName]
        //寫進Firebase
        eachChatRoomRef.setValue(eachChatRoom)
        //把textField歸零
        self.createChatRoomTextField.text = ""
    }
    
    
    
    @IBOutlet weak var friendTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        friendTableView.delegate = self
        friendTableView.dataSource = self
        
        //從Firebase抓資料下來
        let chatRoomsReference = rootReference.child("chatRooms")
        chatRoomsReference.observe(.value) { (snapshot) in
            self.chatRooms = []
            //  找出裡面全部的資料
            for eachRoom in snapshot.children.allObjects as! [DataSnapshot]{
                print(eachRoom)
                guard let snapshotValue = eachRoom.value as? Dictionary<String,Any> else {return}
                print(snapshotValue)
                guard let chatRoomName = snapshotValue["chatRoomName"] as? String else {return}
                let eachChatRoom = ChatRoom(chatRoomName: chatRoomName, autoID: eachRoom.key)
                print(eachChatRoom.autoID)
                print(eachChatRoom.chatRoomName)
                self.chatRooms.append(eachChatRoom)
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
extension FriendViewController: UITableViewDelegate, UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatRooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let friendCell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath)
        friendCell.selectionStyle = .none
        friendCell.textLabel?.text = chatRooms[indexPath.row].chatRoomName
        return friendCell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .groupTableViewBackground
        return footerView
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            //刪除Firebase端的資料
            //得到裡面的聊天室們陣列
            let key = chatRooms[indexPath.row].autoID
            print(key)
            //得到總房間的Ref
            let allRoomsRef = rootReference.child("chatRooms")
            //再去刪除該對應的key
            allRoomsRef.child(key).removeValue()
            //刪除本地端資料，其實這邊可以不用刪除，因為我們是監聽value的變化，我們有在viewDidLoad加上與chatRooms的處理，那邊動本地端就會動，所以這邊不需要處理
            self.chatRooms.remove(at: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToChatRoom", sender: chatRooms[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "goToChatRoom" else {return}
        guard let chatViewController = segue.destination as? ChatViewController else { return }
        guard let passedChatRoom = sender as? ChatRoom else {return}
        chatViewController.selectedChatRoom = passedChatRoom

    }
    
}
