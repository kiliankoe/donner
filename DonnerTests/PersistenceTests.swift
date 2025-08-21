import Foundation
import GRDB
import SharingGRDB
import Testing

@testable import Donner

@Test
func testPersistentStrikeConversion() throws {
  let strike = Strike(
    id: UUID(),
    lightningTime: Date(),
    lightningLocation: nil
  )

  let persistent = PersistentStrike(from: strike)
  let converted = persistent.toStrike()

  #expect(converted.id == strike.id)
  #expect(converted.lightningTime == strike.lightningTime)
  #expect(converted.lightningLocation == nil)
  #expect(converted.thunderTime == nil)
}

@Test
func testPersistentStrikeRoundTrip() throws {
  var strike = Strike(
    id: UUID(),
    lightningTime: Date(),
    lightningLocation: nil
  )
  strike.thunderTime = Date(timeIntervalSinceNow: 3)
  strike.direction = 45.0

  let persistent = PersistentStrike(from: strike)
  let converted = persistent.toStrike()

  #expect(converted.id == strike.id)
  #expect(converted.lightningTime == strike.lightningTime)
  #expect(converted.thunderTime == strike.thunderTime)
  #expect(converted.direction == strike.direction)
}
