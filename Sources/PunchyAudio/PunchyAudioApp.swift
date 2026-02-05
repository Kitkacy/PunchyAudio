import SwiftUI

@main
struct PunchyAudioApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var audioParser = AudioParser()
    var popover = NSPopover()
    var visualizerWindow: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: 44)
        
        if let button = statusItem?.button {
            button.image = nil
            button.title = ""
            
            let visualizerView = MenuBarVisualizerView(audioParser: audioParser)
            let hostingView = NSHostingView(rootView: visualizerView)
            
            hostingView.translatesAutoresizingMaskIntoConstraints = false
            button.addSubview(hostingView)
            
            NSLayoutConstraint.activate([
                hostingView.leadingAnchor.constraint(equalTo: button.leadingAnchor),
                hostingView.trailingAnchor.constraint(equalTo: button.trailingAnchor),
                hostingView.topAnchor.constraint(equalTo: button.topAnchor),
                hostingView.bottomAnchor.constraint(equalTo: button.bottomAnchor)
            ])
            
            button.action = #selector(togglePopover(_:))
            button.target = self
        }
        
        let appDelegate = self
        let contentView = PopoverContentView(
            audioParser: audioParser,
            onOpenVisualizer: { [weak appDelegate] in
                appDelegate?.popover.performClose(nil)
                appDelegate?.openVisualizerWindow()
            },
            onQuit: {
                NSApplication.shared.terminate(nil)
            }
        )
        
        popover.contentViewController = NSHostingController(rootView: contentView)
        popover.behavior = .transient
    }
    
    func openVisualizerWindow() {
        if let window = visualizerWindow {
            window.makeKeyAndOrderFront(nil)
            NSApplication.shared.activate(ignoringOtherApps: true)
            return
        }
        
        let visualizerView = FullScreenVisualizerView(audioParser: audioParser)
        let hostingController = NSHostingController(rootView: visualizerView)
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 900, height: 600),
            styleMask: [.titled, .closable, .resizable, .miniaturizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        window.contentViewController = hostingController
        window.minSize = NSSize(width: 640, height: 400)
        window.title = "PunchyAudio"
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.backgroundColor = .black
        window.isReleasedWhenClosed = false
        window.center()
        window.setFrameAutosaveName("PunchyAudioWindow")
        window.collectionBehavior = [.fullScreenPrimary]
        
        window.makeKeyAndOrderFront(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)
        
        visualizerWindow = window
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
         if let button = statusItem?.button {
             if popover.isShown {
                 popover.performClose(sender)
             } else {
                 popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
             }
         }
    }
}
