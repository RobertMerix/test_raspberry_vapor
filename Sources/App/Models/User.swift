//
//  File.swift
//  
//
//  Created by Roberto I. Merizalde on 3/12/21.
//

import Vapor
import Fluent


final class User: Model, Content {
    static let schema: String = "users"
    
    @ID
    var id: UUID?
    
/*
{
    "email": "romer@email.com",
    "password": "123456"
}
 */
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password")
    var password: String
    
//    @Children(for: \.$user)
//    var addresses: [Address]
    
    init() {}
    
    init(id: UUID? = nil, email: String, password: String) {
        self.email = email
        self.password = password
    }
    
    //MARK: -  STEP 2 (A of C) - Hidding the Encrypted Password
/*
     
*/
    final class Public: Content {
      var id: UUID?
      var email: String


      init(id: UUID?, email: String) {
        self.id = id
        self.email = email
      }

    }
     
    
}
// STEP 2 (B of C)
/*
 
 */
extension User {
    func convertToPublic() -> User.Public {
        return User.Public(id: id, email: email)
    }
}

extension EventLoopFuture where Value: User {
  func convertToPublic() -> EventLoopFuture<User.Public> {
    return self.map { user in
      return user.convertToPublic()
    }
  }
}

extension Collection where Element: User {
  func convertToPublic() -> [User.Public] {
    return self.map { $0.convertToPublic() }
  }
}

extension EventLoopFuture where Value == Array<User> {
  func convertToPublic() -> EventLoopFuture<[User.Public]> {
    return self.map { $0.convertToPublic() }
  }
}

//MARK: - STEP 3a (A of D) - HTTP Basic Authentication - GETTING a Token upon login -
//Conform User to 'ModelAuthenticatable'. This is a protocol that allows Fluent Models to use HTTP Basic Authentication
/*

 */
extension User: ModelAuthenticatable {
  static let usernameKey = \User.$email
  static let passwordHashKey = \User.$password
    
  func verify(password: String) throws -> Bool {
    try Bcrypt.verify(password, created: self.password)
  }
}
