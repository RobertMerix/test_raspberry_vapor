//
//  File.swift
//  
//
//  Created by Roberto I. Merizalde on 3/12/21.
//

import Fluent

struct CreateToken: Migration {
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    database.schema("tokens")
      .id()
      .field("value", .string, .required)
    // Creates a reference to User for the 'userID' field. Also, The reference is marked with a cascade deletion so that any tokens are automatically deleted when you delete a user.
      .field("userID", .uuid, .required, .references("users", "id", onDelete: .cascade))
      .create()
  }

  func revert(on database: Database) -> EventLoopFuture<Void> {
    database.schema("tokens").delete()
  }
}

