import Foundation
import SwiftyJSON

public class TextMessage: Message {
	public let body: String
	
	override init(_ message: JSON) {
		self.body = message["body"].stringValue
		super.init(message)
	}
}

public class TextSendMessage: SendMessage {
	let body: String
	var typeTime = 0
	
	init(body: String) {
		self.body = body
		super.init(type: .text)
		super.rawJSON = JSON([
			"type": MessageType.text.rawValue,
			"delay": super.delay,
			"body": body,
			"typeTime": typeTime
		])
	}
}
