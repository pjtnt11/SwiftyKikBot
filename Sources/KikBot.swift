import Foundation
import SwiftyJSON

internal var dataHandler: BotDataHandler!

/// A protocol that defines an instance to recieve Kik messages
@objc public protocol KikBotDelegate
{
	@objc optional func newMessage(message: Message, completionhandler: (_ option: MessageOption) -> Void) -> Void
	@objc optional func newTextMessage(message: TextMessage) -> Void
	@objc optional func newLinkMessage(message: LinkMessage) -> Void
	@objc optional func newPictureMessage(message: PictureMessage) -> Void
	@objc optional func newVideoMessage(message: VideoMessage) -> Void
	@objc optional func newStartChattingMessage(message: StartChattingMessage) -> Void
	@objc optional func newScanDataMessage(message: ScanDataMessage) -> Void
	@objc optional func newStickerMessage(message: StickerMessage) -> Void
	@objc optional func newTypingMessage(message: TypingMessage) -> Void
	@objc optional func newDeliveryReceiptMessage(message: DeliveryReceiptMessage) -> Void
	@objc optional func newReadReceiptMessage(message: ReadReceiptMessage) -> Void
}

public extension KikBotDelegate
{
	func newMessage(message: Message, completionhandler: (_ option: MessageOption) -> Void) -> Void
	{
		completionhandler(.continue)
	}
}

/// A class that supports a Kik bot.
public class KikBot
{
	let username: String
	let apiKey: String
	
	///	Creates a KikBot instance for the bot specifyed by `username`.
	///
	/// - Parameters:
	///		- username: The username of the bot
	///		- apiKey: The apiKey of the bot
	///		- delegate: The delegate to be called to handle new messages
	public init(username: String, apiKey: String, delegate: KikBotDelegate?)
	{
		self.username = username
		self.apiKey = apiKey
		
		dataHandler = BotDataHandler(username: username, password: apiKey, delegate: delegate)
	}
	
	/// Starts listening for inbound requests from Kik.
	///
	/// - Parameters:
	///		- port: port that the bot should listen on.
	///		- path: path that the bot should listen on.
	///
	/// - Note: This method never returns. Make sure it is the last line of code.
	public func start(onPort port: Int, path: String)
	{
		dataHandler.port = port
		dataHandler.path = path
		
		dataHandler.listen()
	}
	
	public func createKikCode(with data: JSON, colorNumber: Int, completionHandeler: @escaping (String?, Error?) -> Void)
	{
		dataHandler!.createKikCode(withData: data, color: colorNumber, completionHandeler: completionHandeler)
	}
	
	/// Updates the configuration with the configuration JSON.
	///
	/// - Parameters:
	///		- configuration: Configuration dictionary to send.
	///		- callback: Clusure to be called after the data is sent.
	///
	/// - Todo: Check for errors.
	public func updateConfiguration(configuration: JSON, callback: (() -> Void)?)
	{
		guard let configurationData = try? JSONSerialization.data(withJSONObject: configuration) else {
			print("Error: Configuration Data is not valid JSON")
			return
		}
		
		dataHandler.updateConfiguration(with: configurationData) { (_) in
			if callback != nil {
				callback!()
			}
		}
	}
}
