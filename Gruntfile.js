module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    coffee: {
      api: {
        files: [{
          expand: true,
          cwd: "coffee/",
          src: ["**/*.coffee"],
          dest: "js/",
          ext: ".js"
        }]
      },
      web: {
        files: [{
          expand: true,
          cwd: "www/coffee/",
          src: ["**/*.coffee"],
          dest: "www/js/",
          ext: ".js"
        }]
      }
    },
    express: {
      options: {
        background: true,
        port: 8989
        // Override defaults here
      },
      dev: {
        options: {
          script: 'js/peppertalksampleapp.js'
        }
      }
    },
    wiredep: {
      task: {
        // Point to the files that should be updated when
        // you run `grunt wiredep`
        src: [
          'www/**/*.html'   // .html support...
        ],
        options: {
          // See wiredep's configuration documentation for the options
          // you may pass:
          // https://github.com/taptapship/wiredep#configuration
        }
      }
    },
    watch: {
      express: {
        files:  [ 'js/**/*.js' ],
        tasks:  [ 'express:dev' ],
        options: {
          spawn: false
        }
      },
      coffee: {
        files:  [ 'coffee/**/*.coffee' ],
        tasks:  [ 'coffee' ],
        options: {
          spawn: false
        }
      },
      coffee_web: {
        files:  [ 'www/coffee/**/*.coffee' ],
        tasks:  [ 'coffee' ],
        options: {
          spawn: false
        }
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-express-server');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-wiredep');
  // Default task(s).
  grunt.registerTask('default', ['coffee', 'wiredep']);
  grunt.registerTask('server', [ 'express:dev', 'watch' ]);

};