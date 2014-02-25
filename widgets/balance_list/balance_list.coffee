class Dashing.BalanceList extends Dashing.Widget
  ready: ->
    items = @items

    $('li', @node).each (index, element) ->
      item = items[index]
      if item.budget
        percent = item.value / item.budget * 100
        $('.bar', element).width("#{Math.min percent, 100}%")
        if percent > 100
          $('.bar', element).addClass('over')
        else if percent > 90
          $('.bar', element).addClass('close')
        else
          $('.bar', element).addClass('under')
      else
        $('.bar', element).width("0")
