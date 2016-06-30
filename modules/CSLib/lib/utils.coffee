$ = require 'jquery'
{zip, isEmpty, forEach, startsWith, capitalize} = require("lodash")
{warn} = (require 'console-logger').ns 'utils'
{getDomain} = require './domain'
{getParamByname, addGetParam} = require './url'
{gettext, ungettext} = require 'gettext'
pluralize = require './pluralize'
{get_config} = require 'libconfig'
{get_global_stream, publish} = require 'libstream'
keyCode = require './keycodes'
pi = require 'platform-info'
{emitter} = require 'event-channel'

CS = get_config 'CS'
ONE_MINUTE_IN_MS = 1000 * 60
ONE_HOUR_IN_MS = ONE_MINUTE_IN_MS * 60
ONE_DAY_IN_MS = ONE_HOUR_IN_MS * 24

MONTH_OPTIONS = [
    'янв.',
    'февр.',
    'марта',
    'апр.',
    'мая',
    'июня',
    'июля',
    'авг.',
    'сент.',
    'окт.',
    'нояб.',
    'дек.'
]


U =
    PHONE_INVALID_SYMBOLS_REGEX: /[^0-9\(\)\+\-\s]/gi
    capitalize: capitalize
    get_domain: getDomain
    get_param_by_name: getParamByname
    add_get_param: addGetParam

    get_max_z_index: ->
        z_index = null
        $("*").each (idx, el) ->
            el_o = $(el)
            _z_index = parseInt(el_o.css('z-index'), 10) or 0
            if _z_index > z_index
                z_index = _z_index

        z_index

    validate_email: (email_str) ->
        re = /^[a-z0-9._%+-]{1,64}@(?:[a-z0-9][a-z0-9\-]{0,62}\.)+[a-z]{2,}$/
        re.test email_str.toString().toLowerCase()

    apify: (app='remote', version=undefined, controller=undefined) ->
        if version?
            version_str = 'v' + version
            version_url_prefix = "/#{version_str}"
            CS.ROUTING[version_str] ?= {}
            routing_version = CS.ROUTING[version_str]
        else
            version_url_prefix = ''
            routing_version = CS.ROUTING

        if controller?
            scope_url_prefix = "/#{controller}"
            routing_version[controller] ?= {}
            routing_version_scope = routing_version[controller]
        else
            scope_url_prefix = ''
            routing_version_scope = routing_version

        (urls) ->
            for action, url of urls
                routing_version_scope[action] = "/#{app}#{version_url_prefix}#{scope_url_prefix}#{url}"

    is_foreign_origin: -> CS.DEFAULT_ORIGIN isnt CS.CURRENT_ORIGIN

    is_absolute: (url) -> /^https?:\/\/|^\/\//i.test(url)

    is_current_origin: (url) -> startsWith(url, CS.CURRENT_ORIGIN)

    is_wormhole_origin: (url) -> startsWith(url, CS.DEFAULT_ORIGIN)

    bool: (val) -> !!val

    is_uaprom: -> CS.COUNTRY.code is "UA"
    is_ruprom: -> CS.COUNTRY.code is "RU"
    is_belprom: -> CS.COUNTRY.code is "BY"
    is_kzprom: -> CS.COUNTRY.code is "KZ"
    is_mdprom: -> CS.COUNTRY.code is "MD"

    is_numeric: $.isNumeric

    format_rank: (val) ->
        return null unless val
        val = val.toString()
        val.replace(/(\d)(?=(\d{3})+([^\d]|$))/g, '$1 ')

    all: (lst)-> U.asbool lst.reduce ((a,b)-> a and b), true
    any: (lst)-> U.asbool lst.reduce ((a,b)-> a or b), false
    first: (lst)-> if lst.length then lst[0] else null

    object_length: (object) -> (Object.keys object).length

    object_empty: (object) ->
        for key of object
            return false
        true

    hide: (el)-> $(el).addClass("h-hidden")
    show: (el)-> $(el).removeClass("h-hidden")

    escape: (str) -> $('<div/>').text(str).html()

    flatten: (array, results = []) ->
        return [] unless array?.length
        for item in array
            if Array.isArray(item)
                U.flatten(item, results)
            else
                results.push(item)

        results

    find: (func, iterator, _default) -> U.first(iterator.filter func) or _default

    regexp_quote: (s) -> s.replace /([.?*+^$[(){}|\\])/g, "\\$1"

    pluralize: pluralize

    asbool: (value) ->
        switch (U.trim String(value).toLowerCase())
            when "true", '1', 'yes', 'on'
                true
            when 'false', '0', 'no', 'off', ''
                false
            else
                throw new Error "Can't coerce to boolean:" + value

    add_prefix: (url) ->
        if not url? or url[0] != '/' or url.indexOf(CS.URL_PREFIX) != -1
            return url
        else
            return CS.URL_PREFIX + url


    ###########################
    # moved in from uaprom.js

    show_element: (element) ->
        ($ "##{element}").show()

    hide_element: (element) ->
        ($ "##{element}").hide()

    is_type_text: (element) -> element.type is "text"

    is_type_checkbox: (element) -> element.type is "checkbox"

    is_type_select_one: (element) -> element.type is "select-one"

    is_type_radio: (element) -> element.type is "radio"

    is_type_radio_group: (element) -> element.length and U.is_type_radio element[0]

    is_type_label: (element) -> element.tagName.toLowerCase() is "label"

    trim: (str) -> str.replace /^\s+|\s+$/g, ''

    strip: (str) -> str.replace /^\s+|\s+$/g, ''

    group_set_property: (elements_ids, property, value) ->
        for id of elements_ids
            ($ "##{id}").prop property, value

    group_set_checked: (elements_ids, checked) ->
        U.group_set_property elements_ids, "checked", checked

    group_conjunct_property: (elements_ids, property) ->
        (i for i of elements_ids).map((id) -> ($ "##{id}").prop property).reduce (a, b) -> a and b

    grayscaleImage: (imgObj) ->
        canvas = document.createElement 'canvas'
        return '' unless canvas.getContext

        canvasContext = canvas.getContext '2d'

        imgW = imgObj.width
        imgH = imgObj.height

        canvas.width = imgW
        canvas.height = imgH

        canvasContext.drawImage imgObj, 0, 0

        imgPixels = canvasContext.getImageData 0, 0, imgW, imgH

        for y in [0..imgPixels.height] by 1
            for x in [0..imgPixels.width] by 1
                i = (y * 4) * imgPixels.width + x * 4
                avg = (imgPixels.data[i] + imgPixels.data[i + 1] + imgPixels.data[i + 2]) / 3
                imgPixels.data[i] = avg
                imgPixels.data[i + 1] = avg
                imgPixels.data[i + 2] = avg

        canvasContext.putImageData imgPixels, 0, 0, 0, 0, imgPixels.width, imgPixels.height

        return canvas.toDataURL()

    obj_keys_to_lower: (obj) ->
        ret = {}
        for k, v of obj
            ret[k.toLowerCase()] = v
        ret

    is_ctrl: (code) ->
        code in [keyCode.LEFT, keyCode.RIGHT, keyCode.DELETE,
            keyCode.BACKSPACE, keyCode.TAB, keyCode.HOME, keyCode.END]

    is_nan: (obj) ->
        not obj? or not (/\d/.test obj) or isNaN obj

    is_numeric_code: (code) ->
        chr = String.fromCharCode code
        not U.is_nan(parseFloat(chr)) and isFinite(chr)

    xor: (encoded, keys) ->
        [e ^ k for [e, k] in zip(encoded, keys)]

    element_in_viewport: (el) ->
        top = el.offsetTop
        left = el.offsetLeft
        width = el.offsetWidth
        height = el.offsetHeight

        while el.offsetParent
            el = el.offsetParent
            top += el.offsetTop
            left += el.offsetLeft

        return (
            top >= window.pageYOffset and
            left >= window.pageXOffset and
            (top + height) <= (window.pageYOffset + window.innerHeight) and
            (left + width) <= (window.pageXOffset + window.innerWidth)
        )

    element_partly_in_viewport: (el) ->
        top = el.offsetTop
        left = el.offsetLeft
        width = el.offsetWidth
        height = el.offsetHeight

        while el.offsetParent
            el = el.offsetParent
            top += el.offsetTop
            left += el.offsetLeft

        return (
            top < (window.pageYOffset + window.innerHeight) and
            left < (window.pageXOffset + window.innerWidth) and
            (top + height) > window.pageYOffset and
            (left + width) > window.pageXOffset
        )

    safe_url: (url) ->
        # passes url if it is relative / starts with current Domain
        # or lastly contains domain string (For client-sites)
        # used for html_sanitize
        current_domain = get_config("CS.CURRENT_DOMAIN").toLowerCase()
        current_domain_absolute_url_pattern = new RegExp(
            '^((http|https)?(:\/\/)?)?(www\.)?.+?' +
            current_domain +
            '(:[0-9]+)?\/?'
        )

        if (current_domain_absolute_url_pattern.test url) or (url[0] is '/')
            url
        else
            null

    # FIXME move to dom utils
    load_script: (url, callback) ->
        # FIXME put request to external resources queue instead?
        if get_config("ENV.disable_external_resources")
            warn "ENV.disable_external_resources is true, not loading script"

        else
            script = document.createElement "script"
            script.type = "text/javascript"

            if script.readyState  # IE
                script.onreadystatechange = ->
                    if script.readyState is "loaded" or script.readyState is "complete"
                        script.onreadystatechange = null
                        callback?()
            else # Others
                script.onload = ->
                    callback?()

            script.src = url
            document.body.appendChild script

    full_unescape: (text) ->
        char_table = {
            'quot': 34
            'amp': 38
            'lt': 60
            'gt': 62
            'nbsp': 160
            'iexcl': 161
            'cent': 162
            'pound': 163
            'curren': 164
            'yen': 165
            'brvbar': 166
            'sect': 167
            'uml': 168
            'copy': 169
            'ordf': 170
            'laquo': 171
            'not': 172
            'shy': 173
            'reg': 174
            'macr': 175
            'deg': 176
            'plusmn': 177
            'sup2': 178
            'sup3': 179
            'acute': 180
            'micro': 181
            'para': 182
            'middot': 183
            'cedil': 184
            'sup1': 185
            'ordm': 186
            'raquo': 187
            'frac14': 188
            'frac12': 189
            'frac34': 190
            'iquest': 191
            'Agrave': 192
            'Aacute': 193
            'Acirc': 194
            'Atilde': 195
            'Auml': 196
            'Aring': 197
            'AElig': 198
            'Ccedil': 199
            'Egrave': 200
            'Eacute': 201
            'Ecirc': 202
            'Euml': 203
            'Igrave': 204
            'Iacute': 205
            'Icirc': 206
            'Iuml': 207
            'ETH': 208
            'Ntilde': 209
            'Ograve': 210
            'Oacute': 211
            'Ocirc': 212
            'Otilde': 213
            'Ouml': 214
            'times': 215
            'Oslash': 216
            'Ugrave': 217
            'Uacute': 218
            'Ucirc': 219
            'Uuml': 220
            'Yacute': 221
            'THORN': 222
            'szlig': 223
            'agrave': 224
            'aacute': 225
            'acirc': 226
            'atilde': 227
            'auml': 228
            'aring': 229
            'aelig': 230
            'ccedil': 231
            'egrave': 232
            'eacute': 233
            'ecirc': 234
            'euml': 235
            'igrave': 236
            'iacute': 237
            'icirc': 238
            'iuml': 239
            'eth': 240
            'ntilde': 241
            'ograve': 242
            'oacute': 243
            'ocirc': 244
            'otilde': 245
            'ouml': 246
            'divide': 247
            'oslash': 248
            'ugrave': 249
            'uacute': 250
            'ucirc': 251
            'uuml': 252
            'yacute': 253
            'thorn': 254
            'yuml': 255
            'OElig': 338
            'oelig': 339
            'Scaron': 352
            'scaron': 353
            'Yuml': 376
            'fnof': 402
            'circ': 710
            'tilde': 732
            'Alpha': 913
            'Beta': 914
            'Gamma': 915
            'Delta': 916
            'Epsilon': 917
            'Zeta': 918
            'Eta': 919
            'Theta': 920
            'Iota': 921
            'Kappa': 922
            'Lambda': 923
            'Mu': 924
            'Nu': 925
            'Xi': 926
            'Omicron': 927
            'Pi': 928
            'Rho': 929
            'Sigma': 931
            'Tau': 932
            'Upsilon': 933
            'Phi': 934
            'Chi': 935
            'Psi': 936
            'Omega': 937
            'alpha': 945
            'beta': 946
            'gamma': 947
            'delta': 948
            'epsilon': 949
            'zeta': 950
            'eta': 951
            'theta': 952
            'iota': 953
            'kappa': 954
            'lambda': 955
            'mu': 956
            'nu': 957
            'xi': 958
            'omicron': 959
            'pi': 960
            'rho': 961
            'sigmaf': 962
            'sigma': 963
            'tau': 964
            'upsilon': 965
            'phi': 966
            'chi': 967
            'psi': 968
            'omega': 969
            'thetasym': 977
            'upsih': 978
            'piv': 982
            'ensp': 8194
            'emsp': 8195
            'thinsp': 8201
            'zwnj': 8204
            'zwj': 8205
            'lrm': 8206
            'rlm': 8207
            'ndash': 8211
            'mdash': 8212
            'lsquo': 8216
            'rsquo': 8217
            'sbquo': 8218
            'ldquo': 8220
            'rdquo': 8221
            'bdquo': 8222
            'dagger': 8224
            'Dagger': 8225
            'bull': 8226
            'hellip': 8230
            'permil': 8240
            'prime': 8242
            'Prime': 8243
            'lsaquo': 8249
            'rsaquo': 8250
            'oline': 8254
            'frasl': 8260
            'euro': 8364
            'image': 8465
            'weierp': 8472
            'real': 8476
            'trade': 8482
            'alefsym': 8501
            'larr': 8592
            'uarr': 8593
            'rarr': 8594
            'darr': 8595
            'harr': 8596
            'crarr': 8629
            'lArr': 8656
            'uArr': 8657
            'rArr': 8658
            'dArr': 8659
            'hArr': 8660
            'forall': 8704
            'part': 8706
            'exist': 8707
            'empty': 8709
            'nabla': 8711
            'isin': 8712
            'notin': 8713
            'ni': 8715
            'prod': 8719
            'sum': 8721
            'minus': 8722
            'lowast': 8727
            'radic': 8730
            'prop': 8733
            'infin': 8734
            'ang': 8736
            'and': 8743
            'or': 8744
            'cap': 8745
            'cup': 8746
            'int': 8747
            'there4': 8756
            'sim': 8764
            'cong': 8773
            'asymp': 8776
            'ne': 8800
            'equiv': 8801
            'le': 8804
            'ge': 8805
            'sub': 8834
            'sup': 8835
            'nsub': 8836
            'sube': 8838
            'supe': 8839
            'oplus': 8853
            'otimes': 8855
            'perp': 8869
            'sdot': 8901
            'lceil': 8968
            'rceil': 8969
            'lfloor': 8970
            'rfloor': 8971
            'lang': 9001
            'rang': 9002
            'loz': 9674
            'spades': 9824
            'clubs': 9827
            'hearts': 9829
            'diams': 9830
        }
        for k, v of char_table
            text = text.replace(
                new RegExp("&#{k};", 'gi'),
                String.fromCharCode(v)
            )

        text.replace(
            /(&)(#)(\d{1,})(;)/g,
            (tot,amp,cr,cp,sem)-> String.fromCharCode(cp)
        )

    strip_tags: (text)-> text.replace(/<\/?[^>]+>/g, '')

    init_dna_ie8: (id)->

        if pi.is_ie() and pi.get_browser_version() < 9
            emitter.pub 'dom-node-inserted', document.getElementById(id)

    only_digits_on_keypress: (e) ->
        key_code = e.key_code or e.which
        # console.log(key_code)
        accepted_chars = [32, 40, 41, 43, 45, 38, 39, 40]
        if e.charCode == 0
            return true
        if (key_code not in accepted_chars and key_code > 31 and (key_code < 48 or key_code > 57))
            e.preventDefault()
            return false
        return true

    has_uuid: (id) ->
        !!~id.search /[0-9A-F]{8}\-[0-9A-F]{4}\-4[0-9A-F]{3}\-[0-9A-F]{4}\-[0-9A-F]{12}/gi

    startswith: startsWith

    validate_phone: (phone_string, country=CS.COUNTRY.code) ->
        digits = phone_string.replace(/[^\d]/g, '')
        international = startsWith(phone_string, /[\s]*\+/)
        if not digits or digits.length < 9
            false
        else if international
            # UA
            if startsWith(digits, '380')
                digits.length == 12
            # RU
            else if startsWith(digits, '73') or startsWith(digits, '74') or startsWith(digits, '75') or startsWith(digits, '78') or startsWith(digits, '79')
                digits.length == 11
            # BY
            else if startsWith(digits, '375')
                digits.length == 12
            # KZ
            else if startsWith(digits, '76') or startsWith(digits, '77')
                digits.length == 11
            # MD
            else if startsWith(digits, '373')
                digits.length == 11
            # Other?
            else
                digits.length >= 9 and digits.length <= 15
        else
            switch country
                when "UA"
                    digits.length == 10 and startsWith(digits, '0')
                when "RU"
                    digits.length == 11 and startsWith(digits, '8')
                when "BY"
                    # BY is in transition from 8-local to 0-local
                    (
                        digits.length == 10 and startsWith(digits, '0') or
                        digits.length == 11 and startsWith(digits, '8')
                    )
                when "KZ"
                    digits.length == 11 and startsWith(digits, '8')
                when "MD"
                    digits.length == 9 and startsWith(digits, '0')
                else
                    false

    truncate_phone: (phone_string) ->
        digits = phone_string.replace(/[^\d]/g, '')
        international = startsWith(phone_string, /[\s]*\+/)
        if digits and digits.length > 9
            is_ua = CS.COUNTRY.code is "UA"
            is_ru = CS.COUNTRY.code is "RU"
            is_by = CS.COUNTRY.code is "BY"
            is_kz = CS.COUNTRY.code is "KZ"
            is_md = CS.COUNTRY.code is "MD"
            while (
                # international
                digits.length > 15 or
                digits.length > 12 and (startsWith(digits, '380') or startsWith(digits, '375')) or
                digits.length > 11 and (startsWith(digits, '7') or startsWith(digits, '373')) or
                # local
                # BY is in transition from 8-local to 0-local
                not international and (
                    digits.length > 10 and startsWith(digits, '0') and (is_ua or is_by) or
                    digits.length > 11 and startsWith(digits, '8') and (is_ru or is_by or is_kz) or
                    digits.length > 9 and startsWith(digits, '0') and (is_md)
                )
            )
                phone_string = phone_string.slice(0, -1)
                digits = phone_string.replace(/[^\d]/g, '')

        phone_string

    get_phone_example: ->
        CS.PHONE_EXAMPLE

    get_country_internal_code: ->
        CS.COUNTRY.internal_phone_code

    is_country_code_internal: (country_code) ->
        country_code == U.get_country_internal_code()

    format_phone_country_code: (country_code) ->
        if !U.is_country_code_internal(country_code)
            country_code = "+" + country_code
        country_code

    join_phone_dict: (phone_dict) ->
        unless phone_dict
            return ''

        country_code = phone_dict?.country or phone_dict?.country_code or CS.COUNTRY.phone_code
        country_code = U.format_phone_country_code(country_code)
        code = phone_dict?.code or ''
        phone = phone_dict?.phone or ''

        "#{country_code}#{code}#{phone}"


    has_parent: (node, leaf) ->
        while leaf? and leaf isnt document
            if node is leaf
                return true
            leaf = leaf.parentNode
        false

    has_parent_by_tag_name: (tag, leaf) ->
        while leaf? and leaf isnt document
            if leaf.tagName is tag
                return true
            leaf = leaf.parentNode
        false

    get_parent_with_attr: (leaf, attr) ->
        while leaf? and leaf isnt document
            if leaf.hasAttribute attr
                return leaf
            leaf = leaf.parentNode
        null

    send_via_appbus: (msg) ->
        unless msg.to and msg.from and msg.tell
            throw new Error "Bad AppBus message: `to`, `from`, `tell` fields are required"
        AppBus = get_global_stream 'AppBus'
        publish AppBus, msg

    get_appbus: -> get_global_stream 'AppBus'

    popup_help: (elem, title, body, settings, format_data) ->
        U.send_via_appbus
            to: 'Popup'
            from: 'popup_help'
            tell: 'create-help'
            data: [elem, {title: title, body: body, format_data: format_data}, settings]

    popup_hint: (elem, title, body, settings, format_data) ->
        U.send_via_appbus
            to: 'Popup'
            from: 'popup_hint'
            tell: 'create-hint'
            data: [elem, {title: title, body: body, format_data: format_data}, settings]

    get_discount_label: ({discount_percent, gifts, discount_expire_days}) ->
        has_gifts = gifts?.length

        return unless discount_percent or has_gifts

        discount_class = ''
        discount_label = ''
        discount_label_bottom = ''
        discount_price_label = ''
        expire_days = ''

        if discount_percent
            discount_label = "-#{discount_percent}%"
            discount_price_label = "#{gettext 'Со скидкой'} #{discount_percent}%"
            if has_gifts
                discount_label_bottom = gettext "+ подарок"
                discount_price_label += gettext " + подарок"

        if discount_expire_days
            discount_class += 'b-discount_type_timeout'
            if discount_expire_days > 1
                expire_days = pluralize(
                    discount_expire_days
                    gettext "еще #{discount_expire_days} день"
                    gettext "еще #{discount_expire_days} дня"
                    gettext "еще #{discount_expire_days} дней"
                )
                discount_price_label += ". #{gettext 'Осталось'} #{discount_expire_days} " + pluralize(
                    discount_expire_days
                    gettext 'день'
                    gettext 'дня'
                    gettext 'дней'
                )
            else
                expire_days = "#{gettext 'только сегодня'}"
                discount_price_label += ". #{gettext 'Только сегодня'}"

        discount_class: discount_class
        discount_label: discount_label
        discount_label_bottom: discount_label_bottom
        discount_price_label: discount_price_label
        expire_days: expire_days
        has_gifts: has_gifts

    get_stars_css: (stars_number) ->
        stars = [
            'b-pro-state_stars_zero',
            'b-pro-state_stars_one',
            'b-pro-state_stars_two',
            'b-pro-state_stars_three',
            'b-pro-state_stars_four'
        ]

        stars[stars_number]

    get_presence_title: (presence, supply_period) ->
        data = {
            'none': gettext 'Наличие уточняйте'
            'available': gettext 'В наличии'
            'not_available': gettext 'Нет в наличии'
            'order': gettext 'Под заказ'
            'service': gettext 'Услуга'
        }

        if presence is 'order' and supply_period
            supply_text = pluralize(
                supply_period
                gettext "#{supply_period} день"
                gettext "#{supply_period} дня"
                gettext "#{supply_period} дней"
            )
            return "#{data.order}, #{supply_text}"

        return if data[presence]? then data[presence] else ''

    get_presence_css: (presence) ->
        switch presence
            when 'available', 'service' then 'h-color-green-light'
            when 'order' then 'h-color-mustard'
            else 'h-color-red'

    get_rating_info: (rating) ->
        colorClass = ""
        ratingLabel = ""

        if rating > 80
            colorClass = "b-progress_color_green"
            ratingLabel = gettext('Отлично')
        else if rating > 60
            colorClass = "b-progress_color_pale-green"
            ratingLabel = gettext('Хорошо')
        else if rating > 40
            colorClass = "b-progress_color_yellow"
            ratingLabel = gettext('Нормально')
        else if rating > 20
            colorClass = "b-progress_color_orange"
            ratingLabel = gettext('Плохо')
        else if rating > 0
            colorClass = "b-progress_color_red"
            ratingLabel = gettext('Очень плохо')

        colorClass: colorClass
        ratingLabel: ratingLabel

    split_every: (n, l) ->
        chunk = l[0..n-1]
        (chunk.length and ([chunk].concat U.split_every n, l[n..]) or [chunk])
        .filter (i) -> i.length

    action_is: (action_name) -> ({action}) -> action is action_name

    get_react_root_node_id: (component) ->
        (component._reactInternalInstance or component)._rootNodeID

    format_price: (price, d=2, w=3, s=' ', c=',') ->
        #########################################
        # @param integer d: length of decimal
        # @param integer w: length of whole part
        # @param mixed   s: sections delimiter
        # @param mixed   c: decimal delimiter
        #########################################
        price = if price % 1 is 0 then price else price.toFixed(d)
        price = if c then "#{price}".replace('.', c) else price
        end = if d > 0 then '\\b' else '$'
        re = "\\d(?=(\\d{#{w}})+#{end})"
        "#{price}".replace new RegExp(re, 'g'), "$&#{s}"

    get_UTC_date: (dateString) ->
        date = new Date(dateString)
        time = date.getTime()
        offset = date.getTimezoneOffset()
        offset_in_ms = offset * ONE_MINUTE_IN_MS
        new Date(time + offset_in_ms)

    humanize_date: (dateString) ->
        date = @get_UTC_date(dateString)
        dateNow = new Date()
        timeDelta = dateNow.getTime() - date.getTime()
        if timeDelta < ONE_MINUTE_IN_MS
            gettext '1 минуту назад'
        else if timeDelta < ONE_HOUR_IN_MS
            minutesAgo = Math.floor timeDelta / ONE_MINUTE_IN_MS
            cases = ['минута', 'минуты', 'минут']
            gettext "#{minutesAgo} #{ungettext(cases, minutesAgo)} назад"
        else if timeDelta < ONE_DAY_IN_MS
            if dateNow.getDate() == date.getDate()
                hoursAgo = Math.floor timeDelta / ONE_HOUR_IN_MS
                cases = ['час', 'часа', 'часов']
                gettext "#{hoursAgo} #{ungettext(cases, hoursAgo)} назад"
            else
                gettext "Вчера в #{date.format('HH:MM')}"
        else
            gettext "#{date.getDate()} #{MONTH_OPTIONS[date.getMonth()]}
                    #{date.getFullYear()} г., #{date.format('HH:MM')}"

    extract_enums: (data) ->
        data['APPSTATE_ENUMS']

    get_new_query_params: (params) ->
        #########################################
        # @param Array params: params to add/replace in GET params
        # [
        #     {key: 'page', value: current_page},
        #     {key: 'per_page', value: items_per_page}
        # ]
        #########################################
        queryParams = location.search
        forEach params, ({key, value}) ->
            newParam = "#{key}=#{value}"
            searchRegex = new RegExp("[\\?&]#{key}=([^&#]*)")
            if searchRegex.test queryParams
                replaceRegex = new RegExp("#{key}=([^&#]*)")
                queryParams = queryParams.replace(replaceRegex, newParam)
            else
                newParam = if isEmpty(queryParams) then "?#{newParam}" else "&#{newParam}"
                queryParams = queryParams + newParam
        queryParams

    # TODO: Remove this after denomination
    get_belarus_price_transformation: () ->
        transform_price = null
        if get_config('CS.FUNCTIONALITY.content_belarus_price_before_law')
            transform_price = (price) ->
                price / 10000
        if get_config('CS.FUNCTIONALITY.content_belarus_price_after_law')
            transform_price = (price) ->
                price * 10000
        transform_price

module.exports = U
