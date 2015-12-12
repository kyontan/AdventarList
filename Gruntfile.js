module.exports = function(grunt) {
  // load all grunt tasks
  require('load-grunt-tasks')(grunt);

  // grunt config
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

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
          cwd: 'views/sass/',
          dest: 'views/css/',
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
        files: ['views/js/src/*.js', 'views/sass/*.scss'],
        tasks: ['sass:style', 'postcss:style']
      }
    },

    browserSync: {
      bsFiles: {
        src: ['views/*.haml', 'public/*.html',
              'views/js/*.js', 'public/*.js',
              'views/css/*.css', 'public/*.css']
      },
      options: {
        watchTask: true,
        proxy: `http://127.0.0.1:${grunt.option("port") || "9393"}`,
        // server: {
        //   baseDir: "./"
        // }
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


  grunt.registerTask("default", ["browserSync", "watch"]);
};
