import XCTest
import SwiftyJSON
@testable import KikBot

class MessageSendCreationTest: XCTestCase {
	func testSimpleTextMessage() {
		let sendData = Message.makeSendData(body: "Hi there!")
		let exspectedJSON = JSON(["delay": 0, "typeTime": 0, "type": "text", "body": "Hi there!"])
		XCTAssertEqual(sendData.body, "Hi there!")
		XCTAssertEqual(sendData.typeTime, 0)
		XCTAssertEqual(sendData.delay, 0)
		XCTAssertEqual(sendData.type, .text)
		XCTAssertEqual(sendData.rawJSON, exspectedJSON)
	}
}
