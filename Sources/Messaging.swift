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

/// A dictionary that defines the types of messages that can be sent with a `MessageType`.
internal let messageTypes: [String:MessageType] = [
	"text" : .text,
	"link" : .link,
	"picture" : .picture,
	"video" : .video,
	"start-chatting" : .startChatting,
	"scanData" : .scanData,
	"sticker" : .sticker,
	"is-typing" : .isTyping,
	"delivery-receipt" : .deliveryRecipt,
	"read-receip" : .readRecipt,
	"friend-picker" : .friendPicker
]

/// An enum that defines the types of chats that a message can come from.
public enum ChatType: String {
	case direct = "direct"
	case `private` = "private"
	case `public` = "public"
}

/// A dictionary that fines the types of chats that a message can come from.
internal let chatTypes: [String:ChatType] = [
	"direct" : .direct,
	"private" : .private,
	"public" : .public,
]

/// A structure tha sets the attribution for links, pictures and video.
public struct Attribution {
	public enum AttributionType: String {
		case gallery
		case camera
		case object
	}
	
	public static let attributionTypes: [String:AttributionType] = [
		"gallery" : .gallery,
		"camera" : .camera
	]
	
	let type: AttributionType
	let name: String?
	let iconURL: String?
}

/// A structure that defines a keyboard.
public struct Keyboard
{
	/// A structure that defines a single keyboard response
	struct KeyboardResponse {
		/// A enum that defines the types of messages that can be sent with keyboards
		enum KeyboardResponseType:String {
			case text = "text"
			case picture = "picture"
			case friendPicker = "friend-picker"
		}
		
		var type: KeyboardResponseType
		var metadata: Any?
		
		var body: String? = nil
		
		var pictureURL: String? = nil
		
		var friendPickerMininum: Int? = nil
		var friendPickerMaximum: Int? = nil
		var preselectedUsers: [KikUser]? = nil
		
		init(text: String, metadata: Any? = nil)
		{
			type = .text
			body = text
			self.metadata = metadata
		}
		
		init(pictureURL: String, metadata: Any)
		{
			type = .picture
			self.pictureURL = pictureURL
			self.metadata = metadata
		}
		
		init(minimumPicked: Int, maximumPicked: Int, preselectedUsers: [KikUser], metadata: Any?)
		{
			type = .friendPicker
			self.friendPickerMininum = minimumPicked
			self.friendPickerMaximum = maximumPicked
		}
	}
	
	var to: [KikUser]?
	public var isHidden: Bool
	let type = "suggested"
	var responses: [KeyboardResponse]
	
	init(responses: KeyboardResponse..., to users: [KikUser]?, isHidden: Bool = false)
	{
		self.to = users
		self.isHidden = isHidden
		self.responses = responses
	}
}

/// A structure that contains the data to be sent as a message.
public struct MessageSendData
{
	let type: MessageType
	let delay: Int
	fileprivate var keyboards: [Keyboard]? = nil
	
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
	init(text: String, delay: Int) {
		type = .text
		body = text
		self.delay = delay
	}
	
	/// Creates a link message.
	init(link: String, delay: Int) {
		self.type = .link
		self.url = link
		self.delay = delay
	}
	
	/// Creates a picture URL message.
	init(pictureURL: String, delay: Int) {
		type = .picture
		self.pictureURL = pictureURL
		self.delay = delay
	}
	
	/// Creates a video URL message.
	init(videoURL: String, delay: Int) {
		type = .video
		self.videoURL = videoURL
		self.delay = delay
	}
	
	/// Sets the keyboards of the message
	public mutating func setKeyboards(_ keyboards: [Keyboard]) {
		self.keyboards = keyboards
	}
	
	/// Returns a message with added keyboards.
	public func settingKeyboards(_ keyboards: [Keyboard]) -> MessageSendData {
		var returningSendData = self
		returningSendData.setKeyboards(keyboards)
		return returningSendData
	}
}

/// A structure that contains the data send by a user to the bot.
///
/// This structure contains all of the information that is sent to the bot.
/// It also contains methods for replying to the message, marking the message as
/// read and other various interactions between the bot and the user.
///
/// - Todo: Add the ability to recieve data from more message types.
public class Message {
	public let type: MessageType
	public let id: String
	public let chatID: String
	public let mention: [String]!
	public let metadata: JSON!
	
	public let from: KikUser
	public let readReceiptRequested: Bool!
	public let timestamp: Int
	public let participants: [String]
	
	public let chatType: ChatType!
	
	public let attribution: Attribution?
	
	public let body: String?
	
	public let url: String?
	public let urlTitle: String?
	public let urlText: String?
	public var urlIsForwardable: Bool?
	public let kikJsData: JSON?
	
	public let pictureURL: String?
	
	public let videoURL: String?
	
	public let scanData: String?
	
	public let stickerPackID: String?
	public let stickerURL: String?
	
	public let userIsTyping: Bool?
	
	public let receiptMessageIds: [String]?
	
	public let pickedUsers: [KikUser]?
	
	/// Creates a message instance with the provided data.
	///
	/// - Parameters:
	///		- messageJSON: A dictionary of JSON data send from Kik containing
	/// the data that is used to create the instace.
	init(messageJSON: JSON)
	{
		type = messageTypes[messageJSON["type"] as! String]!
		id = messageJSON["id"] as! String
		chatID = messageJSON["chatId"] as! String
		mention = messageJSON["mention"] as? [String]
		metadata = messageJSON["metadata"] as? JSON
		
		from = KikUser(withUsername: messageJSON["from"] as! String)
		readReceiptRequested = messageJSON["readReceiptRequested"] as? Bool
		timestamp = messageJSON["timestamp"] as! Int
		participants = messageJSON["participants"] as! [String]
		
		let chatTypeRawValue = messageJSON["chatType"] as? String
		if chatTypeRawValue != nil {
			chatType = chatTypes[chatTypeRawValue!]
		} else {
			chatType = nil
		}
		
		if let attributionObject = messageJSON["attribution"] as? String {
			attribution = Attribution(type: Attribution.attributionTypes[attributionObject]!, name: nil, iconURL: nil)
		} else if let attributionObject = messageJSON["attribution"] as? JSON {
			attribution = Attribution(type: .object, name: attributionObject["name"] as? String, iconURL: attributionObject["iconUrl"] as? String)
		} else {
			attribution = nil
		}
		
		body = messageJSON["body"] as? String
		
		url = messageJSON["url"] as? String
		urlTitle = messageJSON["title"] as? String
		urlText = messageJSON["text"] as? String
		kikJsData = messageJSON["kikJsData"] as? JSON
		urlIsForwardable = (messageJSON["noForward"] as? Bool)
		if urlIsForwardable != nil {
			urlIsForwardable = !urlIsForwardable! // DOUBLE EXCLAMATION MARKS! xD
		}
		
		pictureURL = messageJSON["picUrl"] as? String
		
		videoURL = messageJSON["videoUrl"] as? String
		
		scanData = messageJSON["data"] as? String
		
		stickerPackID = messageJSON["stickerPackId"] as? String
		stickerURL = messageJSON["stickerUrl"] as? String
		
		userIsTyping = messageJSON["isTyping"] as? Bool
		
		receiptMessageIds = messageJSON["messageIds"] as? [String]
		
		if let pickedUsernames = messageJSON["picked"] as? [String] {
			var pickedKikUsers = [KikUser]()
			for pickedUsername in pickedUsernames {
				pickedKikUsers.append(KikUser(withUsername: pickedUsername))
			}
			pickedUsers = pickedKikUsers
		} else {
			pickedUsers = nil
		}
	}
	
	/// Returns a `MessageSendData` instance from `text`.
	public static func makeSendData(text: String, delay: Int = 0) -> MessageSendData {
		return MessageSendData(text: text, delay: delay)
	}
	
	/// Returns a `MessageSendData` instance from `link`.
	public static func makeSendData(link: String, delay: Int = 0) -> MessageSendData {
		return MessageSendData(link: link, delay: delay)
	}
	
	/// Returns a `MessageSendData` instance from `pictureURL`.
	public static func makeSendData(pictureURL: String, delay: Int = 0) -> MessageSendData {
		return MessageSendData(pictureURL: pictureURL, delay: delay)
	}
	
	/// Returns a `MessageSendData` instance from `videoURL`.
	public static func makeSendData(videoURL: String, delay: Int = 0) -> MessageSendData {
		return MessageSendData(videoURL: videoURL, delay: delay)
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
			
			if message.keyboards != nil {
				var keyboardsJSONObject: [JSON] = []
				
				for keyboard in message.keyboards! {
					
					var toUserUsernames: [String]? = [String]()
					if keyboard.to != nil {
						for user in keyboard.to! {
							toUserUsernames!.append(user.username)
						}
					} else {
						toUserUsernames = nil
					}
					
					var keyboardJSONObject: JSON = [
						"type" : keyboard.type,
						"hidden" : keyboard.isHidden
					]
					
					keyboardJSONObject["to"] = toUserUsernames
					
					var responses: [JSON] = []
					
					for response in keyboard.responses {
						var responseJSONObject: JSON = ["type" : response.type.rawValue]
						
						var preselectedUsersUsernames: [String]? = [String]()
						if response.preselectedUsers != nil {
							for user in response.preselectedUsers! {
								preselectedUsersUsernames!.append(user.username)
							}
						} else {
							preselectedUsersUsernames = nil
						}
						
						responseJSONObject["body"] = response.body
						responseJSONObject["picUrl"] = response.pictureURL
						responseJSONObject["min"] = response.friendPickerMininum
						responseJSONObject["max"] = response.friendPickerMaximum
						responseJSONObject["metadata"] = response.metadata
						responseJSONObject["preselected"] = preselectedUsersUsernames
						
						responses.append(responseJSONObject)
					}
					
					keyboardJSONObject["responses"] = responses
					keyboardsJSONObject.append(keyboardJSONObject)
				}
				
				messageJSON["keyboards"] = keyboardsJSONObject
			}
			
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
	
	/// Marks the message as read.
	public func markRead() {
		if readReceiptRequested {
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
	}
}
