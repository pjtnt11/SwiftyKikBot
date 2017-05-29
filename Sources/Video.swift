import Foundation

public class VideoMessage: Message
{
	public let videoUrl: String
	public let attribution: String
	
	override init(_ message: JSON)
	{
		videoUrl = message["videoUrl"] as! String
		attribution = message["attribution"] as! String
		
		super.init(message)
	}
}
