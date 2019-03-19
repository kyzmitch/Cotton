
"use strict";

if(window.onload) {
    try {
        webkit.messageHandlers.igHandler.postMessage({"log":"Window already has onload handler"});
    } catch(err) {
        console.log('Window already has onload handler');
    }
	var currenload = window.onload;
	var newonload = function(evt) {
        searchIgVideoLink();
		currenload(evt);
	};
	window.onload = newonload;
} else {
	window.onload = searchIgVideoLink;
}

function searchIgVideoLink() {
	var ig_video_url = get_ig_meta('og:video');

	if(ig_video_url){
		console.log('found url' + ig_video_url);
		try {
			webkit.messageHandlers.igHandler.postMessage({"url": ig_video_url});
    	} catch(err) {
			console.log('The native context does not exist yet');
    	}
	}
	else {
		try {
			webkit.messageHandlers.igHandler.postMessage({"log":"No any video url was found"});
		} catch(err) {
			console.log('No any video url was found');
		}
	}
}

function get_ig_meta(key) {
	var metas = document.getElementsByTagName('meta');

	for (var i=0; i<metas.length; i++){
		if (metas[i].getAttribute("property") == key){
			return metas[i].getAttribute("content");
		}
	}

	return '';
}
