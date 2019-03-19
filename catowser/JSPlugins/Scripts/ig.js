
"use strict";

var ig_video_url = get_ig_meta('og:video');
// var ig_image_url = get_ig_meta('og:image');

if(ig_video_url){
	try {
        webkit.messageHandlers.igHandler.postMessage("url":ig_video_url);
    } catch(err) {
        webkit.messageHandlers.igHandler.postMessage("log":"The native context does not exist yet");
    }
}
else {
    webkit.messageHandlers.igHandler.postMessage("log":"No any video url was found");
}

function get_ig_meta(key) {
	var metas = document.getElementsByTagName('meta');

	for (i=0; i<metas.length; i++){
		if (metas[i].getAttribute("property") == key){
			return metas[i].getAttribute("content");
		}
	}

	return '';
}
