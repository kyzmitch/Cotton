var ig_video_url = get_ig_meta('og:video');
// var ig_image_url = get_ig_meta('og:image');

if(ig_video_url){
	try {
        webkit.messageHandlers.callbackHandler.postMessage(meta_video);
    } catch(err) {
        console.log('The native context does not exist yet');
    }
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
