import XCTest
import SwiftyJSON
@testable import KikBot

class MessageRecieveParsingPerformanceTest: XCTestCase
{
	func testSimpleMessageParse()
	{
		let messageJSON = JSON([
			"chatId": "b3be3bc15dbe59931666c06290abd944aaa769bb2ecaaf859bfb65678880afab",
			"type": "text",
			"from": "laura",
			"participants": ["laura"],
			"id": "6d8d060c-3ae4-46fc-bb18-6e7ba3182c0f",
			"timestamp": 1399303478832,
			"mention": nil,
			"metadata": nil,
			"chatType": "direct"
			] as [String:Any?])
		
		self.measure {
			let textMessage = TextMessage(messageJSON)
			XCTAssertEqual(textMessage.chatID, "b3be3bc15dbe59931666c06290abd944aaa769bb2ecaaf859bfb65678880afab")
			XCTAssertEqual(textMessage.type, .text)
			XCTAssertEqual(textMessage.from.username, "laura")
			XCTAssertEqual(textMessage.participants, ["laura"])
			XCTAssertEqual(textMessage.id, "6d8d060c-3ae4-46fc-bb18-6e7ba3182c0f")
			XCTAssertEqual(textMessage.timestamp, "1399303478832")
			XCTAssertNil(textMessage.metadata.dictionary)
			XCTAssertNil(textMessage.mention)
			XCTAssertEqual(textMessage.chatType, .direct)
		}
	}
	
	func testSimpleTextMessageParse()
	{
		let messageJSON = JSON([
			"chatId": "b3be3bc15dbe59931666c06290abd944aaa769bb2ecaaf859bfb65678880afab",
			"type": "text",
			"from": "laura",
			"participants": ["laura"],
			"id": "6d8d060c-3ae4-46fc-bb18-6e7ba3182c0f",
			"timestamp": 1399303478832,
			"body": "Hi!",
			"readReceiptRequested": true,
			"mention": nil,
			"metadata": nil,
			"chatType": "direct"
			] as [String:Any?])
		
		self.measure {
			let textMessage = TextMessage(messageJSON)
			XCTAssertEqual(textMessage.body, "Hi!")
		}
	}
	
	func testSimpleLinkMessageParse()
	{
		let messageJSON = JSON([
			"chatId": "b3be3bc15dbe59931666c06290abd944aaa769bb2ecaaf859bfb65678880afab",
			"type": "link",
			"from": "laura",
			"participants": ["laura"],
			"id": "6d8d060c-3ae4-46fc-bb18-6e7ba3182c0f",
			"timestamp": 83294238952,
			"url": "http://mywebpage.com",
			"attribution": [
				"name": "My App",
				"iconUrl": "http://example.kik.com/anicon.png"
			],
			"noForward": true,
			"readReceiptRequested": true,
			"mention": nil,
			"metadata": nil,
			"chatType": "direct"
			] as [String:Any?])
		
		self.measure {
			let linkMessage = LinkMessage(messageJSON)
			XCTAssertEqual(linkMessage.url, "http://mywebpage.com")
			XCTAssertEqual(linkMessage.attribution["name"].stringValue, "My App")
			XCTAssertEqual(linkMessage.attribution["iconUrl"].stringValue, "http://example.kik.com/anicon.png")
			XCTAssertEqual(linkMessage.forwardable, true)
		}
	}
	
	func testSimplePictureMessageParse()
	{
		let messageJSON = JSON([
			"chatId": "b3be3bc15dbe59931666c06290abd944aaa769bb2ecaaf859bfb65678880afab",
			"type": "picture",
			"from": "laura",
			"participants": ["laura"],
			"id": "6d8d060c-3ae4-46fc-bb18-6e7ba3182c0f",
			"picUrl": "http://example.kik.com/apicture.jpg",
			"timestamp": 1399303478832,
			"readReceiptRequested": true,
			"attribution": [
				"name": "A Title",
				"iconUrl": "http://example.kik.com/anicon.png"
			],
			"mention": nil,
			"metadata": nil,
			"chatType": "direct"
			] as [String:Any?])
		
		self.measure {
			let pictureMessage = PictureMessage(messageJSON)
			XCTAssertEqual(pictureMessage.pictureURL, "http://example.kik.com/apicture.jpg")
			XCTAssertEqual(pictureMessage.attribution["name"].stringValue, "A Title")
			XCTAssertEqual(pictureMessage.attribution["iconUrl"].stringValue, "http://example.kik.com/anicon.png")
		}
	}
}
