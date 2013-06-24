# responsImg jQuery Plugin
# A plugin for loading the right image size according to browser width
# version 1.0, June 23th, 2013
# by Etienne Talbot

jQuery.responsImg = (element, settings) ->
  
  # default config values
  config =
    allowDownsize: false    # If set to false, smaller images will never be loaded on resize or orientationchange
  
  jQuery.extend config, settings if settings
  
  theWindow     = jQuery window
  element       = jQuery element
  rimData       = {}
  resizeTimer   = null
  largestSize   = 0
  retinaDisplay = false
  
  # initialize the plugin
  init = ->
    rimData[0]    = new Array(element.attr 'src')
    retinaDisplay = true if window.devicePixelRatio >= 1.5

    theWindow.on 'resize orientationchange', resizeDetected
    
    determineSizes()

    return
  
  # Put in an object the responsive values of the image
  determineSizes = ->
    elData        = element.data()
    pattern       = /^responsimg/

    for key, value of elData
      if pattern.test key
        newKey          = key.replace 'responsimg', ''
        rimData[newKey] = value.replace(' ', '').split ','

    checkSizes()

    return
  
  resizeDetected = ->
    clearTimeout resizeTimer
    resizeTimer = setTimeout checkSizes, 200

    return

  defineWidth = ->
    deviceWidth = null

    if window.orientation?
      if window.orientation is 0
        deviceWidth = window.screen.width
      else
        deviceWidth = window.screen.height

      if navigator.userAgent.indexOf('Android') >= 0 and window.devicePixelRatio
        deviceWidth = deviceWidth / window.devicePixelRatio;

    else
      deviceWidth = theWindow.width()
    
    deviceWidth

  checkSizes = ->
    theWidth         = defineWidth()
    currentSelection = 0
    largestSize      = 0
    doIt             = true
    newSrc           = ''

    if theWidth > largestSize
      largestSize = theWidth
    else if config.allowDownsize is false
      doIt = false

    if doIt is true
      for key, value of rimData
        if key <= theWidth and key >= currentSelection
          currentSelection = key
          newSrc           = rimData[currentSelection][0]

      if retinaDisplay is true and rimData[currentSelection][1]?
        newSrc = rimData[currentSelection][1]

      setImage newSrc

    return

  setImage = (newSrc) ->
    oldSrc = element.attr 'src'

    if newSrc != oldSrc
      element.attr 'src', newSrc

    return

  init()
  
  return this

jQuery.fn.responsImg = (options) ->
  @each( ->
    if jQuery(this).data('responsImg') is undefined
      plugin = new jQuery.responsImg this, options
      jQuery(this).data 'responsImg', plugin
    return
  )