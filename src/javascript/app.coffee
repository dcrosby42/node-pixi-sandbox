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

  window.main = main

  savedWidth = null
  savedHeight = null
  goingBig = ->
    [savedWidth, savedHeight] = main.getRendererSize()
    main.setRendererSize window.screen.width, window.screen.height

  goingSmall = ->
    if savedWidth? and savedHeight?
      main.setRendererSize savedWidth, savedHeight

  goBig = ->
    if BigScreen.enabled
      BigScreen.request main.renderer.view, goingBig, goingSmall

  $('#fullscreen').on "click", ->
    goBig()

