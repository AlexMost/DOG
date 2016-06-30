$ = require('jquery')
thumbler_view = require('../view/tumbler_view')

module.exports =
    select_dropdown: (drop_down) ->
        ###
            Transform functionality of the html select tag to div
            The chosen value sets to dropdown hidden input

              +------------------+
              |  dropdown value  | DropDown
            +----------------------+
            |  dropdown list item  | DropDown List
            +----------------------+

            select_dropdown takes a dict:
            drop_down = {
                CSS_DROP_DOWN_SEL
                CSS_DROP_DOWN_VALUE_SEL
                CSS_DROP_DOWN_LIST_SEL
                CSS_DROP_DOWN_LIST_ITEM_SEL
            }
        ###
        _set_val = (item_el) ->
            option_value = item_el.data 'value'

            drop_down_value_el.html item_el.html()
            input_el.val option_value
            input_el.trigger "change"

        # get DOM elements
        drop_down_el = $(drop_down.CSS_DROP_DOWN_SEL)
        drop_down_value_el = $(drop_down.CSS_DROP_DOWN_VALUE_SEL)
        list_el = $(drop_down.CSS_DROP_DOWN_LIST_SEL)
        list_item_el = $(drop_down.CSS_DROP_DOWN_LIST_ITEM_SEL)
        input_el = drop_down_el.find('input:first')

        # set default value to div
        select_val = input_el.val()
        if select_val
            list_item_el.each (idx, item) ->
                if $(item).val() is select_val
                    _set_val $(item)

        drop_down_el.click (ev) ->
            if list_el.is ":hidden"
                if drop_down.CSS_DROP_DOWN_ACTIVE_STATE_CLS
                    drop_down_el.addClass drop_down.CSS_DROP_DOWN_ACTIVE_STATE_CLS
                else
                    list_el.show()
            else
                if drop_down.CSS_DROP_DOWN_ACTIVE_STATE_CLS
                    drop_down_el.removeClass drop_down.CSS_DROP_DOWN_ACTIVE_STATE_CLS
                else
                    list_el.hide()

        # set selected value
        list_item_el.click (ev) -> _set_val $(ev.target)

        # hide drop down when click on the area outside the
        $(document.body).click (ev) ->
            element = $(ev.target)

            if element.parents(drop_down.CSS_DROP_DOWN_SEL).length is 0
                unless element.is drop_down_el
                    if drop_down.CSS_DROP_DOWN_ACTIVE_STATE_CLS
                        drop_down_el.removeClass drop_down.CSS_DROP_DOWN_ACTIVE_STATE_CLS
                    else
                        list_el.hide()

    replace_with_input: (from_el, to_el, style_cls, input_cls) ->
        if from_el.is ":input"
            null

        else
            input_cls or= 'b-input__field'
            id = to_el.attr 'id'
            to_el.remove()
            with_name = to_el.attr 'name'

            content = $.trim from_el.text()

            input = $ "<input>", { 'class': input_cls }
            input.attr('type', 'input')
                 .attr('id', id)
                 .attr('name', with_name)
                 .attr('value', content)

            div = $ "<div>", { 'class': style_cls }
            div.append input
            from_el.replaceWith div
            input.focus()


    tumbler: ({view, switcher_s}) ->
      """
      @view: template for toggler rendering
      @switcher_s:
          _______________________
          |  __________________
          |  |        |      | |
          |  | Yes/No |   1  | |
          |  |________|______|_|
          |________________________

              1: switcher_s - selector fot switch tumbler.
      """

      ({el, active, toggle_cb}) ->
        """
        @el : placeholder for toggler rendering.
        @active : tumbler state
        @toggle_cb : if we need to validate tumbler logic somehow we may provide cb function
          that will be executed after tumbler toggling, and will accept current status of tumbler.
        """
        j_el = $ el

        render = -> j_el.html thumbler_view {active}

        render()

        switcher_click_handler = if toggle_cb
            ->
              active = !active
              toggle_cb active
        else
            ->
              active = !active
              render()

        j_el.delegate switcher_s, 'click' , switcher_click_handler

        render: render

        check: ->
          active = true
          render()

        uncheck: ->
          active = false
          render()

        val: -> active


