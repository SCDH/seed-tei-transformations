// add event listener for mouse events on segments/spans
function seedRegisterOnSegmentEvents() {
    console.debug("add event listener for mouse over and mouse out events");
    document.body.addEventListener(
        "mouseover",
        seedPostMessageOnSegmentEvent("mouse-over-segment"),
    );
    document.body.addEventListener(
        "mouseout",
        seedPostMessageOnSegmentEvent("mouse-out-segment"),
    );
    document.body.addEventListener(
        "click",
        seedPostMessageOnSegmentEvent("click-segment"),
    );
}
window.addEventListener("load", (event) => {
    seedRegisterOnSegmentEvents();
});
// this returns the function to be fired on the event
const seedPostMessageOnSegmentEvent = (eventType) => {
    return function (e) {
	console.log(e);
        e = e || window.event;
        var targetElement = e.target || e.srcElement;
        var lineFacs = seedAncestorOrSelfLineFacs(targetElement, []);
	// switch highlighting
	if (eventType == "mouse-over-segment") {
	    for (const el of document.getElementsByClassName("facs-" + lineFacs)) {
		el.style.borderTop = "1px solid orange";
		el.style.borderBottom = "1px solid orange";
		el.style.background = "papayawhip";
	    }
	} else if (eventType == "mouse-out-segment") {
	    for (const el of document.getElementsByClassName("facs-" + lineFacs)) {
		el.style.border = "none";
		el.style.background = "white";
	    };
	}
	// notify parent window
	if (window?.parent?.location?.href) return;
        window.parent.postMessage(
            { ...msg, event: eventType, segmentFacs: lineFacs },
            window.parent.location.href,
        );
    };
};
/*
 * Recursively collects the @data-linefacs from the element and its
 * ancestors. The IDs from ancestors are of interest, since
 * annotations may be nested or attributed to whole paragraphs or
 * divisions.
 */
function seedAncestorOrSelfLineFacs(element, facs) {
    if (!(element instanceof HTMLElement)) return facs;
    if (element.hasAttribute("data-linefacs")) facs.push(element.dataset.linefacs);
    if (!element.parentNode) return facs;
    return seedAncestorOrSelfLineFacs(element.parentNode, facs);
}
