//
//  JobDescriptionHTML.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 14.10.2026.
//

import Foundation
import UIKit

enum JobDescriptionHTML {

    static func attributedString(from html: String) -> NSAttributedString {
        guard !html.isEmpty else {
            return NSAttributedString(string: "")
        }

        let document = """
        <html>
        <head>
        <meta charset="utf-8">
        </head>
        <body>
        \(html)
        </body>
        </html>
        """

        guard let data = document.data(using: .utf8) else {
            return NSAttributedString(string: html)
        }

        do {
            return try NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
            )
        } catch {
            return NSAttributedString(string: html)
        }
    }

    static func html(from attributedString: NSAttributedString) -> String {
        guard attributedString.length > 0 else {
            return ""
        }

        do {
            let data = try attributedString.data(
                from: NSRange(
                    location: 0,
                    length: attributedString.length
                ),
                documentAttributes: [
                    .documentType: NSAttributedString.DocumentType.html
                ]
            )

            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            return attributedString.string
        }
    }
}
