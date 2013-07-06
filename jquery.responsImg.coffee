# responsImg jQuery Plugin
# A plugin for loading the right image size according to browser width
# version 1.2.0, July 6th, 2013
# by Etienne Talbot

jQuery.responsImg = (element, settings) ->
  
  # default config values
  config =
    allowDownsize: false    # If set to false, smaller images will never be loaded on resize or orientationchange
    elementQuery:  false    # False = window's width breakpoints. True = image's width breakpoints.
    delay:         200      # Delay between the window resize action and the image change (too low means more demanding for the browser)
    breakpoints:   null
  
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

    theWindow.on 'resize.responsImg orientationchange.responsImg', resizeDetected
    
    determineSizes()

    return
  
  # Put in an object the responsive values of the image
  determineSizes = ->
    elData        = element.data()
    pattern       = /^responsimg/

    for key, value of elData

      if pattern.test key
        newKey          = key.replace 'responsimg', ''

        if isNaN(newKey)
          newKey = newKey.toLowerCase()
          for breakKey, breakValue of config.breakpoints
            if newKey == breakKey
              newKey = breakValue
        else
          newKey = parseInt newKey

        rimData[newKey] = value.replace(' ', '').split ','

    checkSizes()

    return
  
  resizeDetected = ->
    clearTimeout resizeTimer
    resizeTimer = setTimeout checkSizes, config.delay

    return

  defineWidth = ->
    definedWidth = null

    if config.elementQuery is true
      definedWidth = element.width()
      
    else
      if window.orientation?
        if window.orientation is 0
          definedWidth = window.screen.width
        else
          definedWidth = window.screen.height

        if navigator.userAgent.indexOf('Android') >= 0 and window.devicePixelRatio
          definedWidth = definedWidth / window.devicePixelRatio;

      else
        definedWidth = theWindow.width()
    
    definedWidth

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

        #parseInt is used here because for some reason, keys over 999 are not exactly considered as integers
        if parseInt(key) <= theWidth and parseInt(key) >= currentSelection
          currentSelection = parseInt key
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