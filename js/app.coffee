app = angular.module 'wowRealmStatus', []

# RealmsController is the only controller in the application, which fetches
# the realm list from the Realms service and displays them in a list.
app.controller 'RealmsController', ($scope, $timeout, $window, Realms, hashChange) ->
  $scope.realms = []
  $scope.search = ''
  $scope.lastUpdate = null

  # Any time the URL hash changes, update the `search` variable.
  hashChange (value) ->
    $scope.search = value

  # Conversely, if the user types into the search box and updates
  # the `search` value, represent the change in the URL.
  $scope.updateHash = ->
    $window.location.hash = $scope.search

  # Updates the server list and schedules another update in 5 minutes
  refresh = ->
    $scope.loading = true
    Realms (realms) ->
      $scope.realms = realms
      $scope.loading = false
      $scope.lastUpdate = new Date()
      $timeout(refresh, 60 * 5 * 1000)

  # Trigger the initial data fetch from the API
  refresh()


# The Realms service provides a function that takes a callback and
# calls it with an array of Realms from the Blizzard API.
app.factory 'Realms', ($http) ->
  (cb) ->
    url = "http://us.battle.net/api/wow/realm/status?jsonp=JSON_CALLBACK"
    $http.jsonp(url).success (json) -> cb(json.realms)

# The hashChange service is a function that calls a passed-in callback
# every time the URL's hash changes with the new value of the hash.
app.factory 'hashChange', ($window, $rootScope) ->
  (listener) ->
    window.onhashchange = ->
      $rootScope.$apply ->
        listener($window.location.hash?.substr(1) ? '')


# The realmType filter simply formats the raw `type` string provided by
# the Blizzard API so that it is presented nicely in the view.
app.filter 'realmType', ->
  (type) ->
    switch type
      when 'pve'   then "PvE"
      when 'pvp'   then "PvP"
      when 'rp'    then "RP"
      when 'rppvp' then "RP PvP"

# The capitalize filter capitalizes the first character in a string.
app.filter 'capitalize', ->
  (str) -> if str then str[0].toUpperCase() + str[1..-1].toLowerCase() else ""

# The boolToString filter returns the first string if the value is
# turthy and the second string otherwise.
app.filter 'boolToString', ->
  (boolean, trueString, falseString) -> if boolean then trueString else falseString
