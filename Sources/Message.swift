import Foundation

/// An error that is called when there are problems
public enum MessageJSONError: Error {
	case invalidMessageType(MessageType)
	case missingParameter(String)
}

/// An enum defining the types of messages that can be sent.
public enum MessageType: String {
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

/// An enum that defines the types of chats that a message can come from.
public enum ChatType: String {
	case direct = "direct"
	case `private` = "private"
	case `public` = "public"
}

/// A structure that contains the data to be sent as a message.
public struct MessageSendData
{
	let type: MessageType
	fileprivate var delay: Int = 0
	
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
	
	/// Creates a link message.
	init(link: String) {
		self.type = .link
		self.url = link
	}
	
	/// Creates a picture URL message.
	init(pictureURL: String) {
		type = .picture
		self.pictureURL = pictureURL
	}
	
	/// Creates a video URL message.
	init(videoURL: String) {
		type = .video
		self.videoURL = videoURL
	}
	
	public mutating func delay(_ delay: Int) {
		self.delay = delay
	}
	
	public func delayed(_ delay: Int) -> MessageSendData {
		var newMessage = self
		newMessage.delay(delay)
		return newMessage
	}
}

/// A class that contains the data send by a user to the bot.
///
/// This structure contains all of the information that is sent to the bot.
/// It also contains methods for replying to the message, marking the message as
/// read and other various interactions between the bot and the user.
@objc public class Message: NSObject {
	public let type: MessageType
	public let id: String
	public let chatID: String
	public let mention: [String]?
	public let metadata: JSON?
	
	public let from: KikUser
	public let readReceiptRequested: Bool!
	public let timestamp: Int
	public let participants: [String]
	
	public let chatType: ChatType!
	
	/// Creates a message instance with the provided data.
	///
	/// - Parameters:
	///		- messageJSON: A dictionary of JSON data send from Kik containing
	/// the data that is used to create the instace.
	init(_ message: JSON)
	{
		type = MessageType(rawValue: message["type"] as! String)!
		id = message["id"] as! String
		chatID = message["chatId"] as! String
		mention = message["mention"] as? [String]
		metadata = message["metadata"] as? JSON
		
		from = KikUser(withUsername: message["from"] as! String)
		readReceiptRequested = message["readReceiptRequested"] as? Bool
		timestamp = message["timestamp"] as! Int
		participants = message["participants"] as! [String]
		
		if let chatType = message["chatType"] as? String {
			self.chatType = ChatType(rawValue: chatType)
		} else {
			self.chatType = nil
		}
	}
	
	/// Marks the message as read.
	public func markRead() {
		let message: MessageJSONDictionary = [
			"messages": [[
				"type":MessageType.readRecipt.rawValue,
				"chatId":chatID,
				"to":from.username,
				"messageIds": [id]
				]
			]
		]
		
		let messageJSONObject = try! JSONSerialization.data(withJSONObject: message)
		dataHandler.send(messages: messageJSONObject)
	}
	
	public func startTyping() {
		let message: MessageJSONDictionary = [
			"messages": [[
				"type":MessageType.isTyping.rawValue,
				"chatId":chatID,
				"to":from.username,
				"isTyping": true
				]
			]
		]
		
		let messageJSONObject = try! JSONSerialization.data(withJSONObject: message)
		dataHandler.send(messages: messageJSONObject)
	}
	
	public func stopTyping() {
		let message: MessageJSONDictionary = [
			"messages": [[
				"type":MessageType.isTyping.rawValue,
				"chatId":chatID,
				"to":from.username,
				"isTyping": false
				]
			]
		]
		
		let messageJSONObject = try! JSONSerialization.data(withJSONObject: message)
		dataHandler.send(messages: messageJSONObject)
	}
	
	/// Sends `messages` to the user that sent the original message.
	///
	/// - Parameters:
	///		- messages: Messages to reply with.
	///
	/// - Todo: Add error handling.
	public func reply(withMessages messages: MessageSendData...)
	{
		let messagesJSONObject = try! jsonObject(from: messages)
		let messagesData = try! JSONSerialization.data(withJSONObject: messagesJSONObject)
		dataHandler.send(messages: messagesData)
	}
	
	/// Sends `messages` to the user that sent the original message.
	///
	/// - Parameters:
	///		- messages: String to reply with.
	///
	/// - Todo: Add error handling.
	public func reply(withString text: String)
	{
		let message = Message.makeSendData(text: text)
		let messagesJSONObject = try! jsonObject(from: [message])
		let messagesData = try! JSONSerialization.data(withJSONObject: messagesJSONObject)
		dataHandler.send(messages: messagesData)
	}
	
	// The rest of the methods in this class have to do with sending data.
	
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
	
	/// Returns a dictionary formatted to send to Kik.
	///
	/// - Parameters:
	///		- messages: An array for `MessageSendData` to be converted into a JSON object.
	private func jsonObject(from messages: [MessageSendData]) throws -> MessageJSONDictionary
	{
		var messagesJSON: MessageJSONDictionary = ["messages":[]]
		
		for message in messages
		{
			var messageJSON: JSON = [
				"type": message.type.rawValue,
				"to": from.username,
				"chatId":chatID,
				"delay":message.delay
			]
			
			switch message.type
			{
			case .text:
				guard message.body != nil else {
					throw MessageJSONError.missingParameter("body")
				}
				messageJSON["body"] = message.body
				messageJSON["typeTime"] = message.typeTime
				
			case .link:
				guard message.url != nil else {
					throw MessageJSONError.missingParameter("url")
				}
				messageJSON["url"] = message.url
				messageJSON["title"] = message.urlTitle
				messageJSON["noForward"] = message.isURLForwardable
				messageJSON["kikJsData"] = message.kikJsData
				messageJSON["attribution"] = message.urlAttribution
				messageJSON["picUrl"] = message.urlPictureURL
				
			case .picture:
				guard message.pictureURL != nil else {
					throw MessageJSONError.missingParameter("pictureURL")
				}
				messageJSON["picUrl"] = message.pictureURL
				messageJSON["attribution"] = message.pictureAttribution
				
			case .video:
				guard message.videoURL != nil else {
					throw MessageJSONError.missingParameter("videoURL")
				}
				messageJSON["videoUrl"] = message.videoURL
				messageJSON["loop"] = message.loopVideo
				messageJSON["muted"] = message.isVideoMuted
				messageJSON["autoplay"] = message.autoplayVideo
				messageJSON["noSave"] = message.canVideoBeSaved
				messageJSON["attribution"] = message.videoAttribution
				
			case .isTyping:
				guard message.body != nil else {
					throw MessageJSONError.missingParameter("body")
				}
				messageJSON["isTyping"] = message.isTyping
				
			case .readRecipt:
				messageJSON["messageIds"] = [id]
				
			default:
				throw MessageJSONError.invalidMessageType(message.type)
			}
			
			messagesJSON["messages"]!.append(messageJSON)
		}
		
		return messagesJSON
	}
}
