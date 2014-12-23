jquery    = require 'jquery'
window.$  = jquery # for console debugging and messing around

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
