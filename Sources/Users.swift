import Foundation

public struct KikUserProfile
{
	let firstName: String
	let lastName: String!
	let profilePicURL: String!
}

public struct KikUser
{
	public let username: String
	
	public init(withUsername username: String)
	{
		self.username = username
	}
	
	public func fetchUserProile(completionHandler: (KikUserProfile?) -> Void)
	{
		completionHandler(nil)
	}
}
