
# Use JQuery onload
$ ->




    # Setup socket.io connection
    socket = io()

    # Setup models and views
    Model = Backbone.Model.extend (
        defaults: (
            term: null
            monster: null
            originalLookup: null
            definitions: null
            chosenIndex: null
        )
    )

    View = Backbone.View.extend (

        initialize: (@options) ->
            # Setup router
            router = @options.router
            router.route 'term/:term', 'term', (term) =>
                @model.set 'term', term
                @_doUpdate()

        events: (
            #'input .lookup' : '_doUpdate'
            # Prevent form submit
            'submit #lookup-form' : (e) ->
                e.preventDefault()
                @_doUpdate()
        )

        bindings: (
            '.lookup' : 'term'
            '.query-name' : 'term'
            '.learndb-monster' : (
                observe: 'monster'
                updateMethod: 'html'
            )
            '.learndb-results': (
                observe: 'definitions'
                updateMethod: 'html'
                onGet: (val) ->
                    # If no monster then return nothing
                    if !val then return ''

                    r = '<ol>'
                    for v in val
                       r += '<li>' + _.escape(v) + '</li>'
                    r += '</ol>'

                    # Parse {...} to links
                    r = r.replace /{(.+?)}/g, "<a href='#term/$1'>$1</a>"

                    return r
            )
        )

        render: ->
            @_loadAnim false
            @stickit()

        _loadAnim: (visible) ->
            @$el.find('.spinner').css 'visibility', (if visible then '' else 'hidden')

        _doUpdate: ->
            # Update the browser URL
            @options.router.navigate 'term/' + @model.get('term')
            @_loadAnim true
            socket.emit 'lookup', @model.get('term'), (err, res) =>
                if err or !res then return # An error occured server side

                @model.set res
                @_loadAnim false

    )


    StatsModel = Backbone.Model.extend (
        defaults: (
            queries: null
            terms: null
        )
    )

    StatsView = Backbone.View.extend (
        initialize: (@opt) ->

        bindings: (
            '#counter' : 'queries'
            '#popular' : (
                observe: 'terms'
                updateMethod: 'html'
                onGet: (terms) ->
                    if !terms then return ''
                    r = []
                    #c = if terms.length <= 5 then terms.length else 5

                    for t in terms
                        r.push '<li><a href="#term/' + t.term + '">' + t.term + '</a> - ' + t.count + ' hits </li>'

                    return r.join ''
            )
        )

        render: ->
            @stickit()
    )



    # Setup router
    Router = Backbone.Router.extend (

        initialize: (@options) ->

    )


    model = new Model()
    router = new Router()


    view = new View (
        el: '#learndb-view'
        model: model
        router: router
    )


    statsModel = new StatsModel()
    statsView = new StatsView (
        el: '#stats'
        model: statsModel
    )
    socket.on 'stats', (data) ->
        console.log data
        statsModel.set data

    Backbone.history.start()


    # Render view to initialize bindings
    view.render()
    statsView.render()
