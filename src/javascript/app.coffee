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

  view = main.renderer.view

  goBig = ->
    if BigScreen.enabled
      savedWidth = view.offsetWidth
      savedHeight = view.offsetHeight
      goingBig = ->
        view.style.width = "#{window.screen.width}px"
        view.style.height = "#{window.screen.height}px"
      goingSmall = ->
        view.style.width = "#{savedWidth}px"
        view.style.height = "#{savedHeight}px"
      onError = (el,reason) ->
        console.log "Fullscreen failed because #{reason} on element:", el
      BigScreen.request view, goingBig, goingSmall, onError

  $('#fullscreen').on "click", ->
    goBig()

