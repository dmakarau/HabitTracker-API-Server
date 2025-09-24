import Vapor
import Fluent
import FluentPostgresDriver

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    // TODO: Use environment variables for database configuration in production
    app.databases.use(
        .postgres(
            configuration: SQLPostgresConfiguration(
                hostname: "localhost",
                username: "postgres",
                password: "",
                database: "habitstrackerdb",
                tls: .disable,
            )
        ),
        as: .psql
    )
    
    app.migrations.add(CreateUsersTableMigration())
    
    try app.register(collection: UserController())

    // register routes
    try routes(app)
}
