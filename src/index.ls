path = require \path
rework = require \rework
reworkUrl = require \rework-plugin-url
through = require \through

urlConvert = (file, options) ->
  filePath = path.basename file
  cssContent = file.contents.toString!
  rework cssContent .use reworkUrl (url) ->
    unless url is /^data:image/
      return url

cssUrlConvert = (options) ->
  options ||= {}

  through.obj (file, enc, cb) ->
    cssContent = urlConvert file, options
    file.contents = new Buffer cssContent

    this.push file
    cb!

module.exports = cssUrlConvert
