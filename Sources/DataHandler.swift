import Foundation
import Kitura

fileprivate let messageURL = URL(string: "https://api.kik.com/v1/message")!
fileprivate let broadcastURL = URL(string: "https://api.kik.com/v1/broadcast")!
fileprivate let kikUserProfileURL = URL(string: "https://api.kik.com/v1/user/")!
fileprivate let configurationURL = URL(string: "https://api.kik.com/v1/config")!
fileprivate let kikCodeURL = URL(string: "https://api.kik.com/v1/code")!

/// A class that handles the connection between Kik and the bot server.
internal class BotDataHandler
{
	let router = Router()
	var port: Int = 80
	var path: String = "/"
	
	private let delegate: KikBotDelegate?
	private let kikSession: URLSession
	private let AuthorizationHeader:String
	private let kikBotSessionConfiguration = URLSessionConfiguration.ephemeral
	
	/// Creates a `BotDataHandler` instance with `username`.
	///
	/// - Parameters:
	///		- username: The username of the bot.
	///		- password: The apiKey of the bot.
	///		- delegate: The delegate that is called when the bot recieves a message.
	///
	/// - Todo: Rename the parameters to be more acurate to their use
	init(username: String, password: String, delegate: KikBotDelegate?) {
		
		self.delegate = delegate
		
		AuthorizationHeader = "Basic \(Data("\(username):\(password)".utf8).base64EncodedString())"
		kikSession = URLSession(configuration: kikBotSessionConfiguration, delegate: nil, delegateQueue: nil)
	}
	
	/// Starts listening for messages sent to the bot.
	///
	/// - Note: This function never returns. It should be the last line of code in your bot.
	func listen() {
		
		router.post(path) { request, response, next in
			
			do {
				let bodyString = try request.readString()
				let bodyData = bodyString?.data(using: .utf8)
				let bodyJSON = try JSONSerialization.jsonObject(with: bodyData!) as! JSON
				let messagesJSON = bodyJSON["messages"] as! [[String:Any]]
				
				for messageJSON in messagesJSON {
					let message = Message(messageJSON: messageJSON)
					self.delegate?.newMessage(message: message)
				}
			} catch {
				print("Error!")
			}
			
			_ = response.send(status: .OK)
			next()
		}
		
		Kitura.addHTTPServer(onPort: port, with: router)
		
		Kitura.run()
	}
	
	/// Sends a configuration object to Kik for your bot.
	func updateConfiguration(with configuration: Data, completionHandeler: ((Error?) -> Void)? = nil) {
		
		var configurationURLRequest = URLRequest(url: configurationURL)
		configurationURLRequest.httpMethod = "POST"
		configurationURLRequest.addValue("application/json", forHTTPHeaderField: "Content-type")
		configurationURLRequest.addValue(AuthorizationHeader, forHTTPHeaderField: "Authorization")
		
		let uploadTask = kikSession.uploadTask(with: configurationURLRequest, from: configuration) { (_, _, error) in
			if error == nil {
				completionHandeler!(error)
			} else {
				print(error!)
			}
		}
		
		uploadTask.resume()
	}
	
	/// Sends a message from the `message` data.
	func send(messages: Data, completionHandeler: ((Error?) -> Void)? = nil) {
		
		var messageURLRequest = URLRequest(url: messageURL)
		messageURLRequest.httpMethod = "POST"
		messageURLRequest.addValue("application/json", forHTTPHeaderField: "Content-type")
		messageURLRequest.addValue(AuthorizationHeader, forHTTPHeaderField: "Authorization")
		
		let uploadTask = kikSession.uploadTask(with: messageURLRequest, from: messages) { (_, _, error) in
			if error != nil && completionHandeler != nil {
				completionHandeler!(error)
			}
		}
		
		uploadTask.resume()
	}
	
	/// Gets the profile for a specific user.
	func getUserProfile(for username: String, completionHandeler: ((JSON?, Error?) -> Void)?) {
		
		var messageURLRequest = URLRequest(url: kikUserProfileURL.appendingPathComponent(username))
		messageURLRequest.httpMethod = "GET"
		messageURLRequest.addValue(AuthorizationHeader, forHTTPHeaderField: "Authorization")
		
		let dataTask = kikSession.dataTask(with: messageURLRequest) { (data, responce, error) in
			
			guard error == nil else {
				if completionHandeler != nil {
					completionHandeler!(nil, error)
				}
				
				return
			}
			
			if data != nil {
				if completionHandeler != nil {
					let profileJSONObject = try? JSONSerialization.jsonObject(with: data!)
					completionHandeler!(profileJSONObject as? JSON, nil)
				}
			}
		}
		
		dataTask.resume()
	}
	
	func createKikCode(withData data: Any?, color: Int, completionHandeler: @escaping ((String?, Error?) -> Void)) {
		
		var messageURLRequest = URLRequest(url: kikCodeURL)
		messageURLRequest.httpMethod = "POST"
		messageURLRequest.addValue("application/json", forHTTPHeaderField: "Content-type")
		messageURLRequest.addValue(AuthorizationHeader, forHTTPHeaderField: "Authorization")
		
		var dataJSONObject: Data?
		
		if data != nil {
			let JOSNData:JSON = ["data":data!]
			
			dataJSONObject = try? JSONSerialization.data(withJSONObject: JOSNData)
		}
		
		let uploadTask = kikSession.uploadTask(with: messageURLRequest, from: dataJSONObject) { (data, responce, error) in
			
			guard error == nil else {
				print(error.debugDescription)
				print(error!.localizedDescription)
				return
			}
			
			if data != nil {
				let responseData = try! JSONSerialization.jsonObject(with: data!) as! [String:String]
				completionHandeler("\(kikCodeURL.appendingPathComponent(responseData["id"]!).absoluteString)?c=\(color)", nil)
			}
		}
		
		uploadTask.resume()
	}
}
