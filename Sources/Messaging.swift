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
	var body: String? = nil
	public var typeTime: Int? = nil
	
	// Properties for a link message.
	var url: String? = nil
	public var urlTitle: String? = nil
	public var urlText: String? = nil
	public var isURLForwardable: Bool? = nil
	public var kikJsData: JSON? = nil
	public var urlAttribution: JSON? = nil
	public var urlPictureURL: String? = nil
	
	// Properties for a picture message.
	var pictureURL: String? = nil
	public var pictureAttribution: String? = nil
	
	// Properties for a video message.
	var videoURL: String? = nil
	public var loopVideo: Bool? = nil
	public var isVideoMuted: Bool? = nil
	public var autoplayVideo: Bool? = nil
	public var canVideoBeSaved: Bool? = nil
	public var videoAttribution: String? = nil
	
	// Properties for a is-typing message.
	var isTyping: Bool? = nil
	
	/// Creates a text message.
	init(text: String) {
		type = .text
		body = text
	}
	
	init(link: String) {
		self.type = .link
		self.url = link
	}
	
	init(pictureURL: String) {
		type = .picture
		self.pictureURL = pictureURL
	}
	
	init(videoURL: String) {
		type = .video
		self.videoURL = videoURL
	}
}

/// A structure that contains the data send by a user to the bot.
///
/// This structure contains all of the information that is sent to the bot.
/// It also contains methods for replying to the message, marking the message as
/// read and other various interactions between the bot and the user.
///
/// - Todo: Add the ability to recieve data from more message types.
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
	public static func makeSendData(text: String) -> MessageSendData {
		return MessageSendData(text: text)
	}
	
	/// Returns a `MessageSendData` instance from `link`.
	public static func makeSendData(link: String) -> MessageSendData {
		return MessageSendData(link: link)
	}
	
	/// Returns a `MessageSendData` instance from `pictureURL`.
	public static func makeSendData(pictureURL: String) -> MessageSendData {
		return MessageSendData(pictureURL: pictureURL)
	}
	
	/// Returns a `MessageSendData` instance from `videoURL`.
	public static func makeSendData(videoURL: String) -> MessageSendData {
		return MessageSendData(videoURL: videoURL)
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
				assert(message.body != nil, "You must provide body test with text messages.")
				messageJSON["body"] = message.body
				messageJSON["typeTime"] = message.typeTime
				
			case .link:
				assert(message.url != nil, "You must provide a url with link messages.")
				messageJSON["url"] = message.url
				messageJSON["title"] = message.urlTitle
				messageJSON["noForward"] = message.isURLForwardable
				messageJSON["kikJsData"] = message.kikJsData
				messageJSON["attribution"] = message.urlAttribution
				messageJSON["picUrl"] = message.urlPictureURL
				
			case .picture:
				assert(message.pictureURL != nil, "You must provide a picture URL with picture messages.")
				messageJSON["picUrl"] = message.pictureURL
				messageJSON["attribution"] = message.pictureAttribution
				
			case .video:
				assert(message.videoURL != nil, "You must provide a video URL with video messages.")
				messageJSON["videoUrl"] = message.url
				messageJSON["loop"] = message.urlTitle
				messageJSON["muted"] = message.isURLForwardable
				messageJSON["autoplay"] = message.kikJsData
				messageJSON["noSave"] = message.urlAttribution
				messageJSON["attribution"] = message.videoAttribution
				
			case .readRecipt:
				messageJSON["messageIds"] = [id]
				
			case .isTyping:
				assert(message.isTyping != nil, "You must specify if `isTyping` with a is typing message.")
				messageJSON["isTyping"] = message.isTyping
				
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
