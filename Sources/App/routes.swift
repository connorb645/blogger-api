import Vapor

func routes(_ app: Application) throws {
    let api = app.grouped("api")
    try api.register(collection: SessionController())
    try api.register(collection: BlogPostController())
}
