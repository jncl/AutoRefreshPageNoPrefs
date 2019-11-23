const myDebug = false;
var lastReloadTimestamp = new Date().getTime();

if (window.top === window) {
    // The parent frame is the top-level frame, not an iframe.
    // All non-iframe code goes before the closing brace.

    function handleMessage(event) {
        if (myDebug) console.log("injected - handleMessage", event, lastReloadTimestamp);

        if (event.name === "reload" && event.timeStamp > lastReloadTimestamp + (event.message.rInt * 1000)) {
            if (myDebug) console.log("reloading Page")
            location.reload(true);
        }
        
        // stop any further events
        event.stopPropagation();

    }
    
    if (myDebug) console.log("injected into " + location.href);

    safari.self.addEventListener("message", handleMessage);
    
    // check for reload when page receives focus
    window.onfocus = function() {
        if (myDebug) console.log("onFocus");
        safari.extension.dispatchMessage("checkReloadRequired");
    };

}
