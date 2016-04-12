path = require \path
rework = require \rework
reworkUrl = require \rework-plugin-url
through = require \through

/*
 * options
 *   root 根目录
 *   convertTo 转换到relative相对路径，absolute约对路径，http网络路径
 *   match 匹配的类型
 *   ignore 过滤
 *
 */
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
