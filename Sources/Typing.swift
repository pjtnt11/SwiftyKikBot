import Foundation

public class TypingMessage: Message
{
	let userIsTyping: Bool
	
	override init(_ message: JSON)
	{
		userIsTyping = message["isTyping"] as! Bool
		
		super.init(message)
	}
}
