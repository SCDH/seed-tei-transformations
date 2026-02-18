window.onload = function () {
    console.log("window loaded");
    if (window.parent) {
	console.debug("size of document in iframe", document.body.scrollWidth, document.body.scrollHeight);
	window.parent.postMessage({"height": document.body.scrollHeight, "width": document.body.scrollWidth}, "*");
    }
};
