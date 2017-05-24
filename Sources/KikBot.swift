import Foundation

public typealias JSON = [AnyHashable:Any]
public typealias MessageJSON = [String:[[String:Any]]]

internal var dataHandler: BotDataHandler!

/// A protocol that defines an instance to recieve Kik messages
public protocol KikBotDelegate
{
	func newMessage(message: Message) -> Void
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
	
	/// Updates the configuration with the configuration JSON.
	///
	/// - Parameters:
	///		- configuration: Configuration dictionary to send.
	///		- callback: Clusure to be called after the data is sent.
	///
	/// - Todo: Call the callback after the post request returns values.
	public func updateConfiguration(configuration: JSON, callback: (() -> Void)?)
    {
		guard let configurationData = try? JSONSerialization.data(withJSONObject: configuration) else
		{
			print("Error: Configuration Data is not valid JSON")
			return
		}
		
        dataHandler!.sendConfigurationUpdate(configuration: configurationData)
		
		if callback != nil
		{
			callback!()
		}
    }
	
	/// Sends one or more messages to the specifyed Kik user.
	///
	/// - Parameters:
	///		- to: `KikUser` to send the messages to.
	///		- messages: Messages to be sent.
	///		- chatId: chatID to send the messages to.
	///
	/// - Note: The chatID is not required, but it makes the sending of messages more efficient.
	public func send(to: KikUser, withMessages messages: MessageSendData..., chatId: String? = nil)
	{
		var messageJSON: MessageJSON = ["messages":[[:]]]
		
		for (i, message) in messages.enumerated()
		{
			messageJSON["messages"]![i] = [
					"type": message.type.rawValue,
					"to": to.username
					]
			
			if chatId != nil {
				messageJSON["messages"]![i]["chatId"] = chatId!
			}
			
			if message.type == .text {
				messageJSON["messages"]![i]["body"] = message.body
			}
		}
		
		dataHandler.send(message: messageJSON)
	}
}
