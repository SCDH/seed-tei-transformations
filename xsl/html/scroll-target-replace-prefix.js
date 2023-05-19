function makeScrollTarget(input) {
    var newPrefix = document.documentElement.id;
    var rest = input.substring(input.indexOf("."));
    return newPrefix + rest;
}
