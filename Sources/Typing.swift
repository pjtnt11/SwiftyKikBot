import Foundation

public class TypingMessage: Message
{
	let userIsTyping: Bool
	
	override init(message: JSON)
	{
		userIsTyping = message["isTyping"] as! Bool
		
		super.init(message: message)
	}
}
