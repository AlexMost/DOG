{gettext} = require "gettext"
$ = require 'jquery'
{get_config} = require 'libconfig'
{send_via_appbus} = require './utils'

country_phone_code = get_config 'CS.COUNTRY.phone_code'

util = require './utils'

POPUP_TYPE_NORMAL = 'NORMAL'
POPUP_TYPE_ERROR = 'ERROR'

TEXT =
    PHONE: gettext("Неверный формат номера. Укажите только цифры, например #{country_phone_code} 12 3456789")
    COUNTRY_CODE: gettext("Заполните код страны, например #{country_phone_code}")

POPUP_Z_INDEX = 6000
POPUPS = []

hide_popups_msg =
    to: 'Popup'
    from: 'validation'
    tell: 'remove'
    data: POPUPS

_popup = (el, msg, type) ->
    send_via_appbus hide_popups_msg

    send_via_appbus
        to: 'Popup'
        from: 'validation'
        tell: 'create-help'
        data: [
            el
            { title: '', body: msg }
            {
                callback: (popup_id) -> POPUPS.push popup_id
                z_index: POPUP_Z_INDEX
                fixed: true
                css_class: 'b-popup_type_hint-with-closer'
                type: type or POPUP_TYPE_NORMAL
            }
        ]

show_error_popup = (el, msg, POPUP_TYPE_ERROR) -> _popup(el, msg, POPUP_TYPE_ERROR)

hide_error_popups = -> send_via_appbus hide_popups_msg

is_valid_country_code = (code) ->
    '+' not in code and 1 <= code.length <= 4 and $.isNumeric code

is_valid_phone_code = (phone_code) ->
    unless $.isNumeric phone_code
        false
    else if 1 < phone_code.length < 7
        true
    else
        false

is_valid_phone = (phone) ->
    unless $.isNumeric phone
        false
    else if 4 < phone.length <= 12
        true
    else
        false

is_valid_phone_field = (fields, values, success_cb, error_cb) ->
    country_code_el = fields.country_code_el
    code_el = fields.code_el
    phone_el = fields.phone_el

    country_code = values.country_code
    phone_code = values.phone_code
    phone = values.phone

    if (is_valid_phone phone) and (is_valid_phone_code phone_code)
        if (country_code_el.is ":input") and not (is_valid_country_code country_code)
            show_error_popup country_code_el, TEXT.COUNTRY_CODE

        else
            phone_dict = { country_code, phone_code, phone }
            hide_error_popups()
            success_cb?(phone_dict)

    else

        error_cb?()

        if country_code_el
            country_code_el.focus()
        else
            code_el.focus()

        if (country_code_el.is ":input") and not (is_valid_country_code country_code)
            show_error_popup country_code_el, TEXT.COUNTRY_CODE

        else unless (is_valid_phone_code phone_code)
            show_error_popup code_el, TEXT.PHONE

        else unless (is_valid_phone phone)
            show_error_popup phone_el, TEXT.PHONE

        else
            true


module.exports = { show_error_popup, hide_error_popups, is_valid_country_code,
                   is_valid_phone_code, is_valid_phone, is_valid_phone_field }
