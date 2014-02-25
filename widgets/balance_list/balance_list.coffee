class Dashing.BalanceList extends Dashing.Widget
  ready: ->
  onData: (data) ->
    container = $(@node).parent()
    console.log container
    console.log data
