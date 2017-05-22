import Foundation
import Kitura

internal class BotDataHandler
{
    let router = Router()
    var port: Int = 80
    var path: String = "/"
	let configurationURL = URL(string: "https://api.kik.com/v1/config")!
	let messageURL = URL(string: "https://api.kik.com/v1/message")!
	let KikUserProfileURL = URL(string: "https://api.kik.com/v1/user/")!
	let delegate: KikBotDelegate?
	fileprivate let botDataHandlerDelegate = BotDataHandlerDelegate()
	let kikSession: URLSession?
	let AuthorizationHeader:String?
	
	private let kikBotSessionConfiguration = URLSessionConfiguration.ephemeral
	
	init(username: String, password: String, delegate: KikBotDelegate?)
	{
		self.delegate = delegate
		
		kikBotSessionConfiguration.httpCookieAcceptPolicy = .never
		kikBotSessionConfiguration.httpShouldSetCookies = false
		kikBotSessionConfiguration.httpMaximumConnectionsPerHost = 6
		
		AuthorizationHeader = "Basic \(Data("\(username):\(password)".utf8).base64EncodedString())"
		kikSession = URLSession(configuration: kikBotSessionConfiguration, delegate: botDataHandlerDelegate, delegateQueue: nil)
	}
	
    func listen()
    {
        router.post(path) { request, response, next in
			
			do
			{
				let bodyString = try request.readString()
				let bodyData = bodyString?.data(using: .utf8)
				let bodyJSON = try JSONSerialization.jsonObject(with: bodyData!) as! JSON
				let messagesJSON = bodyJSON["messages"] as! [[String:Any]]
				
				for messageJSON in messagesJSON
				{
					let message = Message(messageJSON: messageJSON)
					self.delegate?.newMessage(message: message)
				}
			}
			catch
			{
				print("Error!")
			}
		
			_ = response.send(status: .OK)
            next()
        }
        
        Kitura.addHTTPServer(onPort: port, with: router)
        
        Kitura.run()
    }
	
	func sendConfigurationUpdate(configuration: Data)
	{
		var configurationURLRequest = URLRequest(url: self.configurationURL)
		configurationURLRequest.httpMethod = "POST"
		configurationURLRequest.addValue("application/json", forHTTPHeaderField: "Content-type")
		configurationURLRequest.addValue(AuthorizationHeader!, forHTTPHeaderField: "Authorization")
		
		let uploadTask = kikSession!.uploadTask(with: configurationURLRequest, from: configuration)
		uploadTask.resume()
	}
	
	func send(message: JSON)
	{
		var messageURLRequest = URLRequest(url: self.messageURL)
		messageURLRequest.httpMethod = "POST"
		messageURLRequest.addValue("application/json", forHTTPHeaderField: "Content-type")
		messageURLRequest.addValue(AuthorizationHeader!, forHTTPHeaderField: "Authorization")
		
		let messageData = try! JSONSerialization.data(withJSONObject: message)
		let uploadTask = kikSession!.uploadTask(with: messageURLRequest, from: messageData)
		uploadTask.resume()
	}
}

private class BotDataHandlerDelegate: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate
{
	var completionHandlers: [URL: (Data) -> Void] = [:]
	
	func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void)
	{
		completionHandler(.allow)
		
		let urlResponse = response as! HTTPURLResponse
		print("\(urlResponse.statusCode): \(HTTPURLResponse.localizedString(forStatusCode: urlResponse.statusCode))")
	}
	
	func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data)
	{
		guard let completionHandler = completionHandlers[dataTask.currentRequest!.url!] else
		{
			return
		}
		
		completionHandler(data)
	}
}
