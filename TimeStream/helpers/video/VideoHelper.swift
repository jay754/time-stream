//
//  VideoHelper.swift
//  TimeStream
//
//  Created by appssemble on 05.10.2021.
//

import Foundation
import AVKit

class VideoHelper {
    
    static func generateThumbnail(url: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: url , options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let time = CMTime(value: asset.duration.value / 2, timescale: asset.duration.timescale)
            let cgImage = try imgGenerator.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            
            return thumbnail
            
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func encodeVideo(at videoURL: URL, completionHandler: ShareURL?)  {
        let avAsset = AVURLAsset(url: videoURL, options: nil)

        //Create Export session
        guard let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPreset1280x720) else {
            completionHandler?(nil)
            return
        }

        //Creating temp path to save the converted video
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
        let filePath = documentsDirectory.appendingPathComponent("rendered-video-for-upload.mp4")

        //Check if the file already exists then remove the previous file
        if FileManager.default.fileExists(atPath: filePath.path) {
            do {
                try FileManager.default.removeItem(at: filePath)
            } catch {
                completionHandler?(nil)
            }
        }

        exportSession.outputURL = filePath
        exportSession.outputFileType = AVFileType.mp4
        exportSession.shouldOptimizeForNetworkUse = true
          let start = CMTimeMakeWithSeconds(0.0, preferredTimescale: 0)
        let range = CMTimeRangeMake(start: start, duration: avAsset.duration)
        exportSession.timeRange = range
        
        exportSession.exportAsynchronously(completionHandler: {() -> Void in
            DispatchQueue.main.async {
                switch exportSession.status {
                case .failed:
                    print(exportSession.error ?? "NO ERROR")
                    completionHandler?(nil)
                    
                case .cancelled:
                    print("Export canceled")
                    completionHandler?(nil)
                    
                case .completed:
                    //Video conversion finished
                    completionHandler?(exportSession.outputURL)
                    
                default: break
                }
            }
        })
    }
}

