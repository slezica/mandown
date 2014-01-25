system  = require 'system'
webpage = require 'webpage'
fs      = require 'fs'

URL     = system.args[1]
OUTDIR  = fs.workingDirectory
TIMEOUT = 50000


total_images_found = 0


onError = (info...) ->
  console.log 'Error', info...
  phantom.exit()

onFinished = (reason) ->
  console.log 'Finished', reason
  phantom.exit()

onImage = (img) ->
  console.log JSON.stringify img, null, 2


open = (url) ->
  page = webpage.create()

  page.resourceTimeout = TIMEOUT;

  page.open url, (status) ->
    return onError(url, status) if status isnt 'success'

    images = Array.prototype.slice.call page.evaluate ->
      outerHref = (e) ->
        switch e.tagName
          when 'A'    then e.href
          when 'BODY' then null
          else outerHref e.parentNode

      for img in document.querySelectorAll 'img'
        src   : img.src
        left  : img.getBoundingClientRect().left
        top   : img.getBoundingClientRect().top
        width : img.clientWidth
        height: img.clientHeight
        size  : img.clientWidth * img.clientHeight
        href  : outerHref img

    return onFinished 'no more images found' if images.length is 0

    largest = images.sort((x) -> x.size).pop()

    return onFinished 'images too small' if largest.size < 400 * 300

    total_images_found++
    onImage largest

    page.clipRect = largest
    page.render OUTDIR + '/' + total_images_found + '.png'
    page.close()

    return onFinished 'no link to follow' if not largest.href?
    open largest.href

open URL