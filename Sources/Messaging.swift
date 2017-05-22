import Foundation

public typealias MessageJSON = [String:[[String:Any]]]

fileprivate extension Dictionary
{
	
	mutating func merge(with dictionary: Dictionary)
	{
		dictionary.forEach{updateValue($1, forKey: $0)}
	}
	
	func merged(with dictionary: Dictionary) -> Dictionary
	{
		var dictionary = self
		dictionary.merge(with: dictionary)
		return dictionary
	}
}

public enum MessageType: String
{
	case text = "text"
	case link = "link"
	case picture = "picture"
	case video = "video"
	case startChatting = "start-chatting"
	case scanData = "scan-data"
	case sticker = "sticker"
	case isTyping = "is-typing"
	case deliveryRecipt = "delivery-receipt"
	case readRecipt = "read-receipt"
	case friendPicker = "friend-picker"
}

internal let messageTypes: [String:MessageType] = [
	"text":.text, "link":.link, "picture":.picture, "video":.video,
	"start-chatting":.startChatting, "scanData":.scanData,
	"sticker":.sticker, "is-typing":.isTyping,
	"delivery-receipt":.deliveryRecipt, "read-receip":.readRecipt,
	"friend-picker":.friendPicker
]

public struct MessageSendData
{
	let type: MessageType
	var body: String!
	
	init(text: String)
	{
		type = .text
		body = text
	}
	
	init(type: MessageType)
	{
		self.type = type
	}
	
	func addKeyboard()
	{
		
	}
	
	func addingKeyboard() -> MessageSendData
	{
		return self
	}
}

public struct Message
{
	let rawMessageJSON: [String:Any]
	
	let type: MessageType
	let id: String
	let chatId: String
	let mention: [String]!
	let metadata: JSON!
	let from: KikUser
	let readReceiptRequested: Bool!
	let timestamp: Int
	let participants: [String]
	let chatType: String!
	
	let body: String!
	
	let pictureURL: String!
	let pictureAttribution: [String:Any]!
	
	init(messageJSON: [String:Any])
	{
		rawMessageJSON = messageJSON
		
		type = messageTypes[messageJSON["type"] as! String]!
		id = messageJSON["id"] as! String
		chatId = messageJSON["chatId"] as! String
		mention = messageJSON["mention"] as? [String]
		metadata = messageJSON["metadata"] as? JSON
		from = KikUser(username: messageJSON["from"] as! String)
		readReceiptRequested = messageJSON["readReceiptRequested"] as? Bool
		timestamp = messageJSON["timestamp"] as! Int
		participants = messageJSON["participants"] as! [String]
		chatType = messageJSON["chatType"] as? String
		
		body = messageJSON["body"] as? String
		
		pictureURL = messageJSON["picUrl"] as? String
		pictureAttribution = messageJSON["attribution"] as? [String:Any]
	}
	
	static func text(_ text: String) -> MessageSendData
	{
		return MessageSendData(text: text)
	}
	
	static func reading() -> MessageSendData
	{
		return MessageSendData(type: .readRecipt)
	}
	
	func reply(withMessages messages: MessageSendData...)
	{
		for message in messages
		{
			var messageJSON: MessageJSON = [
				"messages": [[
					"type":message.type.rawValue,
					"chatId":chatId,
					"to":from.username,
					]
				]
			]
			
			if message.type == .text {
				messageJSON["messages"]![0]["body"] = message.body
			}
			
			if message.type == .readRecipt {
				messageJSON["messages"]![0]["messageIds"] = [id]
			}
			
			dataHandler.send(message: messageJSON)
			
			print()
		}
	}
	
	func read()
	{
		let message: JSON = [
			"messages": [[
				"type":MessageType.readRecipt.rawValue,
				"chatId":chatId,
				"to":from.username,
				"messageIds": [id]
				]
			]
		]
		
		dataHandler.send(message: message)
	}
}
