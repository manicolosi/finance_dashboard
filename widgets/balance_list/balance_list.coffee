class Dashing.BalanceList extends Dashing.Widget
  ready: ->
    items = @items

    $('li', @node).each (index, element) ->
      item = items[index]
      if item.budget
        percent = Math.min item.value / item.budget * 100, 100
        $('.bar', element).width("#{percent}%")
      else
        $('.bar', element).width("0")
