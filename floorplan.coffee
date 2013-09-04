@Qers = new Meteor.Collection "qers"

if Meteor.isClient

    headerHeight = 120 + 42

    Meteor.startup ->
        Session.setDefault "draggingId", null
        Session.setDefault "windowWidth", $(window).width()

    Template.qers.qer = -> @Qers.find({}, sort: name: 1)

    Template.qers.forename = ->
        forename = @name.split(" ")[0]

        results = Qers.find name: new RegExp("^" + forename + "\b", "i")
        if results.count() > 1
            forename += _.last(@name.split(" "))[0]

        forename

    Template.qers.dragging = -> @pos.x isnt 0 and @pos.y isnt 0

    Template.qers.posX = -> @pos.x * Session.get("windowWidth")
    Template.qers.posY = -> @pos.y * Session.get("windowWidth") + headerHeight

    Template.floorplan.events
        "mousemove, touchmove": (evt, template) ->
            return unless Session.get("draggingId") or Meteor.user()
            imageW = Session.get("windowWidth")
            newX = (evt.pageX / imageW)
            newY = if evt.pageY < headerHeight then 0 else (evt.pageY - headerHeight) / imageW
            Meteor.call "updatePosition", Session.get("draggingId"), newX, newY
            evt.preventDefault() # prevent phones from scrolling while touchmoving
        "mouseup, touchend": -> Session.set "draggingId", null

    Template.qers.events
        "mousedown .qer, touchstart .qer": (evt) -> Session.set "draggingId", @_id

    $(window).resize -> Session.set "windowWidth", $(window).width()

    $(window).mousedown -> $(document.body).addClass "mousedown"
    $(window).mouseup -> $(document.body).removeClass "mousedown"