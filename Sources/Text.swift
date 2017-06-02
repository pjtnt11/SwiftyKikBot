import Foundation
import SwiftyJSON

public class TextMessage: Message
{
	public let body: String
	
	override init(_ message: JSON)
	{
		self.body = message["body"].stringValue
		super.init(message)
	}
}
