"use strict";

if (typeof window.__cotton__ === 'undefined') {
    Object.defineProperty(window, "__cotton__", {
        enumerable: false,
        configurable: false,
        writable: false,
        value: {}
    });
}

if (typeof window.__cotton__ !== 'undefined') {
    Object.defineProperty(window.__cotton__, "t4", {
                          enumerable: false,
                          configurable: false,
                          writable: false,
                          value: {enabled: false}
                          });
    
    Object.defineProperty(window.__cotton__.t4, "setEnabled", {
                          enumerable: false,
                          configurable: false,
                          writable: false,
                          value: function(enabled) {
                            if (enabled === window.__cotton__.t4.enabled) {
                                return;
                            }
                            window.__cotton__.t4.enabled = enabled;
                            }
                          });
    Object.defineProperty(window.__cotton__, "ig", {
                          enumerable: false,
                          configurable: false,
                          writable: false,
                          value: {enabled: false}
                          });
    Object.defineProperty(window.__cotton__.ig, "setEnabled", {
                          enumerable: false,
                          configurable: false,
                          writable: false,
                          value: function(enabled) {
                            if (enabled === window.__cotton__.ig.enabled) {
                                return;
                            }
                            window.__cotton__.ig.enabled = enabled;
                            }
                          });
} else {
    cottonBaseLog('__cotton__ isn`t defined');
}

function cottonBaseLog(message) {
    try {
        webkit.messageHandlers.cottonHandler.postMessage({"log": message});
    } catch(err) {
        console.log(message);
    }
}

XMLHttpRequest.prototype.cottonRealOpen = XMLHttpRequest.prototype.open;
XMLHttpRequest.prototype.open = function(method, url, async, username, password) {
	cottonBaseLog('HttpRequest: ' + method  + ' url: ' + url);
	this.cottonRealOpen(method, url, async, username, password);
};

XMLHttpRequest.prototype.cottonRealSend = XMLHttpRequest.prototype.send;
XMLHttpRequest.prototype.send = function(body) {
	this.cottonRealSend(body);
	this.addEventListener('readystatechange', function() {
		if (this.readyState !== 4 /* DONE */ || this.status !== 200) {
			return;
		}
		
		// this.responseType is empty for some reason, so it's not possible to parse 
		// for json specifically
		cottonBaseLog('HttpResponse 200 OK:' + this.responseURL);
        let json = JSON.parse(this.responseText);
        window.__cotton__.ig.httpResponsHandler(json);
        if (typeof window.__cotton__.ig.httpResponsHandler !== 'undefined') {
            window.__cotton__.ig.httpResponsHandler(json);
        }
        if (typeof window.__cotton__.t4.httpResponsHandler !== 'undefined') {
            window.__cotton__.t4.httpResponsHandler(json);
        }
	});
};

window.addEventListener("load", function() {
    let htmlString = document.documentElement.outerHTML.toString();
    try {
	    webkit.messageHandlers.cottonHandler.postMessage({"html": htmlString});
    } catch(err) {
        console.log(message);
    }
}, false);