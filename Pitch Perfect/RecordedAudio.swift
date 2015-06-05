//
//  RecordAudio.swift
//  Pitch Perfect
//
//  Created by Dina Daftedar on 6/1/15.
//  Copyright (c) 2015 Dina Daftedar. All rights reserved.
//

import Foundation

class RecordedAudio {
    var filePathUrl: NSURL!
    var title: String!
    
    
    init(filePathUrl: NSURL, title: String) {
        self.filePathUrl = filePathUrl
        self.title = title
    }
}