_process_ones = (count, ones, second, others) ->
    if "#{count}".length > 1
        last_two = "#{count}"[-2..]
        switch last_two
            when "11" then others
            else
                ones
    else
        ones
    

_process_seconds = (count, ones, second, others) ->
    if "#{count}".length > 1
        last_two = "#{count}"[-2..]
        switch last_two
            when "12", "13", "14" then others
            else
                second
    else
        second


get_plural = (count, ones, second, others) ->
        last = "#{count}"[-1..]

        switch last
            when "1" then _process_ones(count, ones, second, others)
            when "2", "3", "4" then _process_seconds(count, ones, second, others)
            else
                others

module.exports = get_plural
