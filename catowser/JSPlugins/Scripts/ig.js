
"use strict";

window.addEventListener("load", function() {
    window.setTimeout(delayedVideoLinkSearch, 2000);
}, false); 

function delayedVideoLinkSearch() {
	if (window._sharedData) {
		const link = tryExtractLinkSingleVideoPost(window._sharedData);
		if (typeof link !== 'undefined') {
			sendLinkToNativeApp(link);
		}
		const links = tryExtractVideoFromOwnPost(window._sharedData);
		if(links.length == 0){
			cottonLog('empty links array');
		}
		for(var i=0;i<links.length;i++){
			sendLinkToNativeApp(links[i]);
		}
	}
	const metaLink = tryExtractVideoLinkFromMeta();
	if(metaLink) {
		sendLinkToNativeApp(metaLink);
	}
}

function tryExtractLinkSingleVideoPost(json){
	return json['entry_data']['PostPage'][0]['graphql']['shortcode_media']['video_url'];
}

function tryExtractVideoFromOwnPost(json){
	// const edges = json['entry_data']['PostPage'][0]['graphql']['shortcode_media']['edge_sidecar_to_children']['edges'];
	const entry_data = json['entry_data'];
	var result = new Array();
	if(typeof entry_data === 'undefined'){
		return result;
	}
	const PostPage = entry_data['PostPage'];
	if(typeof PostPage === 'undefined'){
		return result;
	}
	const firstPage = PostPage[0];
	if(typeof firstPage === 'undefined'){
		return result;
	}
	const graphql = firstPage['graphql'];
	if(typeof graphql === 'undefined'){
		return result;
	}
	const shortcode_media = graphql['shortcode_media'];
	if(typeof shortcode_media === 'undefined'){
		return result;
	}
	const edge_sidecar_to_children = shortcode_media['edge_sidecar_to_children'];
	if(typeof edge_sidecar_to_children === 'undefined'){
		return result;
	}
	const edges = edge_sidecar_to_children['edges'];
	if(typeof edges === 'undefined'){
		return result;
	}

	for(var i=0;i<edges.length;i++){
		const link = edges[i]['node']['video_url']
		if (typeof link !== 'undefined') {
			result.push(link);
		}
	}
	return result
}

function tryExtractVideoLinkFromMeta() {
	var metas = document.getElementsByTagName('meta');

	for (var i=0; i<metas.length; i++){
		var meta = metas[i];
		if (meta.getAttribute("property") == 'og:video'){
			return meta.getAttribute("content");
		}
	}

	return '';
}

function sendLinkToNativeApp(link) {
	console.log('Video url: ' + link);
		try {
			webkit.messageHandlers.igHandler.postMessage({"url": link});
    	} catch(err) {
			console.log('The native context does not exist yet');
    	}
}

function cottonLog(message) {
	try {
		webkit.messageHandlers.igHandler.postMessage({"log": message});
	} catch(err) {
		console.log(message);
	}
}
