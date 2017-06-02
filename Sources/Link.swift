import Foundation
import SwiftyJSON

public class LinkMessage: Message
{
	public let url: String
	public let title: String
	public let text: String
	public let forwardable: Bool
	public let kikJsData: JSON?
	public let attribution: JSON
	
	override init(_ message: JSON)
	{
		url = message["url"].stringValue
		title = message["title"].stringValue
		text = message["text"].stringValue
		forwardable = message["noForward"].boolValue
		kikJsData = message["kikJsData"]
		attribution = message["attribution"]
		
		super.init(message)
	}
}
