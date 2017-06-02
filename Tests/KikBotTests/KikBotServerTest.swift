import XCTest
@testable import KikBot
import SwiftyJSON

class KikBotTests: XCTestCase
{
	func testSimpleTextMessageParse()
	{
		let messageJSON = JSON([
			"messages" : [
				[
					"chatId": "b3be3bc15dbe59931666c06290abd944aaa769bb2ecaaf859bfb65678880afab",
					"type": "text",
					"from": "laura",
					"participants": ["laura"],
					"id": "6d8d060c-3ae4-46fc-bb18-6e7ba3182c0f",
					"timestamp": 1399303478832,
					"body": "Hi!",
					"mention": nil,
					"metadata": nil,
					"chatType": "direct"
				]
			]
		])
		
		let textMessage = TextMessage(messageJSON)
		XCTAssertEqual(textMessage.chatID, "b3be3bc15dbe59931666c06290abd944aaa769bb2ecaaf859bfb65678880afab")
		XCTAssertEqual(textMessage.type, .text)
		XCTAssertEqual(textMessage.from.username, "laura")
		XCTAssertEqual(textMessage.id, "6d8d060c-3ae4-46fc-bb18-6e7ba3182c0f")
		XCTAssertEqual(textMessage.timestamp, "1399303478832")
		XCTAssertEqual(textMessage.body, "Hi!")
		XCTAssertEqual(textMessage.mention, nil)
		XCTAssertEqual(textMessage.metadata, nil)
		XCTAssertEqual(textMessage.chatType, .direct)
	}

    static var allTests = [
        ("Test Simple Text Message Parse", testSimpleTextMessageParse),
	]
}
