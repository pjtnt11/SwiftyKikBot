import Foundation

public class StickerMessage: Message
{
	public let stickerPackID: String
	public let stickerURL: String
	
	override init(_ message: JSON)
	{
		stickerPackID = message["stickerPackId"] as! String
		stickerURL = message["stickerUrl"] as! String
		
		super.init(message)
	}
}
