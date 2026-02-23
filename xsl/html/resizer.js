function registerIFrameResizer(iframe) {
    console.debug('registering resizer on', iframe, iframe.contentWindow); 

    window.addEventListener('message', (event) => {
	if (event.source !== iframe.contentWindow) return;
	const newstyle = "width:" + (event.data.width + 10) + "px;height:" + (event.data.height + 20) + "px;display:block";
	console.debug('resizing iframe', iframe, "from", iframe.getBoundingClientRect(), "to", newstyle);
	//iframe.style.width = event.data.width;
	//iframe.style.height = event.data.height;
	iframe.setAttribute("style", newstyle);
    });
}
