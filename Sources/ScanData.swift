import Foundation
import SwiftyJSON

public class ScanDataMessage: Message {
	public let data: String

	override init(_ message: JSON) {
		data = message["data"].stringValue
		super.init(message)
	}
}
