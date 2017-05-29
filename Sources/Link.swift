import Foundation

public class LinkMessage: Message
{
	public let url: String
	public let title: String
	public let text: String
	public let forwardable: Bool
	public let kikJsData: JSON?
	public let attribution: String
	
	override init(_ message: JSON)
	{
		url = message["url"] as! String
		title = message["title"] as! String
		text = message["text"] as! String
		forwardable = !(message["noForward"] as! Bool)
		kikJsData = message["kikJsData"] as? JSON
		attribution = message["attribution"] as! String
		
		super.init(message)
	}
}
