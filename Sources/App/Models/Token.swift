//
//  File.swift
//  
//
//  Created by Roberto I. Merizalde on 3/12/21.
//

import Vapor
import Fluent

/* STEP 3a (B of D) - Exchange user's login credentials for a token the client can save.
 At this stage, only authenticated users can create acronyms. However, Asking a user to enter their login credentials with each request is impractical. You also don’t want to store a user’s password anywhere in your application since you’d have to store it in plain text. Instead, you’ll allow users to log in to your API once. When they log in, you exchange their credentials for a token the client can save.
 */

final class Token: Model, Content {
  static let schema = "tokens"

  @ID
  var id: UUID?

  @Field(key: "value")
  var value: String

  @Parent(key: "userID")
  var user: User

  init() {}

  init(id: UUID? = nil, value: String, userID: User.IDValue) {
    self.id = id
    self.value = value
    self.$user.id = userID
  }
}

// generating a token
extension Token {
  static func generate(for user: User) throws -> Token {
    let random = [UInt8].random(count: 16).base64
    return try Token(value: random, userID: user.requireID())
  }
}

//MARK: - STEP 3b - HTTP Basic Authentication - USING a Token upon login -
/*

 */
// Conform 'Token' to Vapor’s ModelTokenAuthenticatable protocol. This allows you to use the token with HTTP Bearer authentication.
/*
 */
extension Token: ModelTokenAuthenticatable {
    //let vapor know the key path
  static let valueKey = \Token.$value
    static let userKey = \Token.$user
    // tell Vapor what type the 'user' is
  typealias User = App.User
    //FIXME: - GREAT IDEA FOR SUBSCRIPTIONS OPTIONS: Determine if the token is valid (which returns 'true' for now,) but you might add an expiry date or a revoked property to check in the future.
  var isValid: Bool {
    true
  }
}

