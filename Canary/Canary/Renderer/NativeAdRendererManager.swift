//
//  NativeAdRendererManager.swift
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation
import MoPub


final class NativeAdRendererManager {
    static let shared = NativeAdRendererManager()
    private let userDefaults: UserDefaults
    
    /**
     Class name of enabled renderers.
     */
    var enabledRendererClassNames: [String] {
        get {
            return userDefaults.enabledAdRenderers
        }
        set {
            userDefaults.enabledAdRenderers = newValue
        }
    }
    
    /**
     Class name of disabled renderers.
     */
    var disabledRendererClassNames: [String] {
        get {
            return userDefaults.disabledAdRenderers
        }
        set {
            userDefaults.disabledAdRenderers = newValue
        }
    }
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        
        let existedRendererClassNames = Set(enabledRendererClassNames + disabledRendererClassNames)
        let newRendererClassNames = rendererConfigurations.compactMap {
            existedRendererClassNames.contains($0.rendererClassName) ? nil : $0.rendererClassName
        }
        if !newRendererClassNames.isEmpty {
            // enable all new renderers by default
            enabledRendererClassNames += newRendererClassNames
        }
    }
    
    /**
     Enabled ad renderer configurations.
     */
    var enabledRendererConfigurations: [MPNativeAdRendererConfiguration] {
        let disabledAdRenderers = Set(disabledRendererClassNames)
        let configs = rendererConfigurations.filter {
            !disabledAdRenderers.contains($0.rendererClassName)
        }
        return (configs as [StringKeyable]).sorted(inTheSameOrderAs: enabledRendererClassNames)
    }
}

// MARK: - Private

private extension NativeAdRendererManager {
    /**
     Ad renderer configurations.
     */
    var rendererConfigurations: [MPNativeAdRendererConfiguration] {
        let networkRendererConfigurations = self.networkRendererConfigurations // cache computed var result
        var configs = [MPNativeAdRendererConfiguration]()
        configs.append(contentsOf: networkRendererConfigurations)
        configs.append({ // add `MPStaticNativeAdRenderer`
            var networkSupportedCustomEvents = Set<String>() // add the custom event names to `MPStaticNativeAdRenderer`
            networkRendererConfigurations.forEach {
                networkSupportedCustomEvents.formUnion($0.supportedCustomEvents as? [String] ?? [])
            }
            return MPStaticNativeAdRenderer.rendererConfiguration(with: mopubRendererSettings,
                                                                  additionalSupportedCustomEvents: Array(networkSupportedCustomEvents))
        }())
        
        return configs
    }

    /**
     MoPub static ad renderer settings
     */
    var mopubRendererSettings: MPStaticNativeAdRendererSettings {
        // MoPub static renderer
        let mopubSettings: MPStaticNativeAdRendererSettings = MPStaticNativeAdRendererSettings()
        mopubSettings.renderingViewClass = NativeAdView.self
        mopubSettings.viewSizeHandler = { (width) -> CGSize in
            return CGSize(width: width, height: NativeAdView.estimatedViewHeightForWidth(width))
        }
        
        return mopubSettings
    }
    
    /**
     Renderers for mediated networks
     */
    var networkRendererConfigurations: [MPNativeAdRendererConfiguration] {
        var renderers: [MPNativeAdRendererConfiguration] = []
        
        return renderers
    }
}

// MARK: - Private UserDefaults Storage

private extension UserDefaults {
    /**
     The private `UserDefaults.Key` for accessing `enabledAdRenderers`.
     */
    private var enabledAdRenderersKey: Key<[String]> {
        return Key<[String]>("enabledAdRenderers", defaultValue: [])
    }
    
    /**
     A list class names of enabled native ad renderer. When picking a renderer for native ads, the
     first match in this list should be picked.
     */
    var enabledAdRenderers: [String] {
        get {
            return self[enabledAdRenderersKey]
        }
        set {
            self[enabledAdRenderersKey] = newValue
        }
    }
}

private extension UserDefaults {
    /**
     The private `UserDefaults.Key` for accessing `disabledAdRenderers`.
     */
    private var disabledAdRenderersKey: Key<[String]> {
        return Key<[String]>("disabledAdRenderers", defaultValue: [])
    }
    
    /**
     A list of class names of disabled native ad renderer.
     */
    var disabledAdRenderers: [String] {
        get {
            return self[disabledAdRenderersKey]
        }
        set {
            self[disabledAdRenderersKey] = newValue
        }
    }
}
