import Async
import XCTest
import FluentBenchmark
import Dispatch
import FluentMySQL

class FluentMySQLTests: XCTestCase {
    var benchmarker: Benchmarker<MySQLDatabase>!
    
    override func setUp() {
        let database = MySQLDatabase(
            hostname: "localhost",
            user: "root",
            password: nil,
            database: "vapor_test"
        )
        
        benchmarker = Benchmarker(database, onFail: XCTFail)
        
        try! benchmarker.pool.requestConnection().then { conn -> Future<Void> in
            return conn.disableReferences().then { _ -> Future<Void> in
                return conn.connection.administrativeQuery("DROP TABLE IF EXISTS `pet+toy`, `pets`, `toys`, `users`, `foos`")
            }.then { _ -> Future<Void> in
                return conn.enableReferences().map {
                    self.benchmarker.pool.releaseConnection(conn)
                }
            }
        }.blockingAwait(timeout: .seconds(10))
    }
    
    func testSchema() throws {
        try benchmarker.benchmarkSchema().blockingAwait(timeout: .seconds(60))
    }
    
    func testModels() throws {
        try benchmarker.benchmarkModels_withSchema().blockingAwait(timeout: .seconds(60))
    }
    
    func testRelations() throws {
        try benchmarker.benchmarkRelations_withSchema().blockingAwait(timeout: .seconds(60))
    }
    
    func testTimestampable() throws {
        try benchmarker.benchmarkTimestampable_withSchema().blockingAwait(timeout: .seconds(60))
    }
    
    func testTransactions() throws {
        try benchmarker.benchmarkTransactions_withSchema().blockingAwait(timeout: .seconds(60))
    }
    
    func testChunking() throws {
        try benchmarker.benchmarkChunking_withSchema().blockingAwait(timeout: .seconds(60))
    }
    
    static let allTests = [
        ("testSchema", testSchema),
        ("testModels", testModels),
        ("testRelations", testRelations),
        ("testTimestampable", testTimestampable),
        ("testTransactions", testTransactions),
        ("testChunking", testChunking),
    ]
}