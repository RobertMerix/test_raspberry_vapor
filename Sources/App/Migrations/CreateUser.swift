//
//  File.swift
//  
//
//  Created by Roberto I. Merizalde on 3/12/21.
//

import Fluent

struct CreateUser: Migration {
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    database.schema("users")
      .id()
      .field("email", .string, .required).unique(on: "email")
      .field("password", .string, .required)
        /* STEP 1 (B of B) - Making email unique, if a the same email is used to create a new account, this vapor app won't allow it because it will recognize it as duplicate.
         You’ll be using the email and password to uniquely identify users
         
         NOTE: reset the DB by creating a new one since Migrations will need to run agains.
         */
      .create()
  }
  
  func revert(on database: Database) -> EventLoopFuture<Void> {
    database.schema("users").delete()
  }
}
