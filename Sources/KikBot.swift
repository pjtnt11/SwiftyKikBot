import Foundation

public typealias JSON = [AnyHashable:Any]
internal var dataHandler: BotDataHandler!

public protocol KikBotDelegate
{
	func newMessage(message: Message) -> Void
}

public class KikBot
{
    let username: String
    let apiKey: String
	
    
	init(username: String, apiKey: String, delegate: KikBotDelegate?)
    {
        self.username = username
        self.apiKey = apiKey
		
		dataHandler = BotDataHandler(username: username, password: apiKey, delegate: delegate)
    }
    
	func start(onPort port: Int, path: String)
    {
        dataHandler!.port = port
		dataHandler!.path = path
		
		dataHandler!.listen()
    }
	
	func updateConfiguration(configuration: JSON, callback: (() -> Void)?)
    {
		let configurationData = try? JSONSerialization.data(withJSONObject: configuration)
		
		guard let data = configurationData else
		{
			print("Error: Configuration Data is not valid JSON")
			return
		}
		
        dataHandler!.sendConfigurationUpdate(configuration: data)
		
		if callback != nil
		{
			callback!()
		}
    }
}

