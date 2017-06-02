import Foundation
import SwiftyJSON

public class TypingMessage: Message
{
	public let userIsTyping: Bool
	
	override init(_ message: JSON)
	{
		userIsTyping = message["isTyping"].boolValue
		
		super.init(message)
	}
}
