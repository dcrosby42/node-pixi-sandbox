jquery = require 'jquery'
# PIXI = require 'pixi.js'

Main = require './scroller/main'

jquery ->
  main = new Main(domElement: jquery('#game-holder')[0])
  window.main = main
