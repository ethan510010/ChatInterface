//
//  ChatRoom.swift
//  ChatInterface
//
//  Created by EthanLin on 2018/4/17.
//  Copyright © 2018年 EthanLin. All rights reserved.
//

import Foundation

class ChatRoom {
    var chatRoomName:String
    var autoID:String
    init(chatRoomName:String,autoID:String) {
        self.chatRoomName = chatRoomName
        self.autoID = autoID
    }
}
