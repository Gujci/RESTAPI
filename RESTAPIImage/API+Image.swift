//
//  API+Image.swift
//  RESTAPIImage
//
//  Created by Gujgiczer Máté on 2018. 09. 25..
//  Copyright © 2018. gujci. All rights reserved.
//

import RESTAPI

struct JPGUploadMultipartFormData: MultipartFormData {
    
    var image: UIImage
    var fileName: String
    var uploadName: String
    
    var boundary = String.generatedBoudary
    
    public init(image: UIImage, fileName: String, uploadName: String) {
        self.image = image
        self.fileName = fileName
        self.uploadName = uploadName
    }
    
    var elements: [MultipartFormDataElement] { return [
        MultipartFormDataElement(name: "upfile", data: JPGData(image: image), customParams: ["filename": fileName + ".jpg"])
    ] }
}

enum JPGUploadError: Error {
    case cannotRepresentInJPG
}

struct JPGData {
    
    var image: UIImage
}

extension JPGData: ValidRequestData {
    
    func type() -> ContentType { return .custom("image/jpeg") }
    
    func requestData() throws -> Data {
        guard let data = image.jpegData(compressionQuality: 1) else { throw JPGUploadError.cannotRepresentInJPG }
        return data
    }
}
