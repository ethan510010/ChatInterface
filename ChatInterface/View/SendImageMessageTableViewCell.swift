//
//  SendImageMessageTableViewCell.swift
//  ChatInterface
//
//  Created by EthanLin on 2018/4/16.
//  Copyright © 2018年 EthanLin. All rights reserved.
//

import UIKit

class SendImageMessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var myAvatar: UIImageView!
    @IBOutlet weak var chatBubbleView: UIView!
    @IBOutlet weak var messageImage: UIImageView!
    
    
    func updateUI(imageMessage:Message){
        self.myAvatar.image = UIImage(named: imageMessage.speaker)
        let myMessageImage = UIImage(named: imageMessage.messageImage!)
        self.myAvatar.layer.masksToBounds = true
        self.myAvatar.layer.cornerRadius = self.myAvatar.frame.width / 2

        
        
        let size = CGSize(width: 160, height: (myMessageImage?.size.height)! * 160 / (myMessageImage?.size.width)!)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        myMessageImage?.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let modifiedImage = UIImageJPEGRepresentation(resizeImage!, 0.8) else {return}
        self.messageImage.image = UIImage(data: modifiedImage)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.chatBubbleView.backgroundColor = UIColor(red: 70/255, green: 137/255, blue: 245/255, alpha: 1)
        self.chatBubbleView.layer.masksToBounds = true
        self.chatBubbleView.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
