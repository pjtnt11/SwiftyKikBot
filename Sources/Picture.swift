import Foundation

public class PictureMessage: Message
{
	public let pictureUrl: String
	public let attribution: JSON
	
	override init(_ message: JSON)
	{
		pictureUrl = message["picUrl"] as! String
		attribution = message["attribution"] as! JSON
		
		super.init(message)
	}
}
