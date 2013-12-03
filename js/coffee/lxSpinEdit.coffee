###
  Class for spinEdit control
  http://lexey111.com
  (c) lexey111, 2013

  v.1.3

  Requires: jquery 1.8+

  Usage example:
        var cntr_angle = new LxSpinEdit({
            container: '#bcoc_regular', <-- container's selector, place to embed
            id: 'cntr_angle',           <-- ID of control, required, has to be unique
            title: 'Rotate',            <-- left caption (title)
            slider: true,               <-- use slider, true|false
            min: -359,                  <-- minimum value
            max: 359,                   <-- maximum
            step: 1,                    <-- value changing step for buttons "+" and "-" and mouse wheel
            value: 0,                   <-- initial value
            measure: '&deg;'            <-- right caption (measure units)
        });

  Full set of options and default values you could find in the constructor, @properties object
###
# TODO: custom button (...)
# TODO: popup hint with target value on mouse over trackbar

class LxSpinEdit
  ###*
    Check is given value is real number
    @param n
    @returns {boolean}
  ###
  isNumber: (n) ->
    !isNaN(parseFloat(n)) && isFinite(n)

  ###*
    ITEM CONSTRUCTOR
  ###
  constructor: (options) ->
    # cached items
    @id = '' # id of control
    @control = null # Main div .bco_control
    @title = null # Title text .bco_title
    @measure = null # Measurement units text .bco_measurement
    @input = null # Input .bco_input
    @up_button = null # Up and Down buttons
    @down_button = null
    @percentage_bar = null # progress bar for percentage

    @diapazone = 0 # Max - Min

    @slider = null # Slider control (if any)
    @slider_track_length = -1
    @slider_track_offset = -1
    @slider_handle = null
    @slider_trackbar = null
    @slider_min = null # Min text for slider
    @slider_max = null # Max text for slider
    @slider_current = null # Current value text for slider
    @in_drag = false

    # settings
    @slider_mode = false

    @dp = 0 # FixedPoint DepTh (position)
    @value = null # Current value

    @properties = $.extend({
      id: ''                    # required, controls id
      container: 'body'         # place where add edit
      title: ''                 # title before control
      hide_title: false         # hide the title
      enabled: true             # true|false
      min: 0                    # min value (for spinedit)
      max: 0                    # max value (for spinedit)
      value: 0                  # current value
      fixed: false              # use integer values if true
      point_pos: 1              # fixed point position (accuracy), default 1 for floats and 0 for fixed
      step: 0                   # step (for spinedit)
      measure: ''               # measurement unit
      always_use_wheel: false   # when true, mouse wheel will interacts with control always (otherwise - only if control is focused)
      slider: false             # use slider?
      live_slider: false        # call the callback function every time while dragging slider handle (or only when drag ends)
      clear_after: false        # add "clearfix" div after control
      percent_bar: false        # use or not percentage bar at all
      percent_full_size: false  # use all the input background as percentage bar
      hide_buttons: false       # hide or not plus/minus buttons while not focused
      callback_change: null     # callback function (after change)
      callback_focus: null      # callback on focus input element
    }, options)

    @init()
    return this

  ###*
    Initialize function
  ###
  init: ->
    # Initial check
    throw "ID is empty!" if @properties.id is ''
    throw "Container not found!" if not $(@properties.container).length
    throw "ID [" + @properties.id + "] already exists!" if $(@properties.container).find('#' + @properties.id).length

    @id = @properties.id
    # wrapper
    s = '<div id="' + @properties.id + '" class="bco_control ';
    s += ' bco_full_size' if @properties.percent_bar and @properties.percent_full_size
    s += ' disabled' if not @properties.enabled
    s += ' bco_no_title' if @properties.hide_title is true
    s += ' bco_hide_buttons' if @properties.hide_buttons is true
    s += '">'

    @slider_mode = @properties.slider
    @use_percentage = @properties.percent_bar # and @slider_mode
    @diapazone = @properties.max - @properties.min

    # Standard spin edit
    s += '<input class="bco_input" type="text" '
    s += 'readonly="readonly" ' unless @properties.enabled
    s += 'value="' + @properties.value + '"/>'

    # Add title that is before edit - it is positioned absolutely
    # but has to be added AFTER in the layout to have correct highlight
    s += '<span class="bco_title noselect">' + @properties.title + '</span>' unless @properties.hide_title

    if @use_percentage
      s += '<div class="bco_percentage'
      s += '"><span></span></div>'


    s += '<div class="bco_buttons">'
    s += '<div class="bco_btn bco_up noselect" tabindex="-1">+</div>'
    s += '<div class="bco_btn bco_down noselect" tabindex="-1">&dash;</div>'
    s += '</div>' # bco_buttons

    s += '<div class="bco_focus_rect">' # focus rectangle
    s += '</div>' # focus rectangle

    # Add measurement units to the end
    s += '<span class="bco_measurement noselect">' + @properties.measure + '</span>'

    if @slider_mode
      s += '<div class="bco_slider_container">'
      s += '<div class="bco_slider_trackbar" tabindex="-1"></div>'
      s += '<div class="bco_slider_handle" tabindex="-1"><b></b></div>'
      s += '<div class="bco_arrow_up"></div>'
      # Slider
      s += '<div class="bco_slider_slider">'
      s += '</div>'
      s += '<div class="bcos_min"></div>'
      s += '<div class="bcos_cur"><span></span></div>'
      s += '<div class="bcos_max"></div>'
      s += '</div>'

    s += '</div>' # wrapper

    s += '<div class="bco_clearfix"></div>' if @properties.clear_after is true

    @dp = @properties.point_pos
    if @properties.fixed then @dp = 0

    $(@properties.container).append(s)

    @control = $(@properties.container).find('#' + @properties.id)
    if not $(@control).length then throw "Control not found!"

    @title = $(@control).find('.bco_title')
    @measure = $(@control).find('.bco_measurement')

    @up_button = $(@control).find('.bco_up')
    @down_button = $(@control).find('.bco_down')

    @slider_current = $(@control).find('.bcos_cur')
    @input = $(@control).find('.bco_input')

    if not @input? then throw "Input not found!"

    @percentage_bar = $(@control).find('.bco_percentage span')

    @_assignHandlers()
    # Finishing init
    @value = @properties.value

    @_initSliderTexts()
    @_actualizeSlider()

    this #return this

  ###*
    Set handlers for various events
  ###
  _assignHandlers: ->
    # firefox|IE way
    mousewheelevt = if (/Firefox/i.test(navigator.userAgent)) then "DOMMouseScroll" else "mousewheel"

    element = this

    if @slider_mode
      @slider = $(@control).find('.bco_slider_container')

      @slider_min = $(@control).find('.bcos_min')
      @slider_max = $(@control).find('.bcos_max')

      @slider_handle = $(@control).find('.bco_slider_handle')
      @slider_trackbar = $(@control).find('.bco_slider_trackbar')

      @slider_track_length = $(@slider_trackbar).width()
      @slider_track_offset = parseInt($(@slider_trackbar).css 'left')

      # To don't close slider on click (prevent focus lost)
      $(@slider).mousedown (e) ->
        e.preventDefault()
        false #return

      # Mouse wheel over slider
      $(@slider).get(0).addEventListener mousewheelevt, (e) ->
        e.preventDefault();
        if element.in_drag is true then return false

        up = true
        if e.wheelDelta and e.wheelDelta < 0
          up = false
        else
          if e.detail and e.detail > 0 then up = false

        if up
          element.increase(element.properties.step)
        else
          element.decrease(element.properties.step)

        false #return
      , false

      # Click on slider's trackbar
      $(@slider_trackbar).mousedown (e) ->
        e.preventDefault()
        if e.which != 1 then return false # not left mouse button was pressed
        if element.in_drag is true then return false

        #firefox again
        mouse_x = (e.offsetX || e.clientX - $(e.target).offset().left)

        percent = (mouse_x / element.slider_track_length)

        element.setValue(element.properties.min + element.diapazone * percent)
        # call change routine
        element._callChangeCallback()

        false #return

      # begin dragging
      $(@slider_handle).mousedown (e) ->
        e.preventDefault()
        if e.which != 1 then return false # not left mouse button was pressed
        if element.in_drag is false
          element.stored_x = parseInt($(element.slider_handle).css 'left')
          element.stored_cx = e.pageX
          element.in_drag = true

        false #return

      # while dragging...
      $(@slider).mousemove (e) ->
        #e.preventDefault()
        if element.in_drag is true

          delta = element.stored_cx - e.clientX
          new_position = element.stored_x - delta

          if new_position < element.slider_track_offset
            new_position = element.slider_track_offset

          if new_position > element.slider_track_offset + element.slider_track_length
            new_position = element.slider_track_offset + element.slider_track_length

          # recalc percentage...
          percent = ((new_position - element.slider_track_offset) / element.slider_track_length)
          element.setValue(element.properties.min + element.diapazone * percent)

          if element.properties.live_slider is true
            element._callChangeCallback()

        true #return

      # end dragging
      $(document).mouseup (e) ->
        e.preventDefault()
        if element.in_drag is true
          element.in_drag = false
          # call change routine
          element._callChangeCallback()

        false #return

    # Up button
    $(@up_button).click (e) ->
      e.preventDefault()
      if e.which != 1 then return false # not left mouse button was pressed
      if $(element.control).hasClass "disabled" then return false

      element.increase(element.properties.step * if e.shiftKey then 10 else 1)

      false#return
    .mousedown ->
        false # prevent input to lost focus

    # Down button
    $(@down_button).click (e) ->
      e.preventDefault()
      if e.which != 1 then return false # not left mouse button was pressed

      if $(element.control).hasClass "disabled" then return false

      element.decrease(element.properties.step * if e.shiftKey then 10 else 1)

      false#return
    .mousedown ->
        false # prevent input to lost focus

    # Click on the title
    $(@title).first().click (e) ->
      if $(element.control).hasClass "disabled" then return false

      e.preventDefault()
      $(element.input).focus()
      false #return

    # Input changed
    $(@input).change ->
      element.value = parseFloat $(element.input).val()
      element._checkValue()

      # set slider value according to input value
      element._actualizeSlider()
      # call change routine
      element._callChangeCallback()

      false #return

    # Keyboard arrows inside input
    $(@input).get(0).addEventListener 'keyup', (e) ->
      if $(element.control).hasClass "disabled" then return false
      # 38 - up, 40 - down
      if e.which == 38 and e.ctrlKey
        element.increase(element.properties.step * if e.shiftKey then 10 else 1)

      if e.which == 40 and e.ctrlKey
        element.decrease(element.properties.step * if e.shiftKey then 10 else 1)

      false #return
    , true

    # When input gets focus
    $(@input).get(0).addEventListener 'focus', () ->
      if typeof element.properties.callback_focus == 'function'
        element._callFocusCallback()
      false
    , false

    # Mouse wheel over input
    $(@input).get(0).addEventListener mousewheelevt, (e) ->
      if $(element.control).hasClass "disabled" then return false

      if not element.properties.always_use_wheel
        if not $(element.input).is(':focus')
          return false

      e.preventDefault()
      up = true
      if e.wheelDelta and e.wheelDelta < 0
        up = false
      else
        if e.detail and e.detail > 0 then up = false

      if up
        element.increase(element.properties.step)
      else
        element.decrease(element.properties.step)

      false #return
    , false

  ###*
    Increase value to delta
  ###
  increase: (delta) ->
    delta = @properties.step unless delta
    @setValue(parseFloat(@value) + parseFloat(delta))
    @_callChangeCallback()

  ###*
    Decrease value to delta
  ###
  decrease: (delta) ->
    delta = @properties.step unless delta
    @setValue(parseFloat(@value) - parseFloat(delta))
    @_callChangeCallback()

  ###*
    Check is current value valid (min <= value <= max)
    and blink error if no
  ###
  _checkValue: ->
    if not @isNumber(@value) or @value < @properties.min or @value > @properties.max
      $(@input).addClass('error')

      if not @isNumber(@value) or @value < @properties.min
        @value = @properties.min

      if @value > @properties.max then @value = @properties.max

      element = this
      # blink error
      setTimeout ->
        $(element.input).removeClass 'error'
        false
      , 200
    else
      $(@input).removeClass 'error'

    @value = parseFloat(@value).toFixed @dp
    $(@input).val @value

  ###*
    Make callback on change value
  ###
  _callChangeCallback: ->
    if @properties.callback_change? and typeof @properties.callback_change is 'function'
      @properties.callback_change.call(this, @value)

  ###*
    Make callback on focus input
  ###
  _callFocusCallback: ->
    if @properties.callback_focus? and typeof @properties.callback_focus is 'function'
      @properties.callback_focus.call(this)

  ###*
    Actualize slider position
  ###
  _actualizeSlider: ->
    # set slider value according to input value
    pc = 0
    if @diapazone != 0
      pc = ((@value - @properties.min) / @diapazone) * 100

    handle_left = (parseFloat(@slider_track_offset) + parseFloat(@slider_track_length * pc / 100)).toFixed(0) + 'px'

    $(@slider_handle).css
      left: handle_left
      top: 12

    # set current value as well
    $(@slider_current).html @value + if typeof @properties.measure != 'undefined' then '<span>' + @properties.measure + '</span>'

    # set percent bar position if any
    $(@percentage_bar).css({
      width: Math.round(pc) + '%'
    })

  ###*
    Set the current value and update control state
    @param {number|string} value
  ###
  setValue: (value) ->
    # value
    @value = parseFloat(value).toFixed(@dp)
    @_checkValue()
    @_actualizeSlider()

    true #return

  ###*
    Set the title of controls
    @param {string} title
  ###
  setTitle: (title) ->
    @properties.title = title
    $(@title).html title

  ###*
    Set min-max-current values to the slider
  ###
  _initSliderTexts: ->
    $(@slider_min).html @properties.min
    $(@slider_max).html @properties.max
    $(@slider_current).html @value + if typeof @properties.measure != 'undefined' then '<span>' + @properties.measure + '</span>'

  ###*
    Set the measurement unit of controls
    @param {string} title
  ###
  setMeasurement: (measurement) ->
    @properties.measure = measurement
    $(@measure).html measurement

    @_actualizeSlider()

  ###*
    Set Minimum value
    @param {string} title
  ###
  setMin: (min) ->
    @properties.min = parseFloat(min)
    @diapazone = @properties.max - @properties.min

    @_initSliderTexts()
    @_actualizeSlider()

  ###*
    Set Maximum value
    @param {string} title
  ###
  setMax: (max) ->
    @properties.max = parseFloat(max)
    @diapazone = @properties.max - @properties.min

    @_initSliderTexts()
    @_actualizeSlider()

  ###*
    Getters
  ###
  getValue: ->
    @value

  getTitle: ->
    @properties.title

  getMin: ->
    @properties.min

  getMax: ->
    @properties.max

  getMeasurement: ->
    @properties.measure

  ###*
    Hide control
  ###
  hide: ->
    $(@control).hide()

  ###*
    Show control
  ###
  show: ->
    $(@control).show()

  ###*
    Get disabled state
  ###
  isControlDisabled: ->
    $(@control).hasClass 'disabled'

  ###*
      Enable control
  ###
  enable: ->
    $(@control).removeClass 'disabled'
    $(@input).removeAttr 'readonly'
  ###*
      Disable control
  ###
  disable: ->
    $(@control).addClass 'disabled'
    $(@input).attr 'readonly', 'readonly'