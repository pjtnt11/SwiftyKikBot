import Foundation
import SwiftyJSON

public class PictureMessage: Message
{
	public let pictureUrl: String
	public let attribution: JSON
	
	override init(_ message: JSON)
	{
		pictureUrl = message["picUrl"].stringValue
		attribution = message["attribution"]
		
		super.init(message)
	}
}
