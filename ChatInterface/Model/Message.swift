//
//  Message.swift
//  ChatInterface
//
//  Created by EthanLin on 2018/4/14.
//  Copyright © 2018年 EthanLin. All rights reserved.
//

import Foundation

enum ChatType{
    case mine
    case someone
}

//struct Message {
//    var speaker:String
//    var content:String?
//    var chatType:ChatType
//    var messageImage:String?
//}
struct Message {
    var text:String
    var imageURL:String
    var uid:String
    var timeStamp:Double
    var autoID:String
    
}//struct Message {
//    var speaker:String
//    var content:String?
//    var chatType:String
//    var messageImage:String?
//}

