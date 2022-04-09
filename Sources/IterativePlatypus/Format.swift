import CMagickWand
import Foundation
import Logging
import Photos

// Some useful links
// https://github.com/apple/swift/blob/main/docs/HowSwiftImportsCAPIs.md
// https://developer.apple.com/documentation/swift/imported_c_and_objective-c_apis/using_imported_c_functions_in_swift

/// See https://imagemagick.org/script/exception.php for error codes
struct CMagickWandException: Error {
    var code: UInt32
    var description: String?

    init(_ wand: OpaquePointer) {
        var exceptionType = MagickGetExceptionType(wand)
        let description = MagickGetException(wand, &exceptionType)

        code = exceptionType.rawValue
        self.description = description != nil ? String(cString: description!) : nil
    }
}

public func encode(image: URL, to: String) throws {
    let logger = Logger(label: "com.iterativeplatypus.encode")

    MagickWandGenesis()
    let wand = NewMagickWand()!
    defer {
        DestroyMagickWand(wand)
        MagickWandTerminus()
    }

    var status = MagickReadImage(wand, image.relativePath)
    guard status != MagickFalse else {
        logger.error("Read Image failed")
        throw CMagickWandException(wand)
    }

    status = MagickSetCompressionQuality(wand, 100)
    guard status != MagickFalse else {
        logger.error("Set compression failed")
        throw CMagickWandException(wand)
    }

    let path = image.deletingPathExtension().appendingPathExtension(to)
    status = MagickWriteImage(wand, path.relativePath)
    guard status != MagickFalse else {
        logger.error("Write image failed")
        throw CMagickWandException(wand)
    }
}
