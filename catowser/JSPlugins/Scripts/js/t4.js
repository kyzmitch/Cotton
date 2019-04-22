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
		cottonLog('HttpResponse 200 OK:' + this.responseURL);
		cottonHandleT4HttpResponseText(this.responseText);
	});
};

function cottonHandleT4HttpResponseText(text) {
    let json = JSON.parse(text);
    if(typeof json === 'undefined'){
        return;
    }
    if(json.length == 0){
        return;
    }

    for (let i=0; i<json.length; i++) {
        console.log('video node[' + i + '] with url: ' + nodes[i]['video_url']);
    }
}

function cottonT4SendVideosToNativeApp(nodes) {
    try {
        webkit.messageHandlers.t4Handler.postMessage({"videoNodes": JSON.stringify(nodes)});
    } catch(err) {
        console.log('the native context does not exist yet');
    }
}
