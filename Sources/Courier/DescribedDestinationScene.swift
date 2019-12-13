//
//  StoryboardScene.swift
//  Courier
//
//  Created by k2o on 2019/12/06.
//  Copyright © 2019 imk2o. All rights reserved.
//

import UIKit

// Storyboard Sceneを特定するための情報
public struct StoryboardDescription {
    public let name: String
    public let identifier: String?
    public let bundle: Bundle
    
    public init(name: String, identifier: String? = nil, bundle: Bundle = .main) {
        self.name = name
        self.identifier = identifier
        self.bundle = bundle
    }
    
    public func storyboard() -> UIStoryboard {
        return .init(name: self.name, bundle: self.bundle)
    }
}

// StoryboardDescriptionで特定可能な画面
// 自身でインスタンス化が可能
public protocol DescribedDestinationScene: DestinationScene {
    static var storyboardDescription: StoryboardDescription { get }
}
public typealias DescribedDestinationViewController = DescribedDestinationScene & UIViewController

extension DescribedDestinationScene where Self: UIViewController {
    public static func instantiate(with context: Context) -> UIViewController! {
        let viewController: UIViewController? = {
            if let storyboardIdentifier = self.storyboardDescription.identifier {
                return self.storyboardDescription.storyboard()
                    .instantiateViewController(withIdentifier: storyboardIdentifier)
            } else {
                return self.storyboardDescription.storyboard()
                    .instantiateInitialViewController()
            }
        }()
        
        if let contentViewController = viewController?.contentViewController() as? Self {
            contentViewController.context = context
        }

        return viewController
    }
}
