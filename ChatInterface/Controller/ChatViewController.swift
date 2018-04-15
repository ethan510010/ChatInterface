//
//  ViewController.swift
//  ChatInterface
//
//  Created by EthanLin on 2018/4/14.
//  Copyright © 2018年 EthanLin. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {
    
    let messages = [Message(speaker: "s1", content: "別堆砌懷念讓劇情變得狗血,深愛了多年又何必毀了經典,都已成年不拖不欠,浪費時間是我情願,像謝幕的演員,眼看著燈光熄滅,別堆砌懷念讓劇情變得狗血,深愛了多年又何必毀了經典,都已成年不拖不欠,浪費時間是我情願,像謝幕的演員,眼看著燈光熄滅,浪費時間是我情願,像謝幕的演員,眼看著燈光熄滅", chatType: .mine), Message(speaker: "s2", content: "來不及再轟轟烈烈,就保留告別的尊嚴,我愛你不後悔也尊重故事結尾", chatType: .someone),Message(speaker: "s2", content: "分手應該體面誰都不要說抱歉,何來虧欠我敢給就敢心碎,鏡頭前面是從前的我們,在喝彩流著淚聲嘶力竭", chatType: .someone),Message(speaker: "s1", content: "離開也很體面才沒辜負這些年,愛得熱烈認真付出的畫面,別讓執念毀掉了昨天,我愛過你利落乾脆", chatType: .someone)]
    
    @IBOutlet weak var chatTableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        chatTableView.separatorStyle = .none
        chatTableView.delegate = self
        chatTableView.dataSource = self
        chatTableView.estimatedRowHeight = self.view.frame.height * (100/667)
        
//        chatTableView.rowHeight = UITableViewRowAction
        chatTableView.rowHeight = UITableViewAutomaticDimension
        // Do any additional setup after loading the view, typically from a nib.
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
        if messages[indexPath.row].chatType == .mine{
            let sendCell = tableView.dequeueReusableCell(withIdentifier: "SendMessageCell", for: indexPath) as! SendMessageTableViewCell
            sendCell.updateUI(sendMessage: messages[indexPath.row])
            return sendCell
        }else{
            let recieveCell = tableView.dequeueReusableCell(withIdentifier: "RecieveMessageCell", for: indexPath) as! RecieveMessageTableViewCell
            recieveCell.updateUI(recieveMessage: messages[indexPath.row])
            recieveCell.updateUI(recieveMessage: messages[indexPath.row])
            return recieveCell
        }
    }
    
    
}
