
module.exports = function (grunt) {
  
  grunt.registerMultiTask('i18n', 'Search inline patterns.', function () {


    grunt.log.writeln('I18N Scanner.');

    var Path = require('path'),
      target = this.target,
      config = grunt.config(['i18n', this.target]) || {}
      languages = config.languages,
      blacklist = config.blacklist,
      whitelist = config.whitelist;

    var fs = require("fs");
    var basePath = Path.resolve("..");

    var results = [];
    var walk = function(dir){
      var paths = fs.readdirSync(dir);
      paths.forEach(function(path){
        if( blacklist.indexOf(path) === -1 ){
          var dirpath = Path.join(dir, path);
          var stat = fs.statSync(dirpath);
          if( stat.isDirectory() ){
            walk(dirpath)
          }else if( stat.isFile() ){
            whitelist.forEach(function(pattern){
              var reg = new RegExp(pattern+"$");
              if( dirpath.match(reg) ){
                results.push(dirpath);  
              }
            });
          }
        }
      });
    };
    walk(basePath);

    var i = 0;
    var strings = {};
    results.forEach(function(file){
      i++;
      var content = fs.readFileSync(file).toString();

      // templates
      var reg = new RegExp("\{\{\_\_ \"([^\"]{1,})\"\}\}", "g");
      while(match = reg.exec(content) ){
        if( match[1] ){
          strings[match[1]] = "";  
        }
      }
      var reg = new RegExp("\{\{ \_\_ \"([^\"]{1,})\" \}\}", "g");
      while(match = reg.exec(content) ){
        if( match[1] ){
          strings[match[1]] = "";  
        }
      }

      var content = fs.readFileSync(file).toString();
      // javascripts
      var reg = /__\(\"([^\"]{1,})\"\)/g;
      while(match = reg.exec(content) ){
        if( match[1] ){
          strings[match[1]] = "";
        }
      }

    });

    languages.forEach(function(language){

      var languageFile = Path.join(basePath, "languages", language + ".json");
      try {
        var contentFile = fs.readFileSync(languageFile).toString();
      } catch(err) {
        fs.writeFileSync(languageFile, "{}");
        var contentFile = fs.readFileSync(languageFile).toString();
      }
      var properties = JSON.parse(contentFile);
      grunt.log.writeln(languageFile);      
      for( word in strings){
        if( !properties[word] ){
          properties[word] = "";
        }
      }
    
      fs.writeFileSync(languageFile, JSON.stringify(properties, null, 2));

    });

  });

};
