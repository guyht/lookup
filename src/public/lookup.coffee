
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
                       r += '<li>' + v + '</li>'
                    r += '</ol>'
                    return r
            )
        )

        render: ->
            @_loadAnim false
            @stickit()

        _loadAnim: (visible) ->
            @$el.find('.spinner').css 'visibility', (if visible then '' else 'hidden')

        _doUpdate: ->
            @_loadAnim true
            console.log 'looking up'
            console.log @model.get 'term'
            socket.emit 'lookup', @model.get('term'), (err, res) =>
                @model.set res
                @_loadAnim false

    )



    model = new Model()
    view = new View (
        el: '#learndb-view'
        model: model
    )


    # Setup router
    router = Backbone.Router.extend (

        # Setup route definitions
        routes: (
            'term/:term' : 'search_term'
        )

        # Handle routing
        search_term: (term) ->
            model.set 'term', term
            model._doUPdate()
    )


    # Render view to initialize bindings
    view.render()
