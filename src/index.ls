path = require \path
rework = require \rework
reworkUrl = require \rework-plugin-url
through = require \through2

/*
 * options
 *   root 根目录
 *   path 路径
 *   type 转换到relative相对路径，absolute约对路径，network网络路径
 *   map 从一个类型映射到另一个类型
 *   ignore 过滤
 *
 */

isDataUrl = (url) ->
  url is /^data:image/

isNetworkUrl = (url) ->
  url is /^(?:http(?:s|):|)\/\//

isRelative = (url) ->
  url isnt /^\./ or url isnt /^(?:(?:http(?:s|):|)\/\/|data:|\/)/

isAbsolute = (url) ->
  url is /^\//

isIgnore = (url, rules) ->
  unless rules
    return false

  unless Array.isArray(rules)
    rules = [].concat rules

  for rule, key in rules
    if typeof rule is 'string'
      return false if url is rule

    if typeof rule is 'object' and rule isnt null and rule.constructor is RegExp
      return false if rule.match(url) isnt null

# 根据映射表替换url中的部份内容
urlMap = (url, maps) ->
  unless Array.isArray maps
    maps = [].concat maps

  for map, key in maps
    mapMatch = new RegExp "^#key"
    if reg.text(url) isnt null
      return url.replace mapMatch, map

urlConvert = (file, options) ->
  cssPath = path.dirname file.path
  cssContent = file.contents.toString!
  replaceCount = 0

  urlReplace = (url) ->
    # 跳过data路径
    return url if isDataUrl url
    # 过滤
    return url if isIgnore(url, options.ignore)

    if options.map
      url = urlMap url, options.map

    # 如果目标路径是网络路标
    if options.type is \network or isNetworkUrl options.path
      return url if isNetworkUrl url

      options.path = options.path.replace /\/$/, ''

      # 相对路径
      if isRelative url
        baseName = path.basename url
        urlPath = path.resolve cssPath, path.dirname url
        relativeUrlPath = path.relative options.root, urlPath

        replaceCount += 1
        "#{options.path}/#relativeUrlPath/#baseName"
      # 绝对路径
      else if isAbsolute url
        replaceCount += 1
        url.replace /^\//, options.path

    # 如果目标路径是绝对路径
    else if options.type is \absolute or isAbsolute options.path
      return url if isAbsolute url or isNetworkUrl url

      # 相对路径
      if isRelative url
        baseName = path.basename url
        urlPath = path.resolve cssPath, path.dirname url
        relativeUrlPath = path.relative options.root, urlPath

        replaceCount += 1
        "#{options.path}#relativeUrlPath/#baseName"

    else
      url

  if options.useRework
    try
      newCssContent = rework cssContent .use reworkUrl urlReplace

      .toString!

    catch e
      console.error "css file: #{file.path}"
      console.error e.stack
      throw new Error "rework error"
  else
    try
      newCssContent = cssContent.replace /(url\(\s*['"]?)([^'"\)]*)(['"]?\s*\))/g, (all, start, url, end)->
        if url.length
          url = urlReplace url

        "#{start}#{url}#{end}"

  if replaceCount > 0 then newCssContent else false

cssUrlConvert = (options) ->
  options ||= {}

  through.obj (file, enc, cb) ->
    cssContent = urlConvert file, options
    if cssContent
      file.contents = new Buffer cssContent

    this.push file
    cb!

module.exports = cssUrlConvert
