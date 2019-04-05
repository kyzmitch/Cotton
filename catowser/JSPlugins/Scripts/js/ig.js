"use strict";

window.addEventListener("load", function() {
	window.setTimeout(cottonDelayedVideoLinksSearch, 2000);
}, false); 

XMLHttpRequest.prototype.cottonRealOpen = XMLHttpRequest.prototype.open;
XMLHttpRequest.prototype.open = function(method, url, async, username, password) {
	cottonLog('HttpRequest: ' + method  + ' url: ' + url);
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
		cottonLog('HttpResponse 200 OK:' + this.responseURL);
		cottonHandleHttpResponseText(this.responseText);
	});
};

function cottonHandleHttpResponseText(text) {
    cottonLog(text);
	// 1) attempt to extract from concrete user post
	let singleNode = text['graphql']['shortcode_media'];
	if(typeof singleNode !== 'undefined'){
		cottonNativeAppSendSingleNode(singleNode);
		return;
	}
	let feedEdges = cottonTryExtractAdditionalDataNodes(text);
	if(feedEdges.length != 0){
		cottonLog('going to send nodes from http response');
		sendVideoNodesToNativeApp(feedEdges);
	} else {
		cottonLog('http response doesn`t contain edge nodes');
	}
}

function cottonDelayedVideoLinksSearch() {
	let additionalDataJSON = window.__additionalData['feed'].data;
	if (typeof additionalDataJSON !== 'undefined') {
		let feedEdges = cottonTryExtractAdditionalDataNodes(additionalDataJSON);
		if(feedEdges.length != 0){
			cottonLog('going to send nodes from __additionalData');
			sendVideoNodesToNativeApp(feedEdges);
		} else {
			cottonLog('__additionalData doesn`t contain edge nodes');
		}
	} else {
		cottonLog('__additionalData isn`t defined');
	}
	
	let sharedDataJSON = window._sharedData;
	if (typeof sharedDataJSON !== 'undefined') {
		// even if it is not empty it not always contains nodes with urls
		let nodes = tryExtractVideoNodes(sharedDataJSON);
		if(nodes.length != 0){
			cottonLog('going to send nodes from _sharedData');
			sendVideoNodesToNativeApp(nodes);
		} else {
			cottonLog('_sharedData doesn`t contain edge nodes');
		}
	} else {
		cottonLog('_sharedData isn`t defined');
	}
}

function cottonTryExtractVideoTags(){
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

function cottonTryExtractAdditionalDataNodes(json) {
	cottonLog('Additional data: ' + JSON.stringify(json));
	let user = json['user'];
	let result = new Array();
	if(typeof user === 'undefined'){
		user = json['data']['user'];
		if(typeof user === 'undefined'){
			user = json['graphql']['user']
			if(typeof user === 'undefined'){
				return result;
			}
		}
	}
	let edge_web_feed_timeline = user['edge_web_feed_timeline'];
	if(typeof edge_web_feed_timeline === 'undefined'){
		edge_web_feed_timeline = user['edge_owner_to_timeline_media']
		if(typeof edge_web_feed_timeline === 'undefined'){
			return result;
		}
	}
	let edges = edge_web_feed_timeline['edges'];
	if(typeof edges === 'undefined'){
		return result;
	}

	return edges;
}

function tryExtractVideoNodes(json){
	// const edges = json['entry_data']['PostPage'][0]['graphql']['shortcode_media']['edge_sidecar_to_children']['edges'];
	let entry_data = json['entry_data'];
	let result = new Array();
	if(typeof entry_data === 'undefined'){
		return result;
	}
	let PostPage = entry_data['PostPage'];
	if(typeof PostPage === 'undefined'){
		return result;
	}
	let firstPage = PostPage[0];
	if(typeof firstPage === 'undefined'){
		return result;
	}
	let graphql = firstPage['graphql'];
	if(typeof graphql === 'undefined'){
		return result;
	}
	let shortcode_media = graphql['shortcode_media'];
	if(typeof shortcode_media === 'undefined'){
		return result;
	}
	let edge_sidecar_to_children = shortcode_media['edge_sidecar_to_children'];
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

function cottonNativeAppSendSingleNode(node) {
	console.log('video node: ' + node);
	try {
        webkit.messageHandlers.igHandler.postMessage({"singleVideoNode": JSON.stringify(node)});
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
