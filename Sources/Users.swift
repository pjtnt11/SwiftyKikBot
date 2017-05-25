import Foundation

/// A structure that keeps the informaation of a specific user.
public struct KikUserProfile
{
	public let firstName: String
	public let lastName: String
	public let profilePictureURL: String?
	public let profilePictureLastModified: Int?
	public let timezone: String?
	
	fileprivate init(userProfileJSON: JSON)
	{
		firstName = userProfileJSON["firstName"] as! String
		lastName = userProfileJSON["lastName"] as! String
		profilePictureURL = userProfileJSON["profilePicUrl"] as? String
		profilePictureLastModified = userProfileJSON["profilePicLastModified"] as? Int
		timezone = userProfileJSON["timezone"] as? String
	}
}

/// A stucture that keeps the information of a KikUser.
public struct KikUser
{
	public let username: String
	
	/// Returns the users profile if it is available.
	public var profile: KikUserProfile? {
		var returningProfile: KikUserProfile?
		fetchUserProile { (profile) in
			returningProfile = profile
		}
		return returningProfile
	}
	
	/// Returns the user's first name if it is available.
	public var addressableName: String {
		if let userProfile = self.profile {
			return userProfile.firstName
		} else {
			return username
		}
	}
	
	/// Creates a `KikUser` from the given username.
	///
	/// - Parameters:
	///		- username: The username of the `KikUser` to create.
	public init(withUsername username: String)
	{
		self.username = username
	}
	
	/// Gets the `KIkUserProfile` for this user.
	///
	/// - Parameters:
	///		- completionHandler: The closure to call after usr profile is fetched.
	private func fetchUserProile(completionHandler: @escaping (KikUserProfile?) -> Void)
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
