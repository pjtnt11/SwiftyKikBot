import Foundation
import SwiftyJSON

public class DeliveryReceiptMessage: Message {
	public let messageIDs: [String]

	override init(_ message: JSON) {
		messageIDs = message["messageIds"].arrayObject as! [String]
		super.init(message)
	}
}

public class ReadReceiptMessage: Message {
	public let messageIDs: [String]

	override init(_ message: JSON) {
		messageIDs = message["messageIds"].arrayObject as! [String]
		super.init(message)
	}
}
