jquery    = require 'jquery'

PixiHarness = require './pixi_harness'
SamusPreview = require './samus/preview'
BigScreen = require './vendor/bigscreen_wrapper'

jquery ->
  el = jquery('#game-holder')[0]

  samusPreview = new SamusPreview()
  harness = new PixiHarness
    domElement: el
    delegate: samusPreview
    width: 512
    height: 384
    stage_background: 0x000033

  harness.start()

  gameView = harness.view
  $('#fullscreen').on "click", ->
    BigScreen.doTheBigThing gameView


# for console debugging and messing around:
window.$  = jquery
window._  = require 'lodash'
