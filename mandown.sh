coffee -c mandown.coffee
phantomjs --disk-cache true mandown.js $@
rm mandown.js