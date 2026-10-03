import Flutter
import UIKit
import UserNotifications
import SwiftUI
import FamilyControls
import ManagedSettings

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

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var managedSettingsStore: Any? = nil

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

    channel.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else { return }

      switch call.method {
      case "isSupported":
        if #available(iOS 15.0, *) {
          result(true)
        } else {
          result(false)
        }

      case "hasAuthorization":
        if #available(iOS 15.0, *) {
          let status = AuthorizationCenter.shared.authorizationStatus
          result(status == .approved)
        } else {
          result(false)
        }

      case "requestAuthorization":
        if #available(iOS 15.0, *) {
          Task {
            do {
              try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
              result(true)
            } catch {
              result(FlutterError(code: "AUTH_ERROR", message: error.localizedDescription, details: nil))
            }
          }
        } else {
          result(false)
        }

      case "openAppPicker":
        if #available(iOS 15.0, *) {
          self.presentFamilyActivityPicker(result: result)
        } else {
          result(false)
        }

      case "startBlocking":
        if #available(iOS 15.0, *) {
          let store = ManagedSettingsStore()
          self.managedSettingsStore = store
          store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.all()
          result(true)
        } else {
          result(false)
        }

      case "stopBlocking":
        if #available(iOS 15.0, *) {
          if let store = self.managedSettingsStore as? ManagedSettingsStore {
            store.shield.applications = nil
            store.shield.applicationCategories = nil
          }
          self.managedSettingsStore = nil
          result(true)
        } else {
          result(false)
        }

      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  @available(iOS 15.0, *)
  private func presentFamilyActivityPicker(result: @escaping FlutterResult) {
    DispatchQueue.main.async {
      guard let rootVC = self.window?.rootViewController else {
        result(false)
        return
      }
      let pickerView = FamilyPickerView {
        result(true)
      }
      let hostingController = UIHostingController(rootView: pickerView)
      rootVC.present(hostingController, animated: true, completion: nil)
    }
  }
}
