import Foundation

public class PictureMessage: Message
{
	let pictureUrl: String
	let attribution: String
	
	override init(message: JSON)
	{
		pictureUrl = message["picUrl"] as! String
		attribution = message["attribution"] as! String
		
		super.init(message: message)
	}
}
