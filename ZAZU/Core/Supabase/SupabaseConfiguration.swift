//
//  SupabaseConfiguration.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//

import Foundation

enum SupabaseConfiguration {
    static var url: URL {
        guard
            let value = Bundle.main.object(
                forInfoDictionaryKey: "SUPABASE_URL"
            ) as? String,
            let url = URL(string: value)
        else {
            fatalError("SUPABASE_URL is missing or invalid.")
        }

        return url
    }

    static var publishableKey: String {
        guard
            let value = Bundle.main.object(
                forInfoDictionaryKey: "SUPABASE_PUBLISHABLE_KEY"
            ) as? String,
            !value.isEmpty
        else {
            fatalError("SUPABASE_PUBLISHABLE_KEY is missing.")
        }

        return value
    }
}
