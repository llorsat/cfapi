var fs = require('fs');
var path = require('path');
var _ = require('underscore');

var command = process.argv[2];

var ReflectionDoc = {
  getComments: function(content) {
    var commentRegexp = /\<\!\-\-\-(\n*[@a-z0-9\'\*\<\>\,\s\_\-\.\/\{\}\:\[\]\|]*\n*)\s+\-\-\-\>/gi;
    var comments = content.match(commentRegexp);
    if (comments) {
      var ret = _.map(comments, function(commentCode) {
        var lineDocRegexp = /^\@([a-z0-9]{1,})\s+((.{1,}\s*)+)$/i;
        var lines = _.filter(
          _.map(commentCode.split("\n"), function(l) {
            return l.trim();
          }), function(l2) {
          return lineDocRegexp.test(l2);
        });
        return _.reduce(lines, function(obj, l) {
          var matches = l.match(lineDocRegexp);
          var tagName = matches[1];
          var isArg = /\:/.test(matches[2]);
          if (isArg) {

            matches[2] = ReflectionDoc.getArg(matches[2]);
          }
          if (_.has(obj, tagName)) {
            if (_.isArray(obj[tagName])) {
              obj[tagName].push(matches[2]);
            } else {

              obj[tagName] = [obj[tagName], matches[2]];
            }
          } else {
            if (tagName == "args") {
              obj[tagName] = [];
              obj[tagName].push(matches[2]);
            } else {
              obj[tagName] = matches[2];  
            }
          }
          
          return obj;
        }, {});
      });
      return _.filter(ret, function(r) {
        return !_.isEmpty(r);
      });
    }
    return [];
  },
  getArg: function(line) {
    var a = line.replace(/\s{2,}/gi, ' ').trim().split(":");
    a = _.map(a, function(b) {
      return b.trim();
    });
    return {
      name: a[0],
      type: a[1],
      value: a[2] || '',
      description: a[3] || '',
    };
  },
  getRestDescription: function(content) {
    var comments = this.getComments(content);
    var obj = _.find(comments, function(c) {
      return _.has(c, 'resource');
    });
    var defaultResource = {
      resource: 'nonamed',
    };
    obj = obj ? obj : defaultResource;
    var operations = _.filter(comments, function(c) {
      return c !== obj;
    });
    obj.operations = operations;
    obj.tags = _.has(obj, 'tags') ? obj.tags.split(',') : [];
    _.each(obj.operations, function(operation) {
      operation.tags = _.has(operation, 'tags') ? operation.tags.split(',') : [];
    });
    return obj;
  }, 
  generateMetadata: function(resourcePath, project, baseUrl, description) {
    var resources = fs.readdirSync(resourcePath);
    var metadata = {
      project: project,
      baseUrl: baseUrl,
      description: description,
      resources: []
    };
    _.each(resources, function (r) {
      var resourceFile = resourcePath + r;
      var content = fs.readFileSync(resourceFile, 'utf8');
      var description = ReflectionDoc.getRestDescription(content);
      if (description.resource != 'nonamed') {
        metadata.resources.push(description);
      }
    });
    return metadata;
  }
};

switch(command) {
  case 'generate-doc':
    console.log("Generando documentación...");
    var resourcePath = 'resources/';
    var metadata = ReflectionDoc.generateMetadata(resourcePath, "Next API", "http://localhost:8500/nextapi/index.cfm/", "gateway between next_ws and nexth5");
    fs.writeFileSync('doc/metadata.json', JSON.stringify(metadata, null, 2));
  break;
  default:
    console.log(command + ': comando no encontrado');
}
