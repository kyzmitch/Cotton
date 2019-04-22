"use strict";

XMLHttpRequest.prototype.cottonRealSend = XMLHttpRequest.prototype.send;
XMLHttpRequest.prototype.send = function(body) {
	this.cottonRealSend(body);
	this.addEventListener('readystatechange', function() {
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

    cottonT4SendVideosToNativeApp(json);
}

function cottonT4SendVideosToNativeApp(nodes) {
    try {
        webkit.messageHandlers.t4Handler.postMessage({"videos": JSON.stringify(nodes)});
    } catch(err) {
        console.log('the native context does not exist yet');
    }
}

function cottonT4Log(message) {
	try {
		webkit.messageHandlers.igHandler.postMessage({"log": message});
	} catch(err) {
		console.log(message);
	}
}