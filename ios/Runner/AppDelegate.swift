import Flutter
import UIKit
import UserNotifications
// Temporarily disabled FamilyControls / ManagedSettings for testing builds without entitlements
// import SwiftUI
// import FamilyControls
// import ManagedSettings

/*
@available(iOS 15.0, *)
struct FamilyPickerView: View {
  @State private var selection = FamilyActivitySelection()
  @Environment(\.dismiss) private var dismiss
  var onDone: () -> Void

  var body: some View {
    NavigationView {
      FamilyActivityPicker(selection: $selection)
        .navigationTitle("Select Allowed Apps")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .confirmationAction) {
            Button("Done") {
              onDone()
              dismiss()
            }
          }
        }
    }
  }
}
*/

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  // private var managedSettingsStore: Any? = nil

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }

    let controller = window?.rootViewController as? FlutterViewController
    if let controller = controller {
      setupFamilyControlsChannel(messenger: controller.binaryMessenger)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let messenger = engineBridge.pluginRegistry as? FlutterBinaryMessenger {
      setupFamilyControlsChannel(messenger: messenger)
    } else if let messenger = engineBridge.pluginRegistry.registrar(forPlugin: "Runner")?.messenger() {
      setupFamilyControlsChannel(messenger: messenger)
    }
  }

  private func setupFamilyControlsChannel(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: "com.lorofy.app/ios_family_controls",
      binaryMessenger: messenger
    )

    channel.setMethodCallHandler { (call, result) in
      // Stub responses for testing without FamilyControls entitlement
      switch call.method {
      case "isSupported":
        result(false)

      case "hasAuthorization":
        result(false)

      case "requestAuthorization":
        result(false)

      case "openAppPicker":
        result(false)

      case "startBlocking":
        result(false)

      case "stopBlocking":
        result(false)

      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
