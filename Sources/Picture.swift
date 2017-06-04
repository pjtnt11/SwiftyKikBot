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
