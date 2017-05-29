import Foundation

public class StickerMessage: Message
{
	let stickerPackID: String
	let stickerURL: String
	
	override init(message: JSON)
	{
		stickerPackID = message["stickerPackId"] as! String
		stickerURL = message["stickerUrl"] as! String
		
		super.init(message: message)
	}
}
