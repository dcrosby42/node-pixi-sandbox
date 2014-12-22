jquery    = require 'jquery'
window.$  = jquery # for console debugging and messing around

Main      = require './scroller/main'
BigScreen = require './vendor/bigscreen_wrapper'

jquery ->
  el = jquery('#game-holder')[0]

  main = new Main
    domElement: el
    width: el.offsetWidth
    height: el.offsetHeight

  window.main = main # just for messing around

  $('#fullscreen').on "click", ->
    BigScreen.doTheBigThing main.renderer.view
