import Vapor

func routes(_ app: Application) throws {
    let api = app.grouped("api")
    try api.register(collection: SessionController())
    try api.register(collection: ArticleController())
    try api.register(collection: DocumentController())
    try api.register(collection: UserController())
}
