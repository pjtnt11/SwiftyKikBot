import Foundation
import SwiftyJSON

public class VideoMessage: Message
{
	public let videoUrl: String
	public let attribution: String
	
	override init(_ message: JSON)
	{
		videoUrl = message["videoUrl"].stringValue
		attribution = message["attribution"].stringValue
		
		super.init(message)
	}
}
