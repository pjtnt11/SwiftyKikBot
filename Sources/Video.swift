import Foundation

public class VideoMessage: Message
{
	let videoUrl: String
	let attribution: String
	
	override init(message: JSON)
	{
		videoUrl = message["videoUrl"] as! String
		attribution = message["attribution"] as! String
		
		super.init(message: message)
	}
}
