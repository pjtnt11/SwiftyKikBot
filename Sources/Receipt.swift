import Foundation

public class DeliveryReceiptMessage: Message
{
	let messageIDs: [String]
	
	override init(_ message: JSON)
	{
		messageIDs = message["messageIds"] as! [String]
		
		super.init(message)
	}
}

public class ReadReceiptMessage: Message
{
	let messageIDs: [String]
	
	override init(_ message: JSON)
	{
		messageIDs = message["messageIds"] as! [String]
		
		super.init(message)
	}
}
