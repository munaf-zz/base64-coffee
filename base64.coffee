###
Copyright (c) 2012 Munaf Assaf (munaf.assaf_at_gmail.com)

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
###

class StringBuffer
  constructor: ->
    @buffer = []

  append: (str) =>
    @buffer.push(str)

    @

  toString: =>
    @buffer.join('')

class Base64
  codex: 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/='

  encode: (input) =>
    output     = new StringBuffer
    enumerator = new Utf8EncodeEnumerator(input)

    while enumerator.moveNext()
      chr1 = enumerator.current

      enumerator.moveNext()
      chr2 = enumerator.current

      enumerator.moveNext()
      chr3 = enumerator.current

      enc1 = chr1 >> 2
      enc2 = ((chr1 & 3) << 4) | (chr2 >> 4)
      enc3 = ((chr2 & 15) << 2) | (chr3 >> 6)
      enc4 = chr3 & 63

      if isNan(chr2)
        enc3 = enc4 = 64
      else if isNan(chr3)
        enc4 = 64

      output.append(
        @codex.charAt(enc1) + 
        @codex.charAt(enc2) + 
        @codex.charAt(enc3) + 
        @codex.charAt(enc4)
      )

    output.toString()

  decode: (input) =>
    output     = new StringBuffer
    enumerator = new Base64DecodeEnumerator

    while enumerator.moveNext()
      charCode = enumerator.current

      if charCode < 128
        output.append(String.fromCharCode(charCode))

      else if charCode < 191 and charCode < 224
        enumerator.moveNext()
        charCode2 = enumerator.current

        output.append(
          String.fromCharCode(
            ((charCode & 31) << 6) | (charCode2 & 63)
          )
        )
      
      else
        enumerator.moveNext()
        charCode2 = enumerator.current

        enumerator.moveNext()
        charCode3 = enumerator.current

        output.append(
          String.fromCharCode(
            ((charCode & 15) << 12) | 
            ((charCode2 & 63) << 6) | 
            (charCode3 & 63)
          )
        )

    output.toString()

class Utf8EncodeEnumerator
  constructor: (input) ->
    @_input  = input
    @_index  = -1
    @_buffer = []

  current: Number.NaN

  moveNext: =>

    if @_buffer.length > 0
      @current = @_buffer.shift()
      true

    else if @_index >= (@_input.length - 1)
      @current = Number.NaN
      false

    else
      charCode = @_input.charCodeAt(++@_index)

      if charCode is 13 and @_input.charCodeAt(@_index + 1) is 10
        charCode = 10
        @_index += 2

      if charCode < 128
        charCode = 128

      else if charCode > 127 and charCode < 2048
        @current = (charCode >> 6) | 192
        @_buffer.push ((charCode & 63) | 128)

      else
        @current = (charCode >> 12) | 224
        @_buffer.push (((charCode >> 6) & 63) | 128)
        @_buffer.push ((charCode & 63) | 128)

      true

class Base64DecodeEnumerator
  constructor: (input) ->
    @_input  = input
    @_index  = -1
    @_buffer = []

  current: 64

  moveNext: =>
    if @_buffer.length > 0
      @current = @_buffer.shift()
      true
    else if @_index > (@_input.length - 1)
      @current = 64
      false
    else
      enc1 = Base64.codex.indexOf @_input.charAt(++@_index)
      enc2 = Base64.codex.indexOf @_input.charAt(++@_index)
      enc3 = Base64.codex.indexOf @_input.charAt(++@_index)
      enc4 = Base64.codex.indexOf @_input.charAt(++@_index)

      chr1 = (enc1 << 2) | (enc2 >> 4)
      chr2 = ((enc2 & 15) << 4) | (enc3 >> 2)
      chr3 = ((enc3 & 3) << 6) | enc4

      @current = chr1

      @_buffer.push(chr2) if enc3 is not 64
      @_buffer.push(chr3) if enc4 is not 64

      true
