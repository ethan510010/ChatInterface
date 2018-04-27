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
        //        self.myAvatar.image = UIImage(named: imageMessage.speaker)
        
        //        let myMessageImage = UIImage(named: imageMessage.messageImage!)
        
        self.myAvatar.layer.masksToBounds = true
        self.myAvatar.layer.cornerRadius = self.myAvatar.frame.width / 2
        guard let imageURL = URL(string: imageMessage.imageURL) else { return }
        let task = URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
            if error != nil{
                print(error?.localizedDescription)
                return
            }
            guard let imageData = data, let downloadedImage = UIImage(data: imageData) else {return}
            print("送出圖片資料:\(imageData)")
            let adjustedImage = downloadedImage.scale(newWidth: 160)
            
            DispatchQueue.main.async {
                self.messageImage.image = adjustedImage
                
            }
        }
        task.resume()

    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        messageImage.contentMode = .scaleAspectFill
        self.chatBubbleView.backgroundColor = UIColor(red: 70/255, green: 137/255, blue: 245/255, alpha: 1)
        self.chatBubbleView.layer.masksToBounds = true
        self.chatBubbleView.layer.cornerRadius = 5
        self.selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
