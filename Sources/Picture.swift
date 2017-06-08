import Foundation
import SwiftyJSON

public class PictureMessage: Message {
	public let pictureURL: String
	public let attribution: JSON

	override init(_ message: JSON) {
		pictureURL = message["picUrl"].stringValue
		attribution = message["attribution"]

		super.init(message)
	}
}

public class PictureSendMessage: SendMessage {
	public let pictureURL: String
	
	init(pictureURL: String) {
		self.pictureURL = pictureURL
		super.init(type: .picture)
		super.rawJSON = JSON([
			"type": MessageType.picture.rawValue,
			"delay": super.delay,
			"picUrl": self.pictureURL,
		])
	}
}
