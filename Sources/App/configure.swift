import Vapor
import Fluent
import FluentPostgresDriver

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    if let url = Environment.get("DATABASE_URL"), var config = PostgresConfiguration(url: url) {
        config.tlsConfiguration = .makeClientConfiguration()
        app.databases.use(.postgres(configuration: config), as: .psql)
    } else {
        let hostname = Environment.get("HN") ?? ""
        let username = Environment.get("DBUN") ?? ""
        let password = Environment.get("DBP") ?? ""
        let database = Environment.get("DB") ?? ""
        app.databases.use(.postgres(hostname: hostname, username: username, password: password, database: database), as: .psql)
    }

    app.migrations.add(CreateUser())
    app.migrations.add(CreateBlogPost())
    app.migrations.add(CreateToken())
    
    // We can run the autoRevert if we create or edit a CREATION migration
//    try app.autoRevert().wait()
    try app.autoMigrate().wait()
//    app.http.server.configuration.hostname = "127.0.0.1"
//    app.http.server.configuration.port = 8090
    // register routes
    try routes(app)
}
