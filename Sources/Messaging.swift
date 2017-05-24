import Foundation

/// An extension to `Dictionary` that adds the abillity to merge two Dictionarys
/// together.
fileprivate extension Dictionary
{
	mutating func merge(with dictionary: Dictionary)
	{
		dictionary.forEach{ updateValue($1, forKey: $0) }
	}
	
	func merged(with dictionary: Dictionary) -> Dictionary
	{
		var dictionary = self
		dictionary.merge(with: dictionary)
		return dictionary
	}
}

/// A enum defining the types of messages that can be sent.
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

/// A dictionary that defines the types of messages that can be sent with a `MessageType`.
internal let messageTypes: [String:MessageType] = [
	"text":.text,
	"link":.link,
	"picture":.picture,
	"video":.video,
	"start-chatting":.startChatting,
	"scanData":.scanData,
	"sticker":.sticker,
	"is-typing":.isTyping,
	"delivery-receipt":.deliveryRecipt,
	"read-receip":.readRecipt,
	"friend-picker":.friendPicker
]

/// A structure that contains the data to be sent as a message.
public struct MessageSendData
{
	let type: MessageType
	
	// Properties for a text message.
	let body: String!
	var typeTime: Int! = nil
	
	// Properties for a link message.
	let url: String!
	var urlTitle: String! = nil
	var urlText: String! = nil
	var isURLForwardable: Bool! = nil
	var kikJsData: JSON! = nil
	var urlAttribution: JSON! = nil
	var urlPictureURL: String! = nil
	
	// Properties for a picture message.
	let pictureURL: String!
	var pictureAttribution: String!
	
	// Properties for a video message.
	let videoURL: String!
	var loopVideo: Bool! = nil
	var isVideoMuted: Bool! = nil
	var autoplayVideo: Bool! = nil
	var canVideoBeSaved: Bool! = nil
	var videoAttribution: String! = nil
	
	// Properties for a is-typing message.
	let isTyping: Bool!
	
	/// Creates a text message.
	init(text: String)
	{
		type = .text
		body = text
		
		url = nil
		pictureURL = nil
		videoURL = nil
		isTyping = nil
	}
	
	init(link: String)
	{
		self.type = .link
		self.url = link
		
		body = nil
		pictureURL = nil
		videoURL = nil
		isTyping = nil
	}
	
	init(pictureURL: String)
	{
		type = .picture
		self.pictureURL = pictureURL
	
		body = nil
		url = nil
		videoURL = nil
		isTyping = nil
	}
	
	init(type: MessageType)
	{
		self.type = type
		
		body = nil
		url = nil
		pictureURL = nil
		videoURL = nil
		isTyping = nil
	}
}

/// A structure that contains the data send by a user to the bot.
///
/// This structure contains all of the information that is sent to the bot.
/// It also contains methods for replying to the message, marking the message as
/// read and other various interactions between the bot and the user.
///
/// -Todo: Add the ability to recieve data from more message types.
public struct Message
{
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
	
	/// Creates a message instance with the provided data.
	///
	/// - Parameters:
	///		- messageJSON: A dictionary of JSON data send from Kik containing 
	/// the data that is used to create the instace.
	init(messageJSON: JSON)
	{
		type = messageTypes[messageJSON["type"] as! String]!
		id = messageJSON["id"] as! String
		chatId = messageJSON["chatId"] as! String
		from = KikUser(withUsername: messageJSON["from"] as! String)
		timestamp = messageJSON["timestamp"] as! Int
		participants = messageJSON["participants"] as! [String]
		
		mention = messageJSON["mention"] as? [String]
		metadata = messageJSON["metadata"] as? JSON
		readReceiptRequested = messageJSON["readReceiptRequested"] as? Bool
		chatType = messageJSON["chatType"] as? String
		
		body = messageJSON["body"] as? String
	}
	
	/// Returns a `MessageSendData` instance from `text`.
	public static func makeSendData(text: String) -> MessageSendData
	{
		return MessageSendData(text: text)
	}
	
	/// Sends `messages` to the user that sent the original message.
	///
	/// - Parameters:
	///		- messages: Messages to reply with.
	///
	/// - Todo: Create a fuction for the setup of the send data.
	public func reply(withMessages messages: MessageSendData...)
	{
		var messagesJSON: MessageJSON = ["messages":[]]
		
		for message in messages
		{
			var messageJSON: JSON = [
				"type": message.type.rawValue,
				"to": from.username,
				"chatId":chatId
			]
			
			switch message.type
			{
			case .text:
				messageJSON["body"] = message.body
				messageJSON["typeTime"] = message.typeTime ?? nil
				
			case .link:
				messageJSON["url"] = message.url
				messageJSON["title"] = message.urlTitle ?? nil
				messageJSON["noForward"] = message.isURLForwardable ?? nil
				messageJSON["kikJsData"] = message.kikJsData ?? nil
				messageJSON["attribution"] = message.urlAttribution ?? nil
				messageJSON["picUrl"] = message.urlPictureURL ?? nil
				
			case .picture:
				messageJSON["picUrl"] = message.pictureURL
				messageJSON["attribution"] = message.pictureAttribution ?? nil
				
			case .video:
				messageJSON["videoUrl"] = message.url
				messageJSON["loop"] = message.urlTitle ?? nil
				messageJSON["muted"] = message.isURLForwardable ?? nil
				messageJSON["autoplay"] = message.kikJsData ?? nil
				messageJSON["noSave"] = message.urlAttribution ?? nil
				messageJSON["attribution"] = message.videoAttribution ?? nil
				
			case .readRecipt:
				messageJSON["messageIds"] = [id]
				
			case .isTyping:
				messageJSON["isTyping"] = message.isTyping
				
				break
			default:
				return
			}
			
			messagesJSON["messages"]!.append(messageJSON as! [String : Any])
		}
		
		dataHandler.send(message: messagesJSON)
	}
	
	/// Marks the message as read.
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
}
