//
//  SendMessageTableViewCell.swift
//  ChatInterface
//
//  Created by EthanLin on 2018/4/14.
//  Copyright © 2018年 EthanLin. All rights reserved.
//

import UIKit

class SendMessageTableViewCell: UITableViewCell {
    

    @IBOutlet weak var myAvatar: UIImageView!
    @IBOutlet weak var sendMessageContent: UILabel!
    
    func updateUI(sendMessage:Message){
        self.sendMessageContent.text = sendMessage.content
//        self.myAvatar.image = UIImage(named: "s1")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.sendMessageContent.backgroundColor = UIColor(red: 70/255, green: 137/255, blue: 245/255, alpha: 1)
        self.sendMessageContent.textColor = .white
        self.sendMessageContent.layer.masksToBounds = true
        self.sendMessageContent.layer.cornerRadius = 10
        self.selectionStyle = .none
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
