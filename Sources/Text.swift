import Foundation

public class TextMessage: Message
{
	public let body: String
	
	override init(_ message: JSON)
	{
		self.body = message["body"] as! String
		super.init(message)
	}
}
