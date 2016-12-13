module.exports = {
  snippetOptions: {
    rule: {
      match: /<\/html>/i,
      fn: function (snippet, match) {
        return snippet + match;
      }
    }
  },
  files: ['public/*.html', 'public/*.css', 'public/*.js'],
  server: {
    baseDir: "./public/"
  },
  host: "127.0.0.1"
};
