import Foundation
import GRDB
import SharingGRDB

extension DatabaseQueue {
  static func makeDefault() throws -> DatabaseQueue {
    let fileManager = FileManager.default
    let appSupport = try fileManager.url(
      for: .applicationSupportDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: true
    )
    let dbPath = appSupport.appendingPathComponent("donner.sqlite")

    let db = try DatabaseQueue(path: dbPath.path)
    try migrator.migrate(db)
    return db
  }

  private static var migrator: DatabaseMigrator {
    var migrator = DatabaseMigrator()

    migrator.registerMigration("v1") { db in
      try db.create(table: "persistentStrike") { t in
        t.primaryKey("id", .text)
        t.column("lightningTime", .double).notNull()
        t.column("lightningLocationLatitude", .double)
        t.column("lightningLocationLongitude", .double)
        t.column("thunderTime", .double)
        t.column("direction", .double)
        t.column("userLocationLatitude", .double)
        t.column("userLocationLongitude", .double)
      }
    }

    return migrator
  }
}
