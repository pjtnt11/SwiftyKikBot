import Foundation

public class PictureMessage: Message
{
	public let pictureUrl: String
	public let attribution: String
	
	override init(_ message: JSON)
	{
		pictureUrl = message["picUrl"] as! String
		attribution = message["attribution"] as! String
		
		super.init(message)
	}
}
