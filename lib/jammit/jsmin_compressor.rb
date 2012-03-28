#--
# jsmin.rb - Ruby implementation of Douglas Crockford's JSMin.
#
# This is a port of jsmin.c, and is distributed under the same terms, which are
# as follows:
#
# Copyright (c) 2002 Douglas Crockford  (www.crockford.com)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# The Software shall be used for Good, not Evil.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#++

require 'strscan'

# = JSMin
#
# Ruby implementation of Douglas Crockford's JavaScript minifier, JSMin.
#
# *Author*::    Ryan Grove (mailto:ryan@wonko.com)
# *Version*::   1.0.1 (2008-11-10)
# *Copyright*:: Copyright (c) 2008 Ryan Grove. All rights reserved.
# *Website*::   http://github.com/rgrove/jsmin
#
# == Example
#
#   require 'rubygems'
#   require 'jsmin'
#
#   File.open('example.js', 'r') {|file| puts JSMin.minify(file) }
#
module JSMin
  CHR_APOS       = "'".freeze
  CHR_ASTERISK   = '*'.freeze
  CHR_BACKSLASH  = '\\'.freeze
  CHR_CR         = "\r".freeze
  CHR_FRONTSLASH = '/'.freeze
  CHR_LF         = "\n".freeze
  CHR_QUOTE      = '"'.freeze
  CHR_SPACE      = ' '.freeze

  ORD_LF    = ?\n
  ORD_SPACE = ?\ 
  ORD_TILDE = ?~

  class ParseError < RuntimeError
    attr_accessor :source, :line
    def initialize(err, source, line)
      @source = source,
      @line = line
      super "JSMin Parse Error: #{err} at line #{line} of #{source}"
    end
  end

  class << self
    def raise(err)
      super ParseError.new(err, @source, @line)
    end

    # Reads JavaScript from _input_ (which can be a String or an IO object) and
    # returns a String containing minified JS.
    def minify(input)
      @js = StringScanner.new(input.is_a?(IO) ? input.read : input.to_s)
      @source = input.is_a?(IO) ? input.inspect : input.to_s[0..100]
      @line = 1

      @a         = "\n"
      @b         = nil
      @lookahead = nil
      @output    = ''

      action_get

      while !@a.nil? do
        case @a
        when CHR_SPACE
          if alphanum?(@b)
            action_output
          else
            action_copy
          end

        when CHR_LF
          if @b == CHR_SPACE
            action_get
          elsif @b =~ /[{\[\(+-]/
            action_output
          else
            if alphanum?(@b)
              action_output
            else
              action_copy
            end
          end

        else
          if @b == CHR_SPACE
            if alphanum?(@a)
              action_output
            else
              action_get
            end
          elsif @b == CHR_LF
            if @a =~ /[}\]\)\\"+-]/
              action_output
            else
              if alphanum?(@a)
                action_output
              else
                action_get
              end
            end
          else
            action_output
          end
        end
      end

      @output
    end

    private

    # Corresponds to action(1) in jsmin.c.
    def action_output
      @output << @a
      action_copy
    end

    # Corresponds to action(2) in jsmin.c.
    def action_copy
      @a = @b

      if @a == CHR_APOS || @a == CHR_QUOTE
        loop do
          @output << @a
          @a = get

          break if @a == @b

          if @a[0] <= ORD_LF
            raise "unterminated string literal: #{@a.inspect}"
          end

          if @a == CHR_BACKSLASH
            @output << @a
            @a = get

            if @a[0] <= ORD_LF
              raise "unterminated string literal: #{@a.inspect}"
            end
          end
        end
      end

      action_get
    end

    # Corresponds to action(3) in jsmin.c.
    def action_get
      @b = nextchar

      if @b == CHR_FRONTSLASH && (@a == CHR_LF || @a =~ /[\(,=:\[!&|?{};]/)
        @output << @a
        @output << @b

        loop do
          @a = get

           # Inside a regex [...] set, which MAY contain a '/' itself.
           # Example:
           #   mootools Form.Validator near line 460:
           #     return Form.Validator.getValidator('IsEmpty').test(element) || (/^(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]\.?){0,63}[a-z0-9!#$%&'*+/=?^_`{|}~-]@(?:(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)*[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\])$/i).test(element.get('value'));
          if @a == '['
            loop do
              @output << @a
              @a = get
              case @a
                when ']' then break
                when CHR_BACKSLASH then
                  @output << @a
                  @a = get
                when @a[0] <= ORD_LF
                  raise "JSMin parse error: unterminated regular expression " +
                      "literal: #{@a}"
              end
            end
          elsif @a == CHR_FRONTSLASH
            break
          elsif @a == CHR_BACKSLASH
            @output << @a
            @a = get
          elsif @a[0] <= ORD_LF
            raise "unterminated regular expression : #{@a.inspect}"
          end

          @output << @a
        end

        @b = nextchar
      end
    end

    # Returns true if +c+ is a letter, digit, underscore, dollar sign,
    # backslash, or non-ASCII character.
    def alphanum?(c)
      c.is_a?(String) && !c.empty? && (c[0] > ORD_TILDE || c =~ /[0-9a-z_$\\]/i)
    end

    # Returns the next character from the input. If the character is a control
    # character, it will be translated to a space or linefeed.
    def get
      if @lookahead
        c = @lookahead
        @lookahead = nil
      else
        c = @js.getch
        if c == CHR_LF || c == CHR_CR
          @line += 1
          return CHR_LF
        end
        return ' ' unless c.nil? || c[0] >= ORD_SPACE
      end
      c
    end

    # Gets the next character, excluding comments.
    def nextchar
      c = get
      return c unless c == CHR_FRONTSLASH

      case peek
      when CHR_FRONTSLASH
        loop do
          c = get
          return c if c[0] <= ORD_LF
        end

      when CHR_ASTERISK
        get
        loop do
          case get
          when CHR_ASTERISK
            if peek == CHR_FRONTSLASH
              get
              return ' '
            end

          when nil
            raise 'unterminated comment'
          end
        end

      else
        return c
      end
    end

    # Gets the next character without getting it.
    def peek
      @lookahead = get
    end
  end
end


# Wraps CSSMin compressor to use the same API as the rest of
# Jammit's compressors.
class Jammit::JsminCompressor
  def initialize(options = {})
  end

  def compress(js)
    JSMin.minify(js)
  end
end
