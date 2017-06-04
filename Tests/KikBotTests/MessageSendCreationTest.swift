import XCTest
import SwiftyJSON
@testable import KikBot

class MessageSendCreationTest: XCTestCase {
	func testSimpleTextMessage() {
		let sendData = Message.makeSendData(body: "Hi there!")
		sendData.delay = 1750
		sendData.typeTime = 1000
		
		let exspectedJSON = JSON(["delay": 1750, "typeTime": 1000, "type": "text", "body": "Hi there!"])
		
		XCTAssertEqual(sendData.body, "Hi there!")
		XCTAssertEqual(sendData.typeTime, 1000)
		XCTAssertEqual(sendData.delay, 1750)
		XCTAssertEqual(sendData.type, .text)
		XCTAssertEqual(sendData.rawJSON, exspectedJSON)
	}
}
