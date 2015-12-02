module.exports = function(grunt) {
  // load all grunt tasks
  require('load-grunt-tasks')(grunt);

  // grunt config
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),


    connect: {
      html: {
        options: {
          base: '',
          keepalive: 'true',
          hostname: '0.0.0.0',
          port: '9999'
        }
      }
    },

    postcss: {
      options: {
        map: false,
        processors: [
          require('autoprefixer') ({
            browsers: 'last 2 version'
          })
        ]
      },
      style: {
        src: 'css/style.css'
      }
    },

    sass: {
      style: {
        files: [{
          cwd: 'sass/',
          dest: 'css/',
          expand: true,
          ext: '.css',
          src: ['*.scss']
        }],
        options: {
          sourcemap: 'none',
          style: 'expanded'
        }
      }
    },

    watch: {
      style: {
        files: ['js/src/*.js', 'sass/*.scss'],
        tasks: ['sass:style', 'postcss:style']
      }
    },

    browserSync: {
      bsFiles: {
        src: ['*.html', 'js/*.js', 'css/*.css'],
      },
      options: {
        watchTask: true,
        server: {
          baseDir: "./"
        }
      }
    },

    // dev update
    devUpdate: {
      main: {
        options: {
          semver: false,
          updateType: 'prompt'
        }
      }
    }
  });
  grunt.registerTask('default', [/* 'browserSync', */ 'watch']);
};
