import Foundation

public class LinkMessage: Message
{
	let url: String
	let title: String
	let text: String
	let forwardable: Bool
	let kikJsData: JSON?
	let attribution: String
	
	override init(message: JSON)
	{
		url = message["url"] as! String
		title = message["title"] as! String
		text = message["text"] as! String
		forwardable = !(message["noForward"] as! Bool)
		kikJsData = message["kikJsData"] as? JSON
		attribution = message["attribution"] as! String
		
		super.init(message: message)
	}
}
