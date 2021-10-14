//
//  UIFont+Typography.swift
//  DesignKit
//
//  Created by Jake Lin on 19/10/20.
//

import UIKit

public extension UIFont {
    static let designKit = DesignKitTypography()

    struct DesignKitTypography {
        //大标题（Display），用于显示这个页面的唯一标题，使用特大字号（如 42pt 和 36pt）
        public var display1: UIFont {
            scaled(baseFont: .systemFont(ofSize: 42, weight: .semibold), forTextStyle: .largeTitle, maximumFactor: 1.5)
        }

        public var display2: UIFont {
            scaled(baseFont: .systemFont(ofSize: 36, weight: .semibold), forTextStyle: .largeTitle, maximumFactor: 1.5)
        }

        //标题（Titile），用于显示段落的标题，我们提供了五种不同的段落标题，其字号由大变小
        public var title1: UIFont {
            scaled(baseFont: .systemFont(ofSize: 24, weight: .semibold), forTextStyle: .title1)
        }

        public var title2: UIFont {
            scaled(baseFont: .systemFont(ofSize: 20, weight: .semibold), forTextStyle: .title2)
        }

        public var title3: UIFont {
            scaled(baseFont: .systemFont(ofSize: 18, weight: .semibold), forTextStyle: .title3)
        }

        public var title4: UIFont {
            scaled(baseFont: .systemFont(ofSize: 14, weight: .regular), forTextStyle: .headline)
        }

        public var title5: UIFont {
            scaled(baseFont: .systemFont(ofSize: 12, weight: .regular), forTextStyle: .subheadline)
        }

        //文本（Body），用于显示一般的内容文本，我们提供了普通和加粗两种类型来呈现不同的文本
        public var bodyBold: UIFont {
            scaled(baseFont: .systemFont(ofSize: 16, weight: .semibold), forTextStyle: .body)
        }

        public var body: UIFont {
            scaled(baseFont: .systemFont(ofSize: 16, weight: .light), forTextStyle: .body)
        }

        public var captionBold: UIFont {
            scaled(baseFont: .systemFont(ofSize: 14, weight: .semibold), forTextStyle: .caption1)
        }

        public var caption: UIFont {
            scaled(baseFont: .systemFont(ofSize: 14, weight: .light), forTextStyle: .caption1)
        }

        //小文本（Small text），使用较小的字体来显示辅佐内容，例如备注、版本信息等。
        public var small: UIFont {
            scaled(baseFont: .systemFont(ofSize: 12, weight: .light), forTextStyle: .footnote)
        }
    }
}

private extension UIFont.DesignKitTypography {
    func scaled(baseFont: UIFont, forTextStyle textStyle: UIFont.TextStyle = .body, maximumFactor: CGFloat? = nil) -> UIFont {
        let fontMetrics = UIFontMetrics(forTextStyle: textStyle)

        if let maximumFactor = maximumFactor {
            let maximumPointSize = baseFont.pointSize * maximumFactor
            return fontMetrics.scaledFont(for: baseFont, maximumPointSize: maximumPointSize)
        }
        return fontMetrics.scaledFont(for: baseFont)
    }
}
