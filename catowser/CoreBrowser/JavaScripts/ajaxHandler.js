// Every time an Ajax call is being invoked the listener will recognize it and
// will call the native app with the request details.
// https://stackoverflow.com/questions/28766676/how-can-i-monitor-requests-on-wkwebview
// Following code only will work with Ajax script

$( document ).ajaxSend(function( event, request, settings )  {
    callNativeApp (settings.data);
});

function callNativeApp (data) {
    try {
        webkit.messageHandlers.callbackHandler.postMessage(data);
    }
    catch(err) {
        console.log('The native context does not exist yet');
    }
}
