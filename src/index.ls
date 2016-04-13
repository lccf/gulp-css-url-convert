path = require \path
rework = require \rework
reworkUrl = require \rework-plugin-url
through = require \through

/*
 * options
 *   root 根目录
 *   convertTo 路径
 *   convertType 转换到relative相对路径，absolute约对路径，network网络路径
 *   match 匹配的类型
 *   ignore 过滤
 *
 */

isDataUrl = (url) ->
  url is /^data:image/

isNetworkUrl = (url) ->
  url is /^http(?:s|):/

isRelative = (url) ->
  url isnt /^\./ or url isnt /^(http(?:s|):|data:|\/)/

urlConvert = (file, options) ->
  cssPath = path.dirname file
  cssContent = file.contents.toString!

  rework cssContent .use reworkUrl (url) ->
    if isDataUrl(url)
      return url

    if options.convertType is 'network'
      baseName = path.basename url
      urlPath = path.resolve cssPath, path.dirname url
      relativeUrlPath = path.relative root, urlPath

      return "#{options.convertTo}/#relativeUrlPath/#baseName"

cssUrlConvert = (options) ->
  options ||= {}

  through.obj (file, enc, cb) ->
    cssContent = urlConvert file, options
    file.contents = new Buffer cssContent

    this.push file
    cb!

module.exports = cssUrlConvert
