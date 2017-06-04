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
public class SendMessage
{
	public let type: MessageType
	public var delay: Int = 0 {
		didSet {
			rawJSON["delay"].int = delay
		}
	}
	public internal(set) var rawJSON = JSON([:])
	
	init(type: MessageType) {
		self.type = type
	}
}

fileprivate extension JSON {
	mutating func merge(with mergingJSON: JSON) {
		for (key, value):(String, JSON) in mergingJSON {
			self.dictionaryObject?[key] = value.object
		}
	}
}

/// A class that contains the data send by a user to the bot.
///
/// This structure contains all of the basic information that is sent to the bot.
/// It also contains methods for replying to the message, marking the message as
/// read and other various interactions between the bot and the user. More specific
/// message data is held in this classes subclasses .
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
	
	public func reply(withMessages messages: [SendMessage]) {
		var sendJSON:JSON = JSON(["messages": []])
		for message in messages {
			var messageJSON: JSON = JSON(["chatId": chatID, "to": from.username])
			messageJSON.merge(with: message.rawJSON)
			sendJSON["messages"].arrayObject?.append(messageJSON.object)
		}
		guard let sendData = try? sendJSON.rawData() else {
			print("ERROR")
			return
		}
		
		dataHandler.send(messages: sendData)
	}
	
	/// Returns a `MessageSendData` instance from `text`.
	public static func makeSendData(body: String) -> TextSendMessage {
		return TextSendMessage(body: body)
	}
}
