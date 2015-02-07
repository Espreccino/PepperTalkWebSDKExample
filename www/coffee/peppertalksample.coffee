app = angular.module("peppertalksample", 
    ['ui.router', 'ui.bootstrap', 'ngSanitize'])

#
app.service('loginService', ['$http', '$rootScope', '$state', 
  ($http, $rootScope, $state) ->
    loginService = @
    @login = (userName, callback) ->
      @userName = userName
      callback(null, userName)
    #
    @getPepperKitSSO = (callback) ->
      $http.get('/api/v1/pepperkit_sso', {params: {email: loginService.userName}}).
        success((data, status) ->
          callback(null, data, status)
          return
        ).
        error((data, status) ->
          callback("failed", data, status)
          return
        )
      return
      
    return
])
#
#
app.controller('loginController', ['loginService', '$rootScope', '$scope', '$state', 
  (loginService, $rootScope, $scope, $state) ->
    @login = ->
      loginService.login(@userName, (err, data) ->
        return if err?
        $rootScope.$broadcast('login_success')
        $state.go("users")
        return
      )
      return
    return
])
#
app.controller('userController', ['loginService', '$rootScope', '$scope', '$state', 
  (loginService, $rootScope, $scope, $state) ->
    controller = @
    @users = {'a@a.com': {id: 'a@a.com', name: 'Alice', count: 0}, 'b@b.com': {id: 'b@b.com', name: 'Bob', count: 0}}
    $scope.$on('incoming_message', (event, data) ->
      if controller.users[data.participant]
        controller.users[data.participant].count = data.unread
      else
        controller.users[data.participant] = {
          id: data.participant
          name: data.participant
          count: data.unread
        }
    )
    @chat = (user) ->
      return PepperTalk.showParticipantsForTopic('NoTopic', 'No Topic') if loginService.userName is user
      return PepperTalk.chatWithParticipant(user, 'NoTopic', 'No Topic')
    #
    return
])
#
#
app.config(($stateProvider, $urlRouterProvider) ->
  $urlRouterProvider.otherwise('/login')
  $stateProvider  
    ## HOME STATES AND NESTED VIEWS ========================================
    .state('login', {
      url: '/login',
      templateUrl: 'partials/signin.html'
      controller: 'loginController as loginCtrl'
    })
    .state('users', {
      url: '/users'
      templateUrl: 'partials/users.html',
      controller: 'userController as userCtrl'
    })
  return
)
#
app.run(($rootScope, $state, $stateParams, loginService) ->
  $rootScope.$on('login_success', ->
    PepperTalk.onAuthRequired = (callback) ->
      loginService.getPepperKitSSO(callback)
      return
    PepperTalk.init()
    $(PepperTalk).on('incoming_message', (event, data) ->
      $rootScope.$evalAsync(->
        $rootScope.$broadcast('incoming_message', data)
      )
      return
    )
    return  
  )
)  
