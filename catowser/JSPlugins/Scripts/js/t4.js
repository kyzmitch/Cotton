"use strict";

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

function cottonHandleT4HttpResponseText(json) {
    if (!cottonIsT4Enabled()){
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
        webkit.messageHandlers.t4Handler.postMessage({"video": JSON.stringify(json)});
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
