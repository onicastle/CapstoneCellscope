//
//  AmplifyModels.swift
//  CapstoneCellscope
//
//  Created by Oni on 5/4/21.
//

import Foundation
import Amplify

public struct Post: Model {
  public let id: String
  public var imageKey: String
  
  public init(id: String = UUID().uuidString,
      imageKey: String) {
      self.id = id
      self.imageKey = imageKey
  }
}

extension Post {
  // MARK: - CodingKeys
   public enum CodingKeys: String, ModelKey {
    case id
    case imageKey
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema
  
  public static let schema = defineSchema { model in
    let post = Post.keys
    
    model.pluralName = "Posts"
    
    model.fields(
      .id(),
      .field(post.imageKey, is: .required, ofType: .string)
    )
    }
}

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "00265f141d6acc2f132501296c3a4276"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: Post.self)
  }
}
