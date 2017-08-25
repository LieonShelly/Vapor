//
//  Author.swift
//  api
//
//  Created by lieon on 2017/8/25.
//
//

import Vapor
import FluentProvider
import HTTP

final class Author: Model {
    let storage = Storage()
    
    // MARK: Properties and database keys
    
    /// The content of the post
    var realName: String
    var nickName: String
    var age: Int
    
    /// The column names for `id` and `content` in the database
    static let idKey = "id"
    static let realNameKey = "real_name"
    static let nickNameKey = "nick_name"
    static let ageKey = "age"
    
    /// Creates a new Post
    init(realName: String,
         nickName: String,
         age: Int) {
        self.realName = realName
        self.nickName = nickName
        self.age = age
    }
    
    // MARK: Fluent Serialization
    
    /// Initializes the Post from the
    /// database row
    init(row: Row) throws {
        realName = try row.get(Author.realNameKey)
        nickName = try row.get(Author.nickNameKey)
        age = try row.get(Author.ageKey)
    }
    
    // Serializes the Post to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Author.realNameKey, realName)
         try row.set(Author.nickNameKey, nickName)
         try row.set(Author.ageKey, age)
        return row
    }
}

// MARK: Fluent Preparation

extension Author: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Author.realNameKey)
            builder.string(Author.nickNameKey)
            builder.string(Author.ageKey)
        }
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

// How the model converts from / to JSON.
// For example when:
//     - Creating a new Post (POST /posts)
//     - Fetching a post (GET /posts, GET /posts/:id)
//
extension Author: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(realName: json.get(Author.realNameKey),
                      nickName: json.get(Author.nickNameKey),
                      age: json.get(Author.ageKey))
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Author.idKey, id)
        try json.set(Author.realNameKey, realName)
        try json.set(Author.nickNameKey, nickName)
        try json.set(Author.ageKey, age)
        return json
    }
}

// MARK: HTTP

// This allows Post models to be returned
// directly in route closures
extension Author: ResponseRepresentable { }

// MARK: Update

// This allows the Post model to be updated
// dynamically by the request.
extension Author: Updateable {
    // Updateable keys are called when `post.update(for: req)` is called.
    // Add as many updateable keys as you like here.
    public static var updateableKeys: [UpdateableKey<Author>] {
        return [
            // If the request contains a String at key "content"
            // the setter callback will be called.
            UpdateableKey(Author.realNameKey, String.self) { author, realName in
                author.realName = realName
            },
            UpdateableKey(Author.nickNameKey, String.self) { author, nickName in
                author.nickName = nickName
            },
            UpdateableKey(Author.ageKey, Int.self) { author, age in
                author.age = age
            }
        ]
    }
}

