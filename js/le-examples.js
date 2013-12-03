/**
 * Created by lexey on 11/6/13.
 */

var object_controls = {};

/**
 * Miniclass to very simple logging to the special div
 * @type {{item: null, console_max_length: number, console_header: string, init: Function, log: Function}}
 */
var pseudo_console = {
    item: null,
    container: 'pseudo-console',
    console_max_length: 20, // maximum amount of <p> inside console
    console_header: '<h1>Console</h1>',
    console_greeting: '<p class="console_greeting">Try to change value.</p>',
    /**
     * init function
     */
    init: function () {
        this.item = $('#' + this.container);
        if (!this.item.length) throw "Can't find console container!";

        $(this.item).html(this.console_header + this.console_greeting);
    },
    /**
     * Log name-value pair
     * @param name
     * @param value
     * @param mesurement_unit
     */
    log: function (name, value, mesurement_unit) {
        if ($(this.item).find('p.console_greeting').length){
            // First entry, remove greetings
            $(this.item).html(this.console_header);
        }
        if ($(this.item).find('p').length >= this.console_max_length) {
            // clear long console or init empty one
            $(this.item).html(this.console_header);
        }
        var i = $(this.item).find('p').length + 1;

        if (typeof value == 'undefined') {
            $(this.item).append('<p><b>' + i + '.</b> ' + name + '</p>'); // one string
            return;
        }
        $(this.item).append('<p><b>' + i + '.</b> ' + name + ' = <span>' + value + '</span>' + (mesurement_unit ? mesurement_unit : '') + '</p>');
    }
};

/**
 * Callback on change labelledEdit
 * Appends item id and value to the console
 * @param value
 */
function onDataChanged(value) {
    // do nothing, append to console
    // LxSpinEdit control is passed here as 'this' parameter
    pseudo_console.log(this.id, value, this.properties.measure);
}

/**
 * Make properties list of selected control and show them
 * this - control that has focus
 */
function showInitialProperties() {
    // show control properties
    var s = '<p>{</p>';
    for (var key in this.properties) {
        s += '<p class="cpl-name-value">';

        s += key + ': <span>';
        if (typeof this.properties[key] == 'string') {
            s += '"' + this.properties[key].toString() + '"';
        } else if (typeof this.properties[key] == 'function') {
            //s += 'function(){...}';
            s += this.properties[key].name + '()';
        } else if (typeof this.properties[key] == 'object') {
            s += '"#' + $(this.properties[key]).attr('id') + '"';
        } else {
            s += this.properties[key].toString()
        }
        s += '</span>';
        s += ',</p>';
    }
    s += '<p>}</p>'
    $('#cntr-properties-list').html(s);
}

/**
 * Switch disabled controls on/off
 */
function toggle_disabled() {
    if (object_controls.cntr_no_title_8.isControlDisabled()) {
        // enable all three
        object_controls.cntr_no_title_8.enable();
        object_controls.cntr_no_title_9.enable();
        object_controls.cntr_no_title_10.enable();

        pseudo_console.log('Set state: <span>Enabled</span>');
        $('#toggle_link').html('Disable controls');

    } else {
        // disable all three
        object_controls.cntr_no_title_8.disable();
        object_controls.cntr_no_title_9.disable();
        object_controls.cntr_no_title_10.disable();

        pseudo_console.log('Set state: <span>Disabled</span>');
        $('#toggle_link').html('Enable controls');
    }
}

/**
 * Change parameters of control #7
 */
var titles = ['Hue', 'Saturation', 'Brightness', 'Contrast', 'Depth', 'Volume', 'Capacity', 'Velocity', 'Width', 'Height', 'Weight'];
var measures = ['', '&deg;', 'mm', 'm', 'g', 'kg', 'oz', 'USD', 'EUR', '%'];

function change_value_title_mu() {
    var i = parseInt(Math.random() * titles.length);
    object_controls.cntr_no_title_7.setTitle(titles[i]);

    var min = parseInt(Math.random() * 50);
    var max = parseInt(Math.random() * 200 + 52);
    var val = parseInt(min + Math.random() * (max - min));
    if (val > max) val = max;

    object_controls.cntr_no_title_7.setMin(min);
    object_controls.cntr_no_title_7.setMax(max);
    object_controls.cntr_no_title_7.setValue(val);

    i = parseInt(Math.random() * measures.length);
    object_controls.cntr_no_title_7.setMeasurement(measures[i]);

    pseudo_console.log('Changed: <span>Title [' + object_controls.cntr_no_title_7.getTitle() + ']</span>');
    pseudo_console.log('Changed: <span>Min [' + object_controls.cntr_no_title_7.getMin() + ']</span>');
    pseudo_console.log('Changed: <span>Max [' + object_controls.cntr_no_title_7.getMax() + ']</span>');
    pseudo_console.log('Changed: <span>Value [' + object_controls.cntr_no_title_7.getValue() + ']</span>');

    pseudo_console.log('Changed: <span>Measure units [' + object_controls.cntr_no_title_7.getMeasurement() + ']</span>');
}

// onDocumentReady
$(function () {
    // init pseudo console
    pseudo_console.init();

    var item_container = $('#selectors_container1');

    $(item_container).append('<h2>Various standard controls</h2>');

    object_controls.cntr_x = new LxSpinEdit({
        container: item_container,
        id: 'cntr_x',
        title: 'X',
        slider: false,
        min: -200,
        max: 200,
        step: 0.5,
        value: 10,
        point_pos: 2,
        measure: 'mm',
        callback_change: onDataChanged,
        callback_focus: showInitialProperties
    });
    object_controls.cntr_y = new LxSpinEdit({
        container: item_container,
        id: 'cntr_y',
        title: 'Y',
        slider: false,
        fixed: true,
        always_use_wheel: true,
        min: -200,
        max: 200,
        step: 5,
        value: 10,
        measure: 'mm',
        callback_change: onDataChanged,
        callback_focus: showInitialProperties
    });
    object_controls.cntr_x1 = new LxSpinEdit({
        container: item_container,
        id: 'cntr_x1',
        title: 'X<sub>1</sub>',
        slider: false,
        min: -200,
        max: 200,
        step: 0.5,
        value: 10,
        measure: 'mm',
        callback_change: onDataChanged,
        callback_focus: showInitialProperties
    });
    object_controls.cntr_y1 = new LxSpinEdit({
        container: item_container,
        id: 'cntr_y1',
        title: 'Y<sub>1</sub>',
        slider: false,
        min: -200,
        max: 200,
        step: 0.5,
        value: 10,
        measure: 'mm',
        callback_change: onDataChanged,
        callback_focus: showInitialProperties
    });
    object_controls.cntr_thickness = new LxSpinEdit({
        container: item_container,
        id: 'cntr_thickness',
        title: 'Thickness',
        slider: true,
        fixed: true,
        always_use_wheel: true,
        min: 1,
        max: 50,
        step: 1,
        value: 1,
        measure: 'mm',
        callback_change: onDataChanged,
        callback_focus: showInitialProperties
    });
    object_controls.cntr_font_size = new LxSpinEdit({
        container: item_container,
        id: 'cntr_font_size',
        title: 'Font size',
        slider: true,
        min: 3,
        max: 80,
        step: .1,
        value: 5,
        measure: 'pt',
        percent_bar: true,
        callback_change: onDataChanged,
        callback_focus: showInitialProperties
    });
    object_controls.cntr_width = new LxSpinEdit({
        container: item_container,
        id: 'cntr_width',
        title: 'Width',
        slider: false,
        min: 0.5,
        max: 200,
        step: 0.5,
        value: 10,
        measure: 'mm',
        callback_change: onDataChanged,
        callback_focus: showInitialProperties
    });
    object_controls.cntr_height = new LxSpinEdit({
        container: item_container,
        id: 'cntr_height',
        title: 'Height',
        slider: false,
        fixed: true,
        always_use_wheel: true,
        min: 5,
        max: 200,
        step: 1,
        value: 10,
        measure: 'mm',
        callback_change: onDataChanged,
        callback_focus: showInitialProperties
    });
    object_controls.cntr_points_count = new LxSpinEdit({
        container: item_container,
        id: 'cntr_points_count',
        title: 'Points',
        slider: true,
        fixed: true,
        min: 3,
        max: 128,
        step: 1,
        value: 87,
        percent_bar: true,
        percent_full_size: true,
        measure: '',
        callback_change: onDataChanged,
        callback_focus: showInitialProperties
    });
    object_controls.cntr_depth = new LxSpinEdit({
        container: item_container,
        id: 'cntr_depth',
        title: 'Depth',
        slider: true,
        min: 1,
        max: 100,
        step: 1,
        value: 5,
        measure: '%',
        percent_bar: true,
        callback_change: onDataChanged,
        callback_focus: showInitialProperties
    });

    object_controls.cntr_opacity = new LxSpinEdit({
        container: item_container,
        id: 'cntr_opacity',
        title: 'Opacity',
        fixed: true,
        slider: true,
        always_use_wheel: true,
        min: 1,
        max: 100,
        step: 1,
        value: 100,
        measure: '%',
        percent_bar: true,
        callback_change: onDataChanged,
        callback_focus: showInitialProperties
    });
    object_controls.cntr_angle = new LxSpinEdit({
        container: item_container,
        id: 'cntr_angle',
        title: 'Angle',
        slider: false,
        fixed: false,
        min: -359,
        max: 359,
        step: 0.1,
        value: 0,
        measure: '&deg;',
        callback_change: onDataChanged,
        callback_focus: showInitialProperties
    });
    object_controls.cntr_border_size = new LxSpinEdit({
        container: item_container,
        id: 'cntr_border_size',
        title: 'Border size',
        slider: false,
        min: 0,
        max: 20,
        step: .5,
        value: 5,
        measure: 'mm',
        percent_bar: true,
        clear_after: true,
        callback_change: onDataChanged,
        callback_focus: showInitialProperties
    });

    var s = "<p>Middle column has <b>always_use_wheel: true</b>, so it interacts with mouse wheel even control isn't focused. ";
    s += "Other two columns doesn't (this is default behavior).</p>";

    s += "<p>Also, controls in the middle column work with integer numbers instead of float numbers because ";
    s += "<b>fixed: true</b>.</p>";
    $(item_container).append(s);

    $(item_container).append('<h2>No title</h2>');

    new LxSpinEdit({
        container: item_container,
        id: 'cntr_no_title_1',
        hide_title: true,
        slider: true,
        min: 0,
        max: 20,
        step: .5,
        value: 5,
        measure: 'mm',
        clear_after: true,
        callback_change: onDataChanged,
        callback_focus: showInitialProperties
    });
    new LxSpinEdit({
        container: item_container,
        id: 'cntr_no_title_2',
        hide_title: true,
        slider: true,
        min: 0,
        max: 200,
        step: 5,
        value: 120,
        fixed: true,
        measure: 'oz',
        percent_bar: true,
        clear_after: true,
        callback_change: onDataChanged,
        callback_focus: showInitialProperties
    });

    new LxSpinEdit({
        container: item_container,
        id: 'cntr_no_title_3',
        hide_title: true,
        slider: true,
        min: -20,
        max: 20,
        step: .5,
        value: 10,
        measure: 'mm',
        clear_after: true,
        callback_change: onDataChanged,
        callback_focus: showInitialProperties
    });

    s = "<p>Controls have property <b>hide_title</b> set to <b>true</b>.</p>";
    $(item_container).append(s);

    $(item_container).append('<h2>Live update on slider drag</h2>');
    new LxSpinEdit({
        container: item_container,
        id: 'cntr_fly_update',
        title: 'Update',
        slider: true,
        min: 0,
        max: 200,
        step: 2,
        value: 70,
        measure: 'mm',
        live_slider: true,
        clear_after: true,
        callback_change: onDataChanged,
        callback_focus: showInitialProperties
    });

    s = "<p>This control has <b>live_slider</b> set to <b>true</b> and fires <b>callback_change</b> on every slider move. ";
    s += "By default, <b>callback</b> fires only when the movement is finished.</p>"
    $(item_container).append(s);


    $(item_container).append('<h2>Buttons are hidden while not focused</h2>');

    new LxSpinEdit({
        container: item_container,
        id: 'cntr_no_title_4',
        hide_title: true,
        slider: true,
        min: -20,
        max: 20,
        step: .5,
        value: 1,
        measure: 'mm',
        hide_buttons: true,
        callback_change: onDataChanged,
        callback_focus: showInitialProperties
    });
    new LxSpinEdit({
        container: item_container,
        id: 'cntr_no_title_5',
        hide_title: true,
        slider: true,
        min: -100,
        max: 0,
        step: 5,
        value: -15,
        measure: 'mm',
        percent_bar: true,
        percent_full_size: true,
        hide_buttons: true,
        callback_change: onDataChanged,
        callback_focus: showInitialProperties
    });
    new LxSpinEdit({
        container: item_container,
        id: 'cntr_no_title_6',
        hide_title: true,
        slider: true,
        min: 0,
        max: 20,
        step: .1,
        value: 7,
        measure: 'kg',
        hide_buttons: true,
        percent_bar: true,
        callback_change: onDataChanged,
        callback_focus: showInitialProperties
    });
    object_controls.cntr_no_title_7 = new LxSpinEdit({
        container: item_container,
        id: 'cntr_no_title_7',
        title: 'Rotation',
        slider: true,
        min: 0,
        max: 180,
        step: 5,
        value: 36,
        measure: 'rad',
        hide_buttons: true,
        percent_bar: true,
        callback_change: onDataChanged,
        callback_focus: showInitialProperties
    });

    $(item_container).append('<div class="clearfix"><p><a href="#" onclick="change_value_title_mu(); return false;">Change title, value, measurement units etc for Rotation control</a></p>');

    $(item_container).append('<h2>Disabled controls</h2>');

    object_controls.cntr_no_title_8 = new LxSpinEdit({
        container: item_container,
        id: 'cntr_no_title_8',
        hide_title: true,
        enabled: false,
        min: -20,
        max: 20,
        step: .5,
        value: 1,
        measure: 'mm',
        hide_buttons: true,
        callback_change: onDataChanged,
        callback_focus: showInitialProperties
    });
    object_controls.cntr_no_title_9 = new LxSpinEdit({
        container: item_container,
        id: 'cntr_no_title_9',
        title: 'Distance',
        slider: true,
        enabled: false,
        min: 0,
        max: 20,
        step: .5,
        value: 17,
        measure: 'mm',
        hide_buttons: true,
        percent_bar: true,
        callback_change: onDataChanged,
        callback_focus: showInitialProperties
    });
    object_controls.cntr_no_title_10 = new LxSpinEdit({
        container: item_container,
        id: 'cntr_no_title_10',
        title: 'Velocity',
        slider: true,
        enabled: false,
        min: 0,
        max: 20,
        step: .5,
        value: 10,
        measure: 'mph',
        percent_bar: true,
        percent_full_size: true,
        callback_change: onDataChanged,
        callback_focus: showInitialProperties
    });
    $(item_container).append('<div class="clearfix"><p><a href="#" id="toggle_link" onclick="toggle_disabled(); return false;">Enable controls</a></p>');

    // set focus to the first control
    setTimeout(function () {
        $(object_controls.cntr_x.input).focus();
    }, 500);
});