import Foundation

public struct KikUserProfile
{
	let firstName: String
	let lastName: String
	let profilePictureURL: String?
	let profilePictureLastModified: Int?
	let timezone: String?
	
	fileprivate init(userProfileJSON: JSON)
	{
		firstName = userProfileJSON["firstName"] as! String
		lastName = userProfileJSON["lastName"] as! String
		profilePictureURL = userProfileJSON["profilePicUrl"] as? String
		profilePictureLastModified = userProfileJSON["profilePicLastModified"] as? Int
		timezone = userProfileJSON["timezone"] as? String
	}
}

public struct KikUser
{
	public let username: String
	
	public init(withUsername username: String)
	{
		self.username = username
	}
	
	public func fetchUserProile(completionHandler: @escaping (KikUserProfile?) -> Void)
	{
		dataHandler.getUserProfile(username: username) { (json, error) in
			guard error == nil else {
				completionHandler(nil)
				return
			}
			
			if json != nil {
				completionHandler(KikUserProfile(userProfileJSON: json!))
			}
		}
	}
}
