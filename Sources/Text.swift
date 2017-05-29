import Foundation

public class TextMessage: Message
{
	let body: String
	
	override init(_ message: JSON)
	{
		self.body = message["body"] as! String
		super.init(message)
	}
}
