import Foundation

public typealias JSON = [AnyHashable:Any]
public typealias MessageJSON = [String:[[String:Any]]]

internal var dataHandler: BotDataHandler!

public protocol KikBotDelegate
{
	func newMessage(message: Message) -> Void
}

public class KikBot
{
    let username: String
    let apiKey: String
	
	/// Creates a KikBot instance for the bot specifyed by `username`.
	public init(username: String, apiKey: String, delegate: KikBotDelegate?)
    {
        self.username = username
        self.apiKey = apiKey
		
		dataHandler = BotDataHandler(username: username, password: apiKey, delegate: delegate)
    }
	
	/// Starts listening for inbound requests from Kik.
	public func start(onPort port: Int, path: String)
    {
        dataHandler.port = port
		dataHandler.path = path
		
		dataHandler.listen()
    }
	
	/// Updates the configuration with the configuration JSON.
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
	
	/// Sends one or more messages to the specifyed Kik users.
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
