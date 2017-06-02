import Foundation
import SwiftyJSON

public class StickerMessage: Message
{
	public let stickerPackID: String
	public let stickerURL: String
	
	override init(_ message: JSON)
	{
		stickerPackID = message["stickerPackId"].stringValue
		stickerURL = message["stickerUrl"].stringValue
		
		super.init(message)
	}
}
