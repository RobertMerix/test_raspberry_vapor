//
//  File.swift
//  
//
//  Created by Roberto I. Merizalde on 3/12/21.
//

import Vapor

struct UsersController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let usersRoute = routes.grouped("api", "users")
    usersRoute.get(use: getAllHandler)
    usersRoute.post(use: createHandler)
//    usersRoute.get(":userID", use: getHandler)
//    usersRoute.get(":userID", "acronyms", use: getAcronymsHandler)
    /*
     usersRoute.get(use: getAllHandler)

     let tokenAuthMiddleware = Token.authenticator()
     let guardAuthMiddleware = User.guardMiddleware()
     let tokenAuthGroup = usersRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
     tokenAuthGroup.post(use: createHandler)
     */
    
    // STEP 3a (D of D) - Create a protected route group using HTTP basic authentication.
    let basicAuthMiddleware = User.authenticator()
    let basicAuthGroup = usersRoute.grouped(basicAuthMiddleware)
    basicAuthGroup.post("login", use: loginHandler)
    
  }

    //MARK: - STEP 1 (A - B): Encrypting the password and making the email unique.
    
    /* old 'createHandler()'
     func createHandler(_ req: Request) throws -> EventLoopFuture<User> {
       let user = try req.content.decode(User.self)
       return user.save(on: req.db).map { user }
     }
     func getAllHandler(_ req: Request) -> EventLoopFuture<[User]> {
         User.query(on: req.db).all()
     }
     */

    
    // step1 version of 'createHandler()'
    /*
     func createHandler(_ req: Request) throws -> EventLoopFuture<User> {
       let user = try req.content.decode(User.self)
       // A - Encrypting the password.
       user.password = try Bcrypt.hash(user.password)
       // B - Hiding the password by passing and instance of 'User'
       return user.save(on: req.db).map { user }
     }
     */


    // STEP 2 (C of C) - This uses the new method to convert a User to User.Public - Create a new user and you'll notice the encrypted password is now hiddem.
    // step2 version of 'createHandler()'
    /*
     
     */
    func createHandler(_ req: Request) throws -> EventLoopFuture<User.Public> {
      let user = try req.content.decode(User.self)
      // A - Encrypting the password.
      user.password = try Bcrypt.hash(user.password)
      // B - Hiding the password by passing and instance of 'User'
        return user.save(on: req.db).map { user.convertToPublic() }
    }
    
    
    
    func getAllHandler(_ req: Request) -> EventLoopFuture<[User.Public]> {
        User.query(on: req.db).all().convertToPublic()
    }
    
    
    
    /*

     func getHandler(_ req: Request) -> EventLoopFuture<User.Public> {
       User.find(req.parameters.get("userID"), on: req.db).unwrap(or: Abort(.notFound)).convertToPublic()
     }
     
   //  func getAcronymsHandler(_ req: Request) -> EventLoopFuture<[Acronym]> {
   //    User.find(req.parameters.get("userID"), on: req.db).unwrap(or: Abort(.notFound)).flatMap { user in
   //      user.$acronyms.get(on: req.db)
   //    }
   //  }

     */
    
    // STEP 3a (C of D) -
    func loginHandler(_ req: Request) throws -> EventLoopFuture<Token> {
    //verifing user and user's password. see how this is done on step3 (A of )
      let user = try req.auth.require(User.self)
    // spits out a token which can then be used by the client.
      let token = try Token.generate(for: user)
    // save the token on the DB and give the token to the client for reference.
      return token.save(on: req.db).map { token }
    }
}

