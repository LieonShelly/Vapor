//
//  AuthorController.swift
//  api
//
//  Created by lieon on 2017/8/25.
//
//

import Vapor
import HTTP

final class AuthorController: ResourceRepresentable {
    /// GET ALL
    func index(_ req: Request) throws -> ResponseRepresentable {
        return try Author.all().makeJSON()
    }

    /// POST：创建了一个新的对象
    func create(_ req: Request) throws -> ResponseRepresentable {
        let author = try req.author()
        try author.save()
        return author
    }

    /// GET /{id}
    func show(_ req: Request, author: Author) throws -> ResponseRepresentable {
        return author
    }

    /// DELETE {id}
    func delete(_ req: Request, author: Author) throws -> ResponseRepresentable {
        try author.delete()
        return Response(status: .ok)
    }

    /// DELETE ALL
    func clear(_ req: Request) throws -> ResponseRepresentable {
        try Author.makeQuery().delete()
        return Response(status: .ok)
    }

    /// PATCH： 只执行更新现有数据操作 相当于update
    func update(_ req: Request, author: Author) throws -> ResponseRepresentable {
        try author.update(for: req)
        try author.save()
        return author
    }

    ///  PUT： 替换现有记录的一些属性， 相当于 replace
    func replace(_ req: Request, author: Author) throws -> ResponseRepresentable {
        let new = try req.author()
        author.realName = new.realName
        author.nickName = new.nickName
        author.age = new.age
        try author.save()
        return author
    }

    func makeResource() -> Resource<Author> {
        return Resource(
            index: index,
            store: create,
            show: show,
            update: update,
            replace: replace,
            destroy: delete,
            clear: clear
        )
    }
}

extension Request {
    func author() throws -> Author {
        guard let json = json else { throw Abort.badRequest }
        return try Author(json: json)
    }
}

extension AuthorController: EmptyInitializable { }
