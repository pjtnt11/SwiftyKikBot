import XCTest
import SwiftyJSON
@testable import KikBot

class MessageSendCreationTest: XCTestCase {
	func testSimpleTextMessage() {
		let sendData = Message.makeSendData(body: "Hi there!")
		sendData.delay = 1750
		sendData.typeTime = 1000
		
		let exespectedJSON = JSON([
			"type": "text",
			"body": "Hi there!",
			"typeTime": 1000,
			"delay": 1750
			])
		
		XCTAssertEqual(sendData.type, .text)
		XCTAssertEqual(sendData.body, "Hi there!")
		XCTAssertEqual(sendData.typeTime, 1000)
		XCTAssertEqual(sendData.delay, 1750)
		XCTAssertEqual(sendData.rawJSON, exespectedJSON)
	}
	
	func testSimplePictureMessage() {
		let sendData = Message.makeSendData(pictureURL: "http://via.placeholder.com/500x500")
		sendData.delay = 1000
		
		let exespectedJSON = JSON([
			"type": "picture",
			"picUrl": "http://via.placeholder.com/500x500",
			"delay": 1000
			])
		
		XCTAssertEqual(sendData.type, .picture)
		XCTAssertEqual(sendData.pictureURL, "http://via.placeholder.com/500x500")
		XCTAssertEqual(sendData.delay, 1000)
		XCTAssertEqual(sendData.rawJSON, exespectedJSON)
	}
}
