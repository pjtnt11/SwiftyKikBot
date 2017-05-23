import Foundation

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
}

public struct Message
{
	public let rawMessageJSON: [String:Any]
	
	public let type: MessageType
	public let id: String
	public let chatId: String
	public let mention: [String]!
	public let metadata: JSON!
	public let from: KikUser
	public let readReceiptRequested: Bool!
	public let timestamp: Int
	public let participants: [String]
	public let chatType: String!
	
	public let body: String!
	
	public let pictureURL: String!
	public let pictureAttribution: [String:Any]!
	
	init(messageJSON: [String:Any])
	{
		rawMessageJSON = messageJSON
		
		type = messageTypes[messageJSON["type"] as! String]!
		id = messageJSON["id"] as! String
		chatId = messageJSON["chatId"] as! String
		mention = messageJSON["mention"] as? [String]
		metadata = messageJSON["metadata"] as? JSON
		from = KikUser(withUsername: messageJSON["from"] as! String)
		readReceiptRequested = messageJSON["readReceiptRequested"] as? Bool
		timestamp = messageJSON["timestamp"] as! Int
		participants = messageJSON["participants"] as! [String]
		chatType = messageJSON["chatType"] as? String
		
		body = messageJSON["body"] as? String
		
		pictureURL = messageJSON["picUrl"] as? String
		pictureAttribution = messageJSON["attribution"] as? [String:Any]
	}
	
	public static func text(_ text: String) -> MessageSendData
	{
		return MessageSendData(text: text)
	}
	
	public static func reading() -> MessageSendData
	{
		return MessageSendData(type: .readRecipt)
	}
	
	public func reply(withMessages messages: MessageSendData...)
	{
		var messageJSON: MessageJSON = ["messages":[[:]]]
		
		for (i, message) in messages.enumerated()
		{
			messageJSON["messages"]![i] = [
				"type": message.type.rawValue,
				"to": from.username
			]
			
			if message.type == .text {
				messageJSON["messages"]![i]["body"] = message.body
			}
			
			if message.type == .readRecipt {
				messageJSON["messages"]![i]["messageIds"] = [id]
			}
			
			dataHandler.send(message: messageJSON)
		}
	}
	
	public func reply(withText texts: String...)
	{
		var messageJSON: MessageJSON = ["messages":[[:]]]
		
		for (i, text) in texts.enumerated()
		{
			messageJSON["messages"]![i] = [
				"type": MessageType.text.rawValue,
				"to": from.username,
				"chatId":chatId
			]
			
			messageJSON["messages"]![i]["body"] = text
			
			dataHandler.send(message: messageJSON)
		}
	}
	
	public func markRead()
	{
		let message: MessageJSON = [
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
	
	public func startTyping()
	{
		let message: MessageJSON = [
			"messages": [[
				"type":MessageType.isTyping.rawValue,
				"chatId":chatId,
				"to":from.username,
				"isTyping":true
				]
			]
		]
		
		dataHandler.send(message: message)
	}
	
	public func stopTyping()
	{
		let message: MessageJSON = [
			"messages": [[
				"type":MessageType.isTyping.rawValue,
				"chatId":chatId,
				"to":from.username,
				"isTyping":false
				]
			]
		]
		
		dataHandler.send(message: message)
	}
}
