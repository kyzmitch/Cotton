"use strict";

window.addEventListener("load", function() {
	window.setTimeout(delayedVideoLinksSearch, 3000);
}, false); 

function delayedVideoLinksSearch() {
	let json = window.__additionalData['feed'].data;
	if (typeof json !== 'undefined') {
		let feedEdges = tryExtractAdditionalDataNodes(json);
		if(feedEdges.length != 0){
			sendVideoNodesToNativeApp(feedEdges);
		} else {
			cottonLog('empty nodes array from __additionalData');
		}
	} else {
		cottonLog('additionalData is empty');
	}
    
	if (typeof window._sharedData !== 'undefined') {
		let nodes = tryExtractVideoNodes(window._sharedData);
		if(nodes.length != 0){
			sendVideoNodesToNativeApp(nodes);
		} else {
			cottonLog('empty nodes array from _sharedData');
		}
	} else {
		cottonLog('_sharedData is empty');
	}
}

function tryExtractVideoTags(){
	let videoTags = document.getElementsByTagName('video')
	let resultTags = new Array();
    // videoTags is an HTMLCollection, so, can't use map
    for(let i = 0; i < videoTags.length; i++) {
		let tag = videoTags.item(i);
		let videoObject = {"src": tag.src, "poster": tag.poster};
		resultTags.push(videoObject);
	}
	return resultTags;
}

function tryExtractAdditionalDataNodes(json) {
	const user = json['user'];
	var result = new Array();
	if(typeof user === 'undefined'){
		return result;
	}
	const edge_web_feed_timeline = user['edge_web_feed_timeline'];
	if(typeof edge_web_feed_timeline === 'undefined'){
		return result;
	}
	let edges = edge_web_feed_timeline['edges'];
	if(typeof edges === 'undefined'){
		return result;
	}

	return edges;
}

function tryExtractVideoNodes(json){
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
	let edges = edge_sidecar_to_children['edges'];
	if(typeof edges === 'undefined'){
		return result;
	}

	// link should be edges[i]['node']['video_url']
	// returning whole object with previews instead of just video url
	return edges;
}

function tryExtractVideoLinkFromMeta() {
	let metas = document.getElementsByTagName('meta');

	for (let i=0; i<metas.length; i++){
		let meta = metas[i];
		if (meta.getAttribute("property") == 'og:video'){
			return meta.getAttribute("content");
		}
	}

	return '';
}

function sendLinkToNativeApp(link) {
	console.log('video url: ' + link);
    try {
        webkit.messageHandlers.igHandler.postMessage({"url": link});
    } catch(err) {
        console.log('the native context does not exist yet');
    }
}

function sendVideoNodesToNativeApp(nodes) {
	for (let i=0; i<nodes.length; i++) {
		console.log('video node[' + i + ']with url: ' + nodes[i]['node']['video_url']);
	}
    try {
		// JSON.stringify doesn't work, it returns the same array
        webkit.messageHandlers.igHandler.postMessage({"videoNodes": JSON.stringify(nodes)});
    } catch(err) {
        console.log('the native context does not exist yet');
    }
}

function sendVideoTagsToNativeApp(tags) {
	for (let i=0; i<tags.length; i++) {
		console.log('video tag with src: ' + tags[i]['src'])
	}
    try {
        webkit.messageHandlers.igHandler.postMessage({"videoTags": tags});
    } catch(err) {
        console.log('the native context does not exist yet');
    }
}

function cottonLog(message) {
	try {
		webkit.messageHandlers.igHandler.postMessage({"log": message});
	} catch(err) {
		console.log(message);
	}
}
