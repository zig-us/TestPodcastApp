//
//  ImportHelpers.swift
//  TestPodcastApp
//

import Foundation
import SwiftUI
import AVFoundation

// This file helps resolve import issues by providing common imports
// and type definitions for the application

// Re-export the model types for easy access
@_exported import struct Foundation.URL
@_exported import struct Foundation.TimeInterval
@_exported import struct Foundation.Date
@_exported import class Foundation.UserDefaults
@_exported import class Foundation.JSONEncoder
@_exported import class Foundation.JSONDecoder

// Fix the main attribute issue (needed when there's top-level code)
#if DEBUG
@_semantics("toplevel") @inline(never) 
func suppressTopLevelWarning() {
    // This function helps suppress top-level code warnings
    // It should never be called
}
#endif
