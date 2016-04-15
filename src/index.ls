path = require \path
rework = require \rework
reworkUrl = require \rework-plugin-url
through = require \through2

/*
 * options
 *   root 根目录
 *   path 路径
 *   type 转换到relative相对路径，absolute约对路径，network网络路径
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

isAbsolute = (url) ->
  url is /^\//

checkIgnore = (url, rules) ->
  unless rules
    return false

urlConvert = (file, options) ->
  cssPath = path.dirname file.path
  cssContent = file.contents.toString!

  rework cssContent .use reworkUrl (url) ->
    # 跳过data路径
    return url if isDataUrl url
    # 过滤
    return url if !isIgnore(url, options.ignore)

    # 如果目标路径是网络路标
    if options.type is \network or isNetworkUrl options.path
      return url if isNetworkUrl url

      options.path = options.path.replace /\/$/, ''

      # 相对路径
      if isRelative url
        baseName = path.basename url
        urlPath = path.resolve cssPath, path.dirname url
        relativeUrlPath = path.relative options.root, urlPath

        "#{options.path}/#relativeUrlPath/#baseName"
      # 绝对路径
      else if isAbsolute url
        url.replace /^\//, options.path

    # 如果目标路径是绝对路径
    else if options.type is \absolute or isAbsolute options.path
      return url if isAbsolute url or isNetworkUrl url

      # 相对路径
      if isRelative url
        baseName = path.basename url
        urlPath = path.resolve cssPath, path.dirname url
        relativeUrlPath = path.relative options.root, urlPath

        "#{options.path}#relativeUrlPath/#baseName"

    else
      url

  .toString!

cssUrlConvert = (options) ->
  options ||= {}

  through.obj (file, enc, cb) ->
    cssContent = urlConvert file, options
    file.contents = new Buffer cssContent

    this.push file
    cb!

module.exports = cssUrlConvert
