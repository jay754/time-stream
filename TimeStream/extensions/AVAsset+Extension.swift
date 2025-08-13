//
//  AVAsset+Extension.swift
//  TimeStream
//
//  Created by appssemble on 08.10.2021.
//

import AVKit

extension AVAsset {
    
    static func durationForAsset(url: URL) -> String {
        let asset = AVAsset(url: url)
        let cm = asset.duration
        let time = Int(ceil(cm.seconds))
        
        return time.secondsToTime()
    }
    
}
