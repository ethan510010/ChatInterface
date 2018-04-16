//
//  ViewController.swift
//  ChatInterface
//
//  Created by EthanLin on 2018/4/14.
//  Copyright © 2018年 EthanLin. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {
    
    let messages = [Message(speaker: "s1", content: "對這個世界如果你有太多的抱怨跌倒了就不敢繼續往前走為什麼人要這麼的脆弱 墮落請你打開電視看看多少人為生命在努力勇敢的走下去我們是不是該知足珍惜一切就算沒有擁有//////////////////", chatType: .mine, messageImage: nil), Message(speaker: "s2", content: "還記得你說家是唯一的城堡 隨著稻香河流繼續奔跑微微笑 小時候的夢我知道不要哭讓螢火蟲帶著你逃跑 鄉間的歌謠永遠的依靠回家吧 回到最初的美好", chatType: .someone, messageImage: nil),Message(speaker: "s2", content: "不要這麼容易就想放棄 就像我說的追不到的夢想 換個夢不就得了為自己的人生鮮艷上色 先把愛塗上喜歡的顏色///////////", chatType: .someone, messageImage: nil),Message(speaker: "s1", content: "笑一個吧 功成名就不是目的讓自己快樂快樂這才叫做意義//////////", chatType: .mine, messageImage: nil), Message(speaker: "s1", content: nil, chatType: .mine, messageImage: "s1"),Message(speaker: "s1", content: nil, chatType: .mine, messageImage: "s15"),Message(speaker: "s1", content: "笑一個吧 功成名就不是目的讓自己快樂快樂這才叫做意義//////////", chatType: .mine, messageImage: nil), Message(speaker: "s2", content: nil, chatType: .someone, messageImage: "s15")]
    
    @IBOutlet weak var chatTableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        chatTableView.separatorStyle = .none
        chatTableView.delegate = self
        chatTableView.dataSource = self
        //cell自適應
        chatTableView.estimatedRowHeight = self.view.frame.height * (100/667)
        chatTableView.rowHeight = UITableViewAutomaticDimension
       
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
        if messages[indexPath.row].chatType == .mine && messages[indexPath.row].messageImage == nil{
            let sendCell = tableView.dequeueReusableCell(withIdentifier: "SendMessageCell", for: indexPath) as! SendMessageTableViewCell
            sendCell.updateUI(sendMessage: messages[indexPath.row])
            sendCell.makeCircleAvatar()
            return sendCell
        }else if messages[indexPath.row].chatType == .mine && messages[indexPath.row].messageImage != nil {
            let sendImageCell = tableView.dequeueReusableCell(withIdentifier: "SendImageCell", for: indexPath) as! SendImageMessageTableViewCell
            sendImageCell.updateUI(imageMessage: messages[indexPath.row])
            return sendImageCell
        }else if messages[indexPath.row].chatType == .someone && messages[indexPath.row].messageImage != nil{
            let receiveImageCell = tableView.dequeueReusableCell(withIdentifier: "RecieveImageCell", for: indexPath) as! RecieveImageMessageTableViewCell
            receiveImageCell.updateUI(receiveImageMessage: messages[indexPath.row])
            return receiveImageCell
        }else{
            let recieveCell = tableView.dequeueReusableCell(withIdentifier: "RecieveMessageCell", for: indexPath) as! RecieveMessageTableViewCell
            recieveCell.updateUI(recieveMessage: messages[indexPath.row])
            recieveCell.makeCircleAvatar()
            return recieveCell
        }
    }
    
    
}
