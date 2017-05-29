import Foundation

public class ScanDataMessage: Message
{
	let data: String
	
	override init(_ message: JSON)
	{
		data = message["data"] as! String
		
		super.init(message)
	}
}
