
# Use JQuery onload
$ ->

    # Setup socket.io connection
    socket = io()

    # Setup models and views
    Model = Backbone.Model.extend (
        defaults: (
            term: null
            originalLookup: null
            definitions: null
            chosenIndex: null
        )
    )

    View = Backbone.View.extend (

        events: (
            'input .lookup' : '_doUpdate'
        )

        bindings: (
            '.query-name' : 'term'
            '.learndb-results': (
                observe: 'definitions'
                updateMethod: 'html'
                onGet: (val) ->
                    r = '<ul>'
                    for v in val
                       r += '<li>' + v + '</li>'
                    r += '</ul>'
                    return r
            )
        )

        render: ->
            @stickit()

        _doUpdate: ->
            console.log 'hi'
            socket.emit 'lookup', @$el.find('[name=lookup]').val(), (res) =>
                @model.set res
    )


    model = new Model()
    view = new View (
        el: '#learndb-view'
        model: model
    )

    # Render view to initialize bindings
    view.render()

