import Foundation
import SwiftyJSON

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
	public var urlAttribution: String? = nil
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
	public let metadata: JSON
	
	public let from: KikUser
	public let readReceiptRequested: Bool!
	public let timestamp: String
	public let participants: [JSON]
	
	public let chatType: ChatType!
	
	/// Creates a message instance with the provided data.
	///
	/// - Parameters:
	///		- messageJSON: A dictionary of JSON data send from Kik containing
	/// the data that is used to create the instace.
	internal init(_ message: JSON)
	{
		type = MessageType(rawValue: message["type"].stringValue)!
		id = message["id"].stringValue
		chatID = message["chatId"].stringValue
		mention = message["mention"].arrayObject as? [String]
		metadata = message["metadata"]
		
		from = KikUser(withUsername: message["from"].stringValue)
		readReceiptRequested = message["readReceiptRequested"].boolValue
		timestamp = message["timestamp"].stringValue
		participants = message["participants"].arrayValue
		
		if let chatType = message["chatType"].string {
			self.chatType = ChatType(rawValue: chatType)
		} else {
			self.chatType = nil
		}
	}
	
	/// Marks the message as read.
	public func markRead() {
		let message: JSON = [
			"messages": [
				[
					"type": MessageType.readRecipt.rawValue,
					"chatId": chatID,
					"to": from.username,
					"messageIds": [id]
				]
			]
		]
		
		guard let sendJSON = try? message.rawData() else {
			print("-- ERROR! --")
			return
		}
		
		dataHandler.send(messages: sendJSON)
	}
	
	public func startTyping() {
		let message: JSON = [
			"messages": [
				[
					"type": MessageType.isTyping.rawValue,
					"chatId": chatID,
					"to": from.username,
					"isTyping": true
				]
			]
		]
		
		guard let sendJSON = try? message.rawData() else {
			print("-- ERROR! --")
			return
		}
		
		dataHandler.send(messages: sendJSON)
	}
	
	public func stopTyping() {
		let message: JSON = [
			"messages" : [
				[
					"type": MessageType.isTyping.rawValue,
					"chatId": chatID,
					"to": from.username,
					"isTyping": false
				]
			]
		]
		
		guard let sendJSON = try? message.rawData() else {
			print("-- ERROR! --")
			return
		}
		
		dataHandler.send(messages: sendJSON)
	}
	
	/// Sends `messages` to the user that sent the original message.
	///
	/// - Parameters:
	///		- messages: Messages to reply with.
	public func reply(withMessages messages: [MessageSendData]) {
		let sendJSON = try? jsonObject(from: messages)
		guard sendJSON != nil else {
			print("-- ERROR! --")
			return
		}
		
		let sendData = try? sendJSON!.rawData()
		guard sendData != nil else {
			print("-- ERROR! --")
			return
		}
		
		dataHandler.send(messages: sendData!)
	}
	
	/// Sends `messages` to the user that sent the original message.
	///
	/// - Parameters:
	///		- messages: Messages to reply with.
	public func reply(withMessages messages: MessageSendData...) {
		reply(withMessages: messages)
	}
	
	/// Sends `messages` to the user that sent the original message.
	///
	/// - Parameters:
	///		- messages: String to reply with.
	public func reply(withString text: String) {
		let message = Message.makeSendData(text: text)
		
		let sendJSON = try? jsonObject(from: [message])
		guard sendJSON != nil else {
			print("-- ERROR! --")
			return
		}
		
		let sendData = try? sendJSON!.rawData()
		guard sendData != nil else {
			print("-- ERROR! --")
			return
		}
		
		dataHandler.send(messages: sendData!)
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
	private func jsonObject(from messages: [MessageSendData]) throws -> JSON
	{
		var messagesJSON: JSON = [
			"messages" : []
		]
		
		for (i, message) in messages.enumerated()
		{
			var messageJSON: JSON = [
				"type": message.type.rawValue,
				"to": from.username,
				"chatId": chatID,
				"delay": message.delay
			]
			
			switch message.type
			{
			case .text:
				guard message.body != nil else {
					throw MessageJSONError.missingParameter("body")
				}
				messageJSON["body"].string = message.body
				messageJSON["typeTime"].int = message.typeTime
				
			case .link:
				guard message.url != nil else {
					throw MessageJSONError.missingParameter("url")
				}
				messageJSON["url"].string = message.url
				messageJSON["title"].string = message.urlTitle
				messageJSON["noForward"].bool = message.isURLForwardable
				messageJSON["kikJsData"].dictionaryObject = message.kikJsData?.dictionaryObject
				messageJSON["attribution"].string = message.urlAttribution
				messageJSON["picUrl"].string = message.urlPictureURL
				
			case .picture:
				guard message.pictureURL != nil else {
					throw MessageJSONError.missingParameter("pictureURL")
				}
				messageJSON["picUrl"].string = message.pictureURL
				messageJSON["attribution"].string = message.pictureAttribution
				
			case .video:
				guard message.videoURL != nil else {
					throw MessageJSONError.missingParameter("videoURL")
				}
				messageJSON["videoUrl"].string = message.videoURL
				messageJSON["loop"].bool = message.loopVideo
				messageJSON["muted"].bool = message.isVideoMuted
				messageJSON["autoplay"].bool = message.autoplayVideo
				messageJSON["noSave"].bool = message.canVideoBeSaved
				messageJSON["attribution"].string = message.videoAttribution
				
			case .isTyping:
				guard message.body != nil else {
					throw MessageJSONError.missingParameter("body")
				}
				messageJSON["isTyping"].bool = message.isTyping
				
			case .readRecipt:
				messageJSON["messageIds"].arrayObject = [id]
				
			default:
				throw MessageJSONError.invalidMessageType(message.type)
			}
			
			messagesJSON["messages"][i].dictionaryObject = messageJSON.dictionary
		}
		
		return messagesJSON
	}
}
