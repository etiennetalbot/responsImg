responsImg
==========

jQuery plugin written in CoffeeScript to make images load the smallest possible version of itself required for the current viewport size. See it as media queries for img tags.

Requirements
------------

This plugin requires jQuery.

Information
-----------
- Different image sources are set as data attributes in the `<img>` tag itself.
- You can specify @2x image sources. If specified, they will be used if the user has a retina display. Retina sizes must have a matching non-retina size in order to work. To set a retina image, add a comma and a space after the first source in a data atribute ("image.jpg, image@2x.jpg").
- Breakpoints are determined by the name of the data attribute. All of them must start with `data-responsimg` followed by the pixel value of the breakpoint (ex: `data-responsimg960`).
- I recommend using the smallest size as the default image (the actual `src` attribute), or else search engines won't see your image.

Parameters
----------

### allowDownsize
*(boolean) default: false* - By default, if a bigger image is already loaded, responsImg will not try to load a smaller one. To override this behavior, set to true.

### elementQuery
*(boolean) default: false* - By default, the sizes specified in the data attributes are related to the size of the viewport. If elementQuery is set to true, the sizes specified in the attributes will be related to the size of the image itself.

### delay
*(integer) default: 200* - Delay between the window resize action and the image change. Be careful, as a low number means a more demanding process for the browser.

Usage
-----
### JavaScript
	$('.responsive-image').responsImg({
	  allowDownsize: true,
	  elementQuery: true,
	  delay: 250
	});

### CoffeeScript
	$('.responsive-image').responsImg
	  allowDownsize: true
	  elementQuery: true
	  delay: 250

### HTML
	<img src="default-image.png" class="responsive-image"
	  data-responsimg320="image-320.png, image-320@2x.png"
      data-responsimg480="image-480.png"
      data-responsimg768="blue-car.png"
    />
    
In this example, the default image is `default-image.png`. This image is always loaded… make sure it's pretty small. You could always remove the `src` attribute completely if you really wanted to.

The image `image-320.png` is loaded and displayed if the window reaches a width of **320** pixels. If the screen used is retina, the image used will only be `image-320@2x.png`. If the window reaches **480** pixels wide, `image-480.png` will be loaded and displayed. Even if you have a retina display, this image will override the previous one. If the window reaches **768** pixels wide, `blue-car.png` will be loaded and displayed.

**Important** - *Please keep in mind that if the elementQuery is set to true, the breakpoints won't be defined by the width of the window but instead by the width of the image itself.*