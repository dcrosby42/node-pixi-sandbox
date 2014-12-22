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
    console.log "going big"
    [savedWidth, savedHeight] = main.getRendererSize()
    console.log "savedWidth=#{savedWidth} savedHeight=#{savedHeight}"
    main.setRendererSize window.screen.width, window.screen.height

  goingSmall = ->
    console.log "savedWidth=#{savedWidth} savedHeight=#{savedHeight}"
    if savedWidth? and savedHeight?
      main.setRendererSize savedWidth, savedHeight

  goBig = ->
    if BigScreen.enabled
      console.log "requesting..."
      BigScreen.request main.renderer.view, goingBig, goingSmall

  $('#fullscreen').on "click", ->
    console.log "yeah!"
    goBig()

