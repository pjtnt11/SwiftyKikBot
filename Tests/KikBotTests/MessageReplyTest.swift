//
//  MessageReplyTest.swift
//  KikBot
//
//  Created by Patrick Stephen on Sat 10.
//
//

import XCTest
import SwiftyJSON
@testable import KikBot

class MessageReplyTest: XCTestCase {
	let replyingMessageJSON = JSON([
				"chatId": "b3be3bc15dbe59931666c06290abd944aaa769bb2ecaaf859bfb65678880afab",
				"type": "text",
				"participants": ["laura"],
				"id": "6d8d060c-3ae4-46fc-bb18-6e7ba3182c0f",
				"timestamp": 1399303478832,
				"body": "Hi!",
				"mention": nil,
				"metadata": nil,
				"chatType": "direct"
	] as [String:Any?])
	
	var replyingMessage: Message? = nil
	let sendMessage = Message.makeSendData(body: "Hi there!")
	
	override func setUp() {
		replyingMessage = TextMessage(replyingMessageJSON)
	}
}
