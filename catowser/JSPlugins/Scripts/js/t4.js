"use strict";

if (typeof window.__cotton__ !== 'undefined') {
	Object.defineProperty(window.__cotton__, "t4", {
        enumerable: false,
        configurable: false,
        writable: false,
        value: {enabled: true}
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
} else {
    cottonT4Log('__cotton__ isn`t defined');
}

function cottonIsT4Enabled() {
    if (typeof window.__cotton__ === 'undefined') {
        console.log('window.__cotton__ isn`t defined');
        return false;
    }
    if (typeof window.__cotton__.t4 === 'undefined') {
        console.log('window.__cotton__.t4 isn`t defined');
        return false;
    }

    let isEnabled = window.__cotton__.t4['enabled'];
    if (typeof isEnabled === 'undefined') {
        console.log('t4 enabled key isn`t defined');
        return false;
    }
    if (!isEnabled) {
        console.log('t4 parsing disabled');
        return false;
    }

    return true;
}

XMLHttpRequest.prototype.cottonT4RealSend = XMLHttpRequest.prototype.send;
XMLHttpRequest.prototype.send = function(body) {
	this.cottonT4RealSend(body);
	this.addEventListener('readystatechange', function() {
        if (!cottonIsT4Enabled()) {
            return;
        }
		if (this.readyState !== 4 /* DONE */ || this.status !== 200) {
			return;
		}
		
		// this.responseType is empty for some reason, so it's not possible to parse 
		// for json specifically
		cottonT4Log('HttpResponse 200 OK:' + this.responseURL);
		cottonHandleT4HttpResponseText(this.responseText);
	});
};

function cottonHandleT4HttpResponseText(json) {
    if (!cottonIsT4Enabled()) {
        return;
    }
    if(typeof json === 'undefined'){
        return;
    }
    if(json.length == 0){
        return;
    }

    for (let mainKey in json) {
        let t4video = json[mainKey];
        let url = t4video['token'];
        if(typeof url === 'undefined') {
            console.log('resolution without token is ' + mainKey);
        } else {
            console.log('resolution is ' + mainKey + ', url: ' + url);
        }
    }

    if(typeof document.title !== 'undefined'){
        json['pageTitle'] = document.title;
    }

    try {
        webkit.messageHandlers.t4Handler.postMessage({"video": json});
    } catch(err) {
        console.log('the native context does not exist yet');
    }
}

function cottonT4Log(message) {
	try {
		webkit.messageHandlers.t4Handler.postMessage({"log": message});
	} catch(err) {
		console.log(message);
	}
}
