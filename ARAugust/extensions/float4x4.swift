//
//  float4x4.swift
//  ARAugust
//
//  Created by Matthew Chiang on 8/30/18.
//  Copyright © 2018 Matthew Chiang. All rights reserved.
//

import Foundation

extension matrix_float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}
