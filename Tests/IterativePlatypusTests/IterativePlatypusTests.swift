import IterativePlatypus
import XCTest

import class Foundation.Bundle

final class IterativePlatypusTests: XCTestCase {
    func testEncode() throws {
        let imageURL = Bundle.module.url(forResource: "test", withExtension: "jpeg")!
        try encode(image: imageURL, to: "heic")

        XCTAssert(Bundle.module.url(forResource: "test", withExtension: "heic") != nil)
    }

    /*
      func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.

        // Mac Catalyst won't have `Process`, but it is supported for executables.
        #if !targetEnvironment(macCatalyst)
          let fooBinary = productsDirectory.appendingPathComponent("IterativePlatypus")

          let process = Process()
          process.executableURL = fooBinary

          let pipe = Pipe()
          process.standardOutput = pipe

          try process.run()
          process.waitUntilExit()

          let data = pipe.fileHandleForReading.readDataToEndOfFile()
          let output = String(data: data, encoding: .utf8)

          XCTAssertEqual(output, "Hello, world!\n")
        #endif
      }

     /// Returns path to the built products directory.
     var productsDirectory: URL {
         #if os(macOS)
             for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
                 return bundle.bundleURL.deletingLastPathComponent()
             }
             fatalError("couldn't find the products directory")
         #else
             return Bundle.main.bundleURL
         #endif
     }*/
}
