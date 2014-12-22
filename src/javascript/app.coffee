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

  goBig = ->
    if BigScreen.enabled
      savedSize = main.getRendererSize()
      fullSize = {width: width, height: height} = window.screen
      goingBig = -> main.setRendererSize fullSize
      goingSmall = -> main.setRendererSize savedSize
      onError = (el,reason) ->
        console.log "Fullscreen failed because #{reason} on element:", el
      BigScreen.request main.renderer.view, goingBig, goingSmall, onError

  $('#fullscreen').on "click", ->
    goBig()

