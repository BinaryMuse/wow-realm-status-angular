app = angular.module 'wowRealmStatus', []

app.factory 'Realms', ($http) ->
  (cb) ->
    url = "http://us.battle.net/api/wow/realm/status?jsonp=JSON_CALLBACK"
    $http.jsonp(url)
      .success(cb)

app.filter 'realmType', ->
  (type) ->
    switch type
      when 'pve'   then "PvE"
      when 'pvp'   then "PvP"
      when 'rp'    then "RP"
      when 'rppvp' then "RP PvP"

app.filter 'realmStatus', ->
  (status) -> if status then "Up" else "Down"

app.filter 'realmPop', ->
  (pop) ->
    switch pop
      when 'low'    then "Low"
      when 'medium' then "Medium"
      when 'high'   then "High"
      else pop

app.filter 'realmQueue', ->
  (queue) -> if queue then "Yes" else "No"

app.controller 'RealmController', ($scope, $timeout, Realms) ->
  $scope.search = location.hash?.substr(1) ? ''
  $scope.lastUpdate = null
  $scope.realms = []

  window.onhashchange = ->
    $scope.search = location.hash
  $scope.$watch 'search', (val) ->
    location.hash = val if val?

  $scope.showAll = ->
    $scope.search = ''

  $scope.showOnly = (name) ->
    $scope.search = name

  refresh = ->
    $scope.loading = true
    Realms (data) ->
      $scope.realms = data.realms
      $scope.loading = false
      $scope.lastUpdate = new Date()
      $timeout(refresh, 60 * 5 * 1000)

  refresh()
