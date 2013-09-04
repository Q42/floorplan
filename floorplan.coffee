@Qers = new Meteor.Collection "qers"

if Meteor.isServer
    Meteor.startup ->
        #Qers.remove({})
        if Qers.find().count() is 0
            names = ["Alexander Overvoorde", "Arian van Gend", "Arjen van der Ende", "Bas Warmerdam", "Benjamin de Jager", "Bob van Oorschot", "Chris Waalberg", "Christiaan Hees", "Coen Bijpost", "Cynthia Wijntje", "Elaine Oliver", "Frank Raterink", "Gerard Dorst", "Guus Goossens", "Herman Banken", "Huib Piguillet", "Jaap Mengers", "Jaap Taal", "Jan-Willem Maneschijn", "Jasper Haggenburg", "Jasper Kaizer", "Jeroen Gijsman", "Johan Huijkman", "Kamil Afsar", "Kars Veling", "Katja Hollaar", "Korjan van Wieringen", "Laurens van den Oever", "Leonard Punt", "Lukas van Driel", "Marcel Duin", "Mark van Straten", "Martijn Laarman", "Martijn van Steenbergen", "Martin Kool", "Matthijs van der Meulen", "Michiel Post", "Rahul Choudhury", "Remco Veldkamp", "Richard Lems", "Roelf-Jan de Vries", "Sander de Vos", "Sjoerd Visscher", "Stef Brooijmans", "Suzanne Waalberg", "Tim Logtenberg", "Tim van Deursen", "Tim van Steenis", "Tom Lokhorst", "Wilbert Mekenkamp"]
            _.each names, (name) -> Qers.insert name: name, pos: x: 0, y: 0

    Meteor.methods
        updatePosition: (id, x, y) -> Qers.update id, { $set: { "pos.x": x, "pos.y": y } }

if Meteor.isClient

    Meteor.startup ->
        Session.setDefault "windowWidth", $(window).width()

    Template.qers.qer = -> @Qers.find({}, sort: name: 1)

    Template.qers.forename = ->
        forename = @name.split(" ")[0]

        results = Qers.find name: new RegExp("^" + forename, "i")
        if results.count() > 1
            forename += _.last(@name.split(" "))[0]

        forename

    Template.qers.dragging = -> @pos.x isnt 0 and @pos.y isnt 0

    Template.qers.posX = -> @pos.x * Session.get("windowWidth")
    Template.qers.posY = -> @pos.y * Session.get("windowWidth") + 120

    Template.floorplan.events
        "mousemove, touchmove": (evt, template) ->
            return unless window.draggingId
            imageW = Session.get("windowWidth")
            newX = (evt.pageX / imageW)
            newY = if evt.pageY < 120 then 0 else (evt.pageY - 120) / imageW
            Meteor.call "updatePosition", window.draggingId, newX, newY
            evt.preventDefault() # prevent phones from scrolling while touchmoving
        "mouseup, touchend": -> window.draggingId = null

    Template.qers.events
        "mousedown .qer, touchstart .qer": (evt) -> window.draggingId = @_id

    $(window).resize -> Session.set "windowWidth", $(window).width()