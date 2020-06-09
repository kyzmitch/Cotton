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

    Object.defineProperty(window.__cotton__, "isHandledHost", {
                            enumerable: false,
                            configurable: false,
                            writable: false,
                            value: function() {
                                let currentHost = window.location.hostname;
                                let on4Tube = currentHost.includes("4tube.com");
                                let onIg = currentHost.includes("instagram.com");
                                if (on4Tube || onIg) {
                                    return false;
                                } else {
                                    return true;
                                }
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
	// cottonBaseLog('HttpRequest: ' + method  + ' url: ' + url);
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
		// cottonBaseLog('HttpResponse 200 OK: ' + this.responseURL);
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
    window.setTimeout(cottonHandleIgHtml, 3000);
}, false);

function cottonHandleIgHtml() {
    if (!window.__cotton__.isHandledHost()) {
        return;
    }
    let htmlString = document.documentElement.outerHTML.toString();
    try {
        let json = {"hostname": location.hostname,"htmlString": htmlString};
        webkit.messageHandlers.cottonHandler.postMessage({"html": JSON.stringify(json)});
    } catch(err) {
        console.log(message);
    }
}

document.body.addEventListener('DOMSubtreeModified', function(event) {
    if (!window.__cotton__.isHandledHost()) {
        return;
    }
    cottonBaseLog('DOMSubtreeModified triggered');
}, false);

(function () {
    let callback = function(mutationsList, observer) {
        cottonBaseLog('HTML DOM change detected');
        let tags = [];
        for(let mutation of mutationsList) {
            // https://developer.mozilla.org/en-US/docs/Web/API/MutationRecord
            // https://developer.mozilla.org/en-US/docs/Web/API/NodeList

            for(let node of mutation.addedNodes) {
                if (!(node instanceof HTMLElement)) {
                    cottonBaseLog('added non HTMLElement');
                    continue;
                }
                if (!(node.tagName == 'video')) {
                    continue;
                }
                cottonBaseLog('video tag added to html');

                let srcURL = node.getAttribute('src');
                let posterURL = node.getAttribute('poster');
                if (typeof srcURL === 'undefined'){
                    cottonBaseLog('video tag without source URL');
                    continue;
                }
                let videoTag = {};
                videoTag['src'] = srcURL;
                if (typeof posterURL !== 'undefined') {
                    videoTag['poster'] = posterURL;
                }
                tags.push(videoTag);
            }
        }

        if (tags.length > 0) {
            webkit.messageHandlers.cottonHandler.postMessage({"domVideos": tags});
        }
    };
    
    var videoTagsDOMobserver = new MutationObserver(callback);
    if (typeof videoTagsDOMobserver === 'undefined') {
        cottonBaseLog('failed create DOM observer');
    }
    let bodyObserverConfig = {'attributes': false, 'childList': true, 'subtree': true, 'characterData': false};
    videoTagsDOMobserver.observe(document, bodyObserverConfig);
}());
