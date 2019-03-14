// Every time an Ajax call is being invoked the listener will recognize it and
// will call the native app with the request details.
// https://stackoverflow.com/questions/28766676/how-can-i-monitor-requests-on-wkwebview
// Following code only will work with Ajax script
// https://stackoverflow.com/a/7341884/483101

if (typeof jQuery == 'undefined') {
    // https://css-tricks.com/snippets/jquery/check-if-jquery-is-loaded/
    console.log('jQuery is not present on site')
} else {
    console.log('jQuery ajax listener will be added')
    $( document ).ajaxSend(function( event, request, settings )  {
        callNativeApp (settings.data);
    });
}

function callNativeApp (data) {
    try {
        webkit.messageHandlers.callbackHandler.postMessage(data);
    }
    catch(err) {
        console.log('The native context does not exist yet');
    }
}
