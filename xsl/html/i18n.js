// local i18next setup
//import i18next from 'i18next';

const unidir = /^[.,;:!?-|\[\]\(\)\{\}\s،۔؛]*$/;

// variables defaultLanguage, initialLanguage must be initialized before!
// resources should be set after this with i18next.addResourceBundle(...)

i18next
  .init({
    resources: {},
    lng: initialLanguage,
    fallbackLng: defaultLanguage,
    debug: true,
  }, function(err, t) {
    // init set content
    //updateContent();
  });

const updateContent = (initial) => {
    return () => {
        // var el = document.getElementById("i18n-direction-indicator");
        // el.innerHTML = i18next.dir(i18next.language);

        var allElements = document.getElementsByTagName('*');
        for (var i = 0, n = allElements.length; i < n; i++) {
            // translate non-interpolation phrases
            var key = allElements[i].getAttribute('data-i18n-key');
            var namespace = allElements[i].getAttribute('data-i18n-ns');
            var lng = allElements[i].getAttribute('data-i18n-lang');
            if (key !== null) {
                var transl = null;
                var options = {};
                // The initial call of updateContent overrides the default
                // language with the language from the @data-i18n-lang
                // attribute if it is present.
                if (lng !== null && initial) {
                    options = { ...options, lng: lng };
                }
                if (namespace === null) {
                    // translate with i18next translations
                    transl = i18next.t(key, { ...options, ns: defaultNamespace });
                } else if  (namespace == 'decimal') {
                    // translate number
                    const l = options?.lng ?? i18next.language;
                    transl = translateDecimal(key, l);
                } else {
                    // translate with i18next translations
                    transl = i18next.t(key, { ...options, ns: namespace });
                }
                if (unidir.test(transl)) {
                    allElements[i].innerHTML = transl;
                } else {
                    allElements[i].innerHTML = "".concat(directionPrefix(lng), transl, directionSuffix(lng));
                }
            }
            // TODO: translate interpolation and pluralization phrases
        }
    }
}

// register translation function
window.onload = updateContent(true);

function directionPrefix(lang) {
    var dir = i18next.dir(lang ?? i18next.language);
    if (dir == "rtl") {
        return "&#x202B;"; // right-to-left embedding
    } else {
        return "&#x202A;"; // left-to-right embedding
    }
}

function directionSuffix() {
    return "&#x202C;";
}

function changeLng(lng) {
  i18next.changeLanguage(lng);
}

function getZeroCodepoint(language) {
    switch (language) {
    case "ar":
	return 0x660;
    default:
	return 0x30;
    }
}

// translate a decimal to the current language's script
function translateDecimal(dec, lang) {
    var fromZero = 0x30;
    var toZero = getZeroCodepoint(lang);
    if (fromZero == toZero) {
	return dec;
    } else {
	var codeblockDifference = toZero - fromZero;
	var result = "";
	for (let cifer of dec) {
	    // do we have to handle decimal points or commas?
	    result += String.fromCodePoint(cifer.codePointAt(0) + codeblockDifference);
	}
	return result;
    }
}

i18next.on('languageChanged', () => {
    updateContent(false)();
});
