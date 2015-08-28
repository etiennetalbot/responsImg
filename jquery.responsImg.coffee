###
# responsImg jQuery Plugin
# Turn your <img> tags into responsive images with retina alternatives
# version 1.4.2, August 28th, 2015
# by Etienne Talbot
###

jQuery.responsImg = (element, settings) ->

  # default config values
  config =
    allowDownsize:  false    # If set to false, smaller images will never be loaded on resize or orientationchange
    elementQuery:   false    # False = window's width breakpoints. True = image's width breakpoints.
    delay:          200      # Delay between the window resize action and the image change (too low means more demanding for the browser)
    breakpoints:    null     # Object containing the different breakpoints for your page or element
    considerDevice: false    # If true, responsImg will pick the image size while considering the zoomed-out level of mobile devices

  jQuery.extend config, settings if settings

  theWindow     = jQuery window
  element       = jQuery element
  rimData       = {}
  elementType   = null
  resizeTimer   = null
  largestSize   = 0
  retinaDisplay = false

  # initialize the plugin
  init = ->
    elementType   = getElementType element
    retinaDisplay = true if window.devicePixelRatio >= 1.5

    if elementType == 'IMG'
      rimData[0] = new Array(element.attr 'src')
    else
      rimData[0] = new Array(getBackgroundImage element)

    theWindow.on 'resize.responsImg orientationchange.responsImg', resizeDetected

    determineSizes()

    return

  # Return the image path from a background-image style
  getBackgroundImage = (element) ->
    bg = element.css 'background-image'
    bg = bg.replace 'url(', ''
    bg = bg.replace ')', ''

    return bg

  # Return the jquery element type
  getElementType = (element) ->
    return jQuery(element).prop 'tagName'

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
          newKey = parseInt newKey, 10

        rimData[newKey] = value.replace(' ', '').split ','

    checkSizes()

    return

  # The browser resize or rotation has been detected
  resizeDetected = ->
    clearTimeout resizeTimer
    resizeTimer = setTimeout checkSizes, config.delay

    return

  # Define the actual width of the browser or the image
  #(wether it's in media query or element query mode)
  defineWidth = ->
    definedWidth = null

    if config.elementQuery is true
      definedWidth = element.width()

      if window.orientation? and config.considerDevice
        windowWidth       = theWindow.width()
        mobileWindowWidth = getMobileWindowWidth()

        definedWidth = Math.ceil(mobileWindowWidth * definedWidth / windowWidth)

    else
      if window.orientation? and config.considerDevice
        definedWidth = getMobileWindowWidth()

      else
        definedWidth = theWindow.width()

    definedWidth

  # Detect the width of the mobile window
  getMobileWindowWidth = ->
    if window.orientation is 0
      mobileWindowWidth = window.screen.width
    else
      mobileWindowWidth = window.screen.height

    if navigator.userAgent.indexOf('Android') >= 0 and window.devicePixelRatio
      mobileWindowWidth = mobileWindowWidth / window.devicePixelRatio;

    mobileWindowWidth

  # Determine which image size is appropriate for the current situation
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
        if parseInt(key, 10) <= theWidth and parseInt(key, 10) >= currentSelection
          currentSelection = parseInt key, 10
          newSrc           = rimData[currentSelection][0]

      if retinaDisplay is true and rimData[currentSelection][1]?
        newSrc = rimData[currentSelection][1]

      if elementType == 'IMG'
        setImage element, newSrc
      else
        setBackgroundImage element, newSrc

    return

  # Change the image's src
  setImage = (element, newSrc) ->
    oldSrc = element.attr 'src'

    if newSrc != oldSrc
      element.attr 'src', newSrc

    return

  # Change the background-image's src
  setBackgroundImage = (element, newSrc) ->
    oldSrc = getBackgroundImage element

    if newSrc != oldSrc
      element.css 'background-image', 'url('+newSrc+')'

    return

  # Punch it, Chewie!
  init()

  # Recheck now
  @recheck = ->
    checkSizes()

    return

  return this

jQuery.fn.responsImg = (options) ->
  @each( ->
    jQthis = jQuery this
    if jQthis.data('responsImg') is undefined
      plugin = new jQuery.responsImg this, options
      jQthis.data 'responsImg', plugin
    return
  )
