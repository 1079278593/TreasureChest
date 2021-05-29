//
//  RoutingSource.swift
//  Moments
//
//  Created by Jake Lin on 4/2/21.
//

import Foundation
import UIKit

/**
 首先，我们定义一个名为RoutingSource的空协议，
 然后让UIViewController遵循该协议。
 这样就能让route(to:from:using)方法与UIViewController进行解耦。（因为后面只和RoutingSource打交道）
 */

protocol RoutingSource: class { }

typealias RoutingSourceProvider = () -> RoutingSource?

extension UIViewController: RoutingSource { }
