"use strict";

window.addEventListener("load", function() {
	window.setTimeout(cottonHandleHtml, 1000);
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

	// 1) attempt to extract from concrete user post
	let graphql = text['graphql'];
	if(typeof graphql !== 'undefined'){
		let singleNode = graphql['shortcode_media'];
		if(typeof singleNode !== 'undefined'){
			cottonNativeAppSendSingleNode(singleNode);
			return;
		}
	}

	let feedEdges = cottonTryExtractGrapthVideoNodes(JSON.parse(text));
	if(feedEdges.length != 0){
		cottonLog('HttpResponse: going to send nodes');
		sendVideoNodesToNativeApp(feedEdges);
	} else {
		cottonLog('HttpResponse: doesn`t contain edge nodes');
	}
}

function cottonHandleHtml() {
	cottonSearchAdditionalData();
	let sharedData = window._sharedData;
	if (typeof sharedData === 'undefined') {
		return;
	}

	cottonSearchSharedData(sharedData);
}

function cottonSearchAdditionalData() {
	if(typeof window.__additionalData === 'undefined'){
		cottonLog('__additionalData isn`t defined');
		return;
	}
	if(typeof window.__additionalData['feed'] === 'undefined'){
		cottonLog('__additionalData[feed] isn`t defined');
		return;
	}
	
	let additionalDataJSON = window.__additionalData['feed'].data;
	if (typeof additionalDataJSON === 'undefined'){
		cottonLog('__additionalData[feed] data isn`t defined');
		return;
	}

	let feedEdges = cottonTryExtractGrapthVideoNodes(additionalDataJSON);
	if(feedEdges.length != 0){
		cottonLog('going to send nodes from __additionalData');
		sendVideoNodesToNativeApp(feedEdges);
	} else {
		cottonLog('__additionalData doesn`t contain video nodes');
	}
}

function cottonSearchSharedData(sharedDataJSON) {
	// Shared data used for specific user posts

	let entry_data = sharedDataJSON['entry_data'];
	if(typeof entry_data === 'undefined') {
		return;
	}

	let PostPage = entry_data['PostPage'];
	if(typeof PostPage === 'undefined'){
		return;
	}
	let firstPage = PostPage[0];
	if(typeof firstPage === 'undefined'){
		return;
	}
	let graphql = firstPage['graphql'];
	if(typeof graphql === 'undefined'){
		return;
	}
	let shortcode_media = graphql['shortcode_media'];
	if(typeof shortcode_media === 'undefined'){
		return;
	}

	let nodes = cottonTryExtractVideoNodesFrom(shortcode_media);
	if(nodes.length != 0){
		cottonLog('going to send nodes from _sharedData');
		sendVideoNodesToNativeApp(nodes);
	} else {
		cottonLog('_sharedData doesn`t contain edge nodes');
	}
}

function cottonTryExtractGrapthVideoNodes(json) {
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
			let feed_reels_tray = user['feed_reels_tray'];
			if(typeof feed_reels_tray === 'undefined'){
				return result;
			}
			edge_web_feed_timeline = feed_reels_tray['edge_reels_tray_to_reel'];
			if(typeof edge_web_feed_timeline === 'undefined'){
				return result;
			}
		}
	}
	let edges = edge_web_feed_timeline['edges'];
	if(typeof edges === 'undefined'){
		return result;
	}

	let filteredEdges = filterVideoEdges(edges);
	return filteredEdges;
}

function filterVideoEdges(edges) {
	let filtered = new Array();
	for(let i=0; i<edges.length; i++){
		let edge = edges[i];
		let node = edge['node'];
		if(typeof node === 'undefined'){
			continue;
		}
		let videos = cottonTryExtractVideoNodesFrom(node);
		// https://stackoverflow.com/a/30846567/483101
		if(videos.length > 0) {
			filtered = filtered.concat(videos);
		}
	}
	return filtered;
}

function cottonTryExtractVideoNodesFrom(node) {
	let filtered = new Array();
	let __typename = node['__typename'];
	if(typeof __typename === 'undefined'){
		return filtered;
	}
	switch (__typename) {
		case "GraphVideo":
			return [node];
		case "GraphSidecar":
			let edge_sidecar_to_children = node['edge_sidecar_to_children'];
			if(typeof edge_sidecar_to_children === 'undefined'){
				return filtered;
			}
			let childrenEdges = edge_sidecar_to_children['edges'];
			if(typeof childrenEdges === 'undefined'){
				return filtered;
			}
			return filterVideoEdges(childrenEdges);
		default:
			return filtered;
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
		console.log('video node[' + i + '] with url: ' + nodes[i]['video_url']);
	}
	try {
		webkit.messageHandlers.igHandler.postMessage({"videoNodes": JSON.stringify(nodes)});
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
