import XCTest
@testable import HabitMonCore

final class ChecklistSourceItemTests: XCTestCase {
    func testDecodesTaggedDoneItem() throws {
        let json = """
        {"id":"E7D4000F-821C-454B-A298-54DA320729ED","text":"run 2 miles","isDone":true,"createdAt":"2026-08-06T19:17:23Z","type":"fire"}
        """.data(using: .utf8)!
        let item = try JSONDecoder().decode(ChecklistSourceItem.self, from: json)
        XCTAssertEqual(item.id, UUID(uuidString: "E7D4000F-821C-454B-A298-54DA320729ED"))
        XCTAssertEqual(item.isDone, true)
        XCTAssertEqual(item.type, .fire)
    }

    func testDecodesUntaggedItemAsNilType() throws {
        let json = """
        {"id":"120713C8-2EDE-409A-B8B1-46BA38A25014","text":"research","isDone":false,"createdAt":"2026-08-06T19:17:23Z"}
        """.data(using: .utf8)!
        let item = try JSONDecoder().decode(ChecklistSourceItem.self, from: json)
        XCTAssertNil(item.type)
    }

    func testUnrecognizedTypeValueDecodesAsNilInsteadOfThrowing() throws {
        let json = """
        {"id":"120713C8-2EDE-409A-B8B1-46BA38A25014","text":"something new","isDone":true,"createdAt":"2026-08-06T19:17:23Z","type":"earth"}
        """.data(using: .utf8)!
        let item = try JSONDecoder().decode(ChecklistSourceItem.self, from: json)
        XCTAssertNil(item.type, "Unrecognized type should decode as untagged, not throw")
    }

    func testIgnoresExtraFieldsLikeTextAndCreatedAt() throws {
        let json = """
        {"id":"120713C8-2EDE-409A-B8B1-46BA38A25014","text":"anything","isDone":false,"createdAt":"2026-08-06T19:17:23Z","someNewField":123}
        """.data(using: .utf8)!
        XCTAssertNoThrow(try JSONDecoder().decode(ChecklistSourceItem.self, from: json))
    }

    func testDecodesFullFileWithMultipleItems() throws {
        let json = """
        {"items":[
            {"id":"E7D4000F-821C-454B-A298-54DA320729ED","text":"a","isDone":true,"createdAt":"2026-08-06T19:17:23Z","type":"fire"},
            {"id":"120713C8-2EDE-409A-B8B1-46BA38A25014","text":"b","isDone":false,"createdAt":"2026-08-06T19:17:23Z"}
        ],"lastSeenDate":"2026-08-06T04:07:18Z"}
        """.data(using: .utf8)!
        let file = try JSONDecoder().decode(ChecklistSourceFile.self, from: json)
        XCTAssertEqual(file.items.count, 2)
    }
}
