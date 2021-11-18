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
    print(app.baseUrl)
    
    
    app.fileStorages.use(.local(publicUrl: app.baseUrl,
                                publicPath: app.directory.publicDirectory,
                                workDirectory: "assets"), as: .local)

    app.migrations.add(CreateUser())
    app.migrations.add(CreateArticle())
    app.migrations.add(CreateToken())
    
    // We can run the autoRevert if we create or edit a CREATION migration
//    try app.autoRevert().wait()
    try app.autoMigrate().wait()

    try routes(app)
}

extension Application {
    #warning("Untested when running from Heroku environments")
    var baseUrl: String {
        let configuration = http.server.configuration
        let scheme = configuration.tlsConfiguration == nil ? "http" : "https"
        let host = configuration.hostname
        let port = configuration.port
        return "\(scheme)://\(host):\(port)"
    }
}
