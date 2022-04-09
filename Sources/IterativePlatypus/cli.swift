import ArgumentParser
import Logging
import Photos

@main
struct PhotoTransformer: AsyncParsableCommand {
    @Argument(help: "Number of images to process at once")
    var count: Int = 10

    mutating func run() async throws {
        let logger = Logger(label: "com.phototransformer.run")

        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        guard status == .authorized else {
            logger.info("Unauthorized: nothing to do")
            return
        }
        let opt = PHFetchOptions()
        opt.includeAssetSourceTypes = .typeUserLibrary

        let fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: opt)

        var assets: [PHAsset] = []
        fetchResult.enumerateObjects { asset, _, _ in
            assets.append(asset)
        }

        for asset in assets {
            let resource = PHAssetResource.assetResources(for: asset)

            if resource.count == 1,
               resource.contains(where: { res in
                   UTType(res.uniformTypeIdentifier)!.conforms(to: .rawImage)
               })
            {
                handleImage(imageObject: asset, resources: resource)
            }
        }
        logger.info("Done!")
    }
}

func handleImage(imageObject: PHAsset, resources _: [PHAssetResource]) {
    let logger = Logger(label: "com.phototransformer.handleImage")

    let options = PHImageRequestOptions()
    options.isSynchronous = true
    options.version = .original
    options.deliveryMode = .highQualityFormat
    options.isNetworkAccessAllowed = true

    let imageManager = PHImageManager.default()

    func resultHandler(
        _ image: Data?, _: String?, _: CGImagePropertyOrientation, _ info: [AnyHashable: Any]?
    ) {
        guard image != nil else {
            logger.error("Did not get image data \(String(describing: info))")
            return
        }

        guard let filename = imageObject.originalFilename else {
            logger.error("Image does not contain filename \(imageObject)")
            return
        }

        guard
            let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent("iterativeplatypus", isDirectory: true)
        else {
            logger.error("Unable to find Documents directory")
            return
        }
        let path = dir.appendingPathComponent(filename)

        do {
            try image?.write(to: path)
        } catch {
            logger.error("Failed to write to \(path)")
        }
    }

    imageManager.requestImageDataAndOrientation(
        for: imageObject, options: options, resultHandler: resultHandler
    )
}

extension PHAsset {
    var originalFilename: String? {
        var fileName: String?

        let resources = PHAssetResource.assetResources(for: self)
        if let resource = resources.first {
            fileName = resource.originalFilename
        }

        if fileName == nil {
            // https://stackoverflow.com/a/33420339
            fileName = value(forKey: "filename") as? String
        }

        return fileName
    }
}
