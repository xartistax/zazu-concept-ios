//
//  AppState.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//

import Foundation
import Observation

@Observable
@MainActor
final class AppState {
    enum RootState {
        case loading
        case authentication
        case onboarding
        case main
        case employerOnboarding
        case employerMain
        case error(String)
        
    }

    var rootState: RootState = .loading
}
