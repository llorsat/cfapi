var fs = require('fs');
var path = require('path');
var util = require('util');
var exec = require('child_process').exec;
var ncp = require('ncp').ncp;

String.prototype.capitalize = function() {
    return this.charAt(0).toUpperCase() + this.slice(1);
}

Array.prototype.last = function() {
    var i = this.length;
    return this[i-1];
}

Array.prototype.first = function() {
  return this[0];
}

function modelsTemplate (appName) {
  var namespace = appName.replace(/\"/g, '').replace(/\,/g, '.');
  var model = namespace.split('.');
  return '/*\n'+
  '* Your models here\n'+
  '*/\n'+
  '\n'+
  '(function(namespace) {\n'+
  '\n'+
  '  var models = namespace.models;\n'+
  '\n'+
  '  models.'+model.last().capitalize()+' = Bb.Model.extend({\n'+
  '    defaults: {\n' +
  '      id: 1,\n'+
  '      name: "Example"\n'+
  '    }\n' +
  '  });\n'+
  '\n'+
  '})(' + namespace + ');\n';
}

function viewsTemplate (appName) {
  var namespace = appName.replace(/\"/g, '').replace(/\,/g, '.');
  var module = namespace.split('.');
  var id_template = namespace.replace(/\./g, '-')+'-template';
  return '/*\n'+
  '* Your views here\n'+
  '*/\n'+
  '\n'+
  '(function(namespace) {\n'+
  '\n'+
  '  var views = namespace.views;\n'+
  '  var models = namespace.models;\n'+
  '\n'+
  '  views.Index = Bb.View.extend({\n'+
  '    template: hbs.compile($(\'#'+id_template+'\').html()),\n'+
  '    model: null,\n'+
  '    initialize: function() {\n'+
  '      var me = this;\n'+
  '      me.model = new models.'+module.last().capitalize()+'();\n'+
  '      me.render();\n'+
  '    },\n'+
  '    render: function(){\n'+
  '      var me = this;\n'+
  '      me.$html(me.template(me.model.toJSON()));\n'+
  '      return me;\n'+
  '    }\n'+
  '  });\n'+
  '\n'+
  '})(' + namespace + ');';
}

function collectionsTemplate (appName) {
  var namespace = appName.replace(/\"/g, '').replace(/\,/g, '.');
  return '/*\n'+
  '* Your colletions here\n'+
  '*/\n'+
  '\n'+
  '(function(namespace) {\n'+
  '\n'+
  '  var collections = namespace.collections;\n'+
  '\n'+
  '  collections.MyCollection = Bb.Collection.extend({});\n'+
  '\n'+
  '})(' + namespace + ');';
}

function initTemplate (appName) {
  return '/*\n'+
  '* Your init functions here\n'+
  '* Default: namespaces definition.\n'+
  '*/\n'+
  '\n'+
  '(function(){\n'+
  '\n'+
  '  App.namespace(' + appName + ');\n'+
  '\n'+
  '})();';
}

function indexTemplate (appName) {
  var app = appName.replace(/\"/g, '').replace(/\,/g, '-');
  return '<!-- Your main template here -->\n'+
  '<script type="text/x-handlerbars-template" id="'+app+'-template">\n'+
  '  <h2>Your code HTML and handlebars here</h2>\n'+
  '  <hr>\n'+
  '  <p>Model id: {{ id }}</p>\n'+
  '  <p>Model name: {{ name }}</p>\n'+
  '</script>';
}

APP_COMPONENTS = [{
  file: 'models.js',
  content: modelsTemplate,
}, {
  file: 'views.js',
  content: viewsTemplate,
}, {
  file: 'collections.js',
  content: collectionsTemplate,
}, {
  file: 'init.js',
  content: initTemplate,
}, {
  file: 'templates/main.html',
  content: indexTemplate
}];

var packageJSON = JSON.parse(fs.readFileSync('package.json').toString());

var settings = packageJSON.settings;

function initializeAppArch(dirName, appName) {
  try{
    fs.mkdirSync(dirName+'/templates', 0755);
  } catch (err) {}
  for (var i = 0; i < APP_COMPONENTS.length; i++) {
    var fileName = path.join(dirName, APP_COMPONENTS[i].file);
    var fileContent = APP_COMPONENTS[i].content(appName);
    try {
      fs.writeFileSync(fileName, fileContent);
    } catch (err) {}
  }
}

function addAplicationToSettings(namespace) {
  packageJSON.settings.environment.applications.push(namespace);
  fs.writeFile('package.json', JSON.stringify(packageJSON, null, 2), function (err) {
    if (err) throw err;
  });
}

function deployTemplate(modernizr, app, requirements) {
  return '\n' + modernizr + '\n' + app + '\n' + requirements + ' window.main();';
}

function directoryTemplate(files) {
  var html = '<html><head></head><body>';
  for(var i = 0; i < files.length; i++) {
    html+='<li>' + files[i] + '</li>';
  }
  html += '</body></html>';
  return html;
}

var command = process.argv[2];

switch(command) {
  case 'startapp':
    if (process.argv.length < 4) {
      console.log('Too few arguments.');
      return false;
    }
    
    var dirName = '', appName = '', appPath = '', flag = false;
    
    for (var i = 3; i < process.argv.length; i++) {
      dirName = path.join(dirName, process.argv[i]);
      try {
        fs.mkdirSync(dirName, 0755);
      } catch (err) {
        if (i == process.argv.length - 1) {
          console.log('Directory already exists.');
          flag = true;
        }
      }
    }

    appName = '"' + dirName.replace(/\//g, ',').replace(/\\/g, ',') + '"';
    appPath = dirName.replace(/\//g, '.').replace(/\\/g, '.');

    if (flag) return false;

    initializeAppArch(dirName, appName, appPath);
    addAplicationToSettings(dirName);
    console.log('Your application has been created.');
    break;
  case 'i18n':
    exec('cd nodejs; grunt i18n', function(err, stdout, stderr) {
      if (err !== null) {
        console.log(err);
        console.log(stdout);
      } else {
        console.log('i18n files has been created and updated.');
      }
    });
    break;
  case 'deploy':
    var modernizr = fs.readFileSync('core/contrib/modernizr.js').toString();
    var app = fs.readFileSync('core/app.js').toString();
    var requirements = [];
    var libraries = settings.environment.libraries;
    var applications = settings.environment.applications;
    var scripts = settings.environment.main_files;
    var contentLibraries = '';
    ncp.limit = 16;
    ncp('stylesheets/images', 'deploy/images', function (err) {
     if (err) {
       return console.error(err);
     }
    });

    for (var i = 0; i < libraries.length; i++) {
      contentLibraries += fs.readFileSync('libraries/' + libraries[i]+'.js','utf8');
    }
    for (var i = 0; i < applications.length; i++) {
      contentLibraries += fs.readFileSync(applications[i] + '/init.js','utf8');
      contentLibraries += fs.readFileSync(applications[i] + '/models.js','utf8');
      contentLibraries += fs.readFileSync(applications[i] + '/collections.js','utf8');
      contentLibraries += fs.readFileSync(applications[i] + '/views.js','utf8');
    }
    for (var i = 0; i < scripts.length; i++) {
      contentLibraries += fs.readFileSync('main/' + scripts[i]+'.js','utf8');
    }
    try {
      fs.mkdirSync('deploy', 0755);
    } catch(err) {}
    fs.writeFileSync('deploy/_main_prototype_.js', deployTemplate(
      modernizr, 
      app,
      contentLibraries)
    );
    exec('cd nodejs; grunt min', function(err, stdout, stderr) {
      try {fs.unlinkSync('deploy/_main_prototype_.js');} catch(err){}
      if (err !== null) {
        console.log(err);
        console.log(stdout);
      } else {
        exec('lessc -x stylesheets/ui.less deploy/main.css');
        var indexContent = fs.readFileSync('index.template.html','utf8')+'\n';
        for (var i=0; i < applications.length; i++){
          var templates = fs.readdirSync(applications[i]+'/templates');
          for (var ii=0; ii< templates.length; ii++){
              indexContent += fs.readFileSync(applications[i]+'/templates/'+templates[ii],'utf8')+'\n\n';
          }
        }
        try {
          fs.mkdirSync('deploy/languages', 0755);
        } catch(err) {}
        var languages = fs.readdirSync('languages');
        for(var i = 0; i < languages.length; i++){
          var lenguage = fs.readFileSync('languages/'+languages[i], 'utf8');
          fs.writeFileSync('deploy/languages/'+languages[i],language);
        }
        indexContent += '<script src="main.js"></script>\n</body>\n</html>';
        fs.writeFileSync('deploy/index.html',indexContent);
        console.log('Your deploy is ready... enjoy! ;)');
      }
    });
    break;
  case 'runserver':
    // fuente: https://gist.github.com/701407
    var http = require("http"),
    url = require("url"),
    path = require("path"),
    fs = require("fs")
    port = process.argv[3] || 9300;

    http.createServer(function(request, response) {
      var uri = url.parse(request.url).pathname
        , filename = path.join(process.cwd(), uri);
      path.exists(filename, function(exists) {
        if(!exists) {
          response.writeHead(404, {"Content-Type": "text/plain"});
          response.write("404 Not Found\n");
          response.end();
          return;
        }
        if (filename.substring(0, filename.length - 1) == __dirname) {
          filename += 'index.html';
        }
        if (fs.statSync(filename).isDirectory()) {
          var content = fs.readdirSync(filename);
          response.writeHead(200);
          response.write(directoryTemplate(content), "binary");
          response.end();
        } else {
          fs.readFile(filename, "binary", function(err, file) {
            if(err) {
              response.writeHead(500, {"Content-Type": "text/plain"});
              response.write(err + "\n");
              response.end();
              return;
            }
            response.writeHead(200);
            response.write(file, "binary");
            response.end();
          });
        }
      });
    }).listen(parseInt(port, 10)).on('error', function(err) {
      errors = {
        'EADDRINUSE': 'Port: ' + port + ' is already in use.'
      }
      console.log(errors[err.code]);
    }).on('listening', function() {
      console.log("Server running at http://localhost:" + port);
      console.log("CTRL + C  to stop.");
    });
    break;
  default:
    console.log(command + ': comand not found');
}