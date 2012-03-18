# Allows Hubot to find an awesome Mitch Hedburg quotes
#
# get mitch - This spits out one of the many awesome Mitch Hedburg quotes from wikiquote.org with filter
# get dirty mitch - This spits out one of the many awesome Mitch Hedburg quotes from wikiquote.org without potty mouth filter

# REQUIRED MODULES
# sudo npm install htmlparser
# sudo npm install soupselect
# sudo npm install jsdom
# sudo npm install underscore

Select     = require("soupselect").select
HtmlParser = require "htmlparser"
JsDom      = require "jsdom"
_          = require("underscore")

module.exports = (robot) ->

  robot.respond /get mitch$/i, (msg) ->
    msg
      .http("http://en.wikiquote.org/wiki/Archer_(TV_Series)")
      .header("User-Agent: Archerbot for Hubot (+https://github.com/github/hubot-scripts)")
      .get() (err, res, body) ->
        quotes = parse_html(body, "li")
        quote = get_quote msg, quotes

get_quote = (msg, quotes) ->

  nodeChildren = _.flatten childern_of_type(quotes[Math.floor(Math.random() * quotes.length)])
  quote = (textNode.data for textNode in nodeChildren).join ''

  msg.send quote

# Helpers
parse_html = (html, selector) ->
  handler = new HtmlParser.DefaultHandler((() ->), ignoreWhitespace: true)
  parser  = new HtmlParser.Parser handler

  parser.parseComplete html
  Select handler.dom, selector

childern_of_type = (root) ->
  return [root] if root?.type is "text"

  if root?.children?.length > 0
    return (childern_of_type(child) for child in root.children)

get_dom = (xml) ->
  body = JsDom.jsdom(xml)
  throw Error("No XML data returned.") if body.getElementsByTagName("FilterReturn")[0].childNodes.length == 0
  return body
