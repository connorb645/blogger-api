import Vapor
import Fluent
import FluentPostgresDriver
import Liquid
import LiquidLocalDriver

// configures your application
public func configure(_ app: Application) throws {
    
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    var publicUrl = ""
    
    if let url = Environment.get("DATABASE_URL"), var config = PostgresConfiguration(url: url) {
        config.tlsConfiguration = .makeClientConfiguration()
        config.tlsConfiguration?.certificateVerification = .none
        app.databases.use(.postgres(configuration: config), as: .psql)
        publicUrl = url
    } else {
        let hostname = Environment.get("HN") ?? ""
        let username = Environment.get("DBUN") ?? ""
        let password = Environment.get("DBP") ?? ""
        let database = Environment.get("DB") ?? ""
        app.databases.use(.postgres(hostname: hostname, username: username, password: password, database: database), as: .psql)
        publicUrl = hostname
    }
    
    print(publicUrl)
    
    app.fileStorages.use(.local(publicUrl: publicUrl,
                                publicPath: app.directory.publicDirectory,
                                workDirectory: "assets"), as: .local)

    app.migrations.add(CreateUser())
    app.migrations.add(CreateDocument())
    app.migrations.add(CreateArticle())
    app.migrations.add(CreateToken())
    
    // We can run the autoRevert if we create or edit a CREATION migration
//    try app.autoRevert().wait()
    try app.autoMigrate().wait()

    try routes(app)
}
