

if Meteor.isClient
    @q42nl = DDP.connect "http://q42.nl"
    @Employees = new Meteor.Collection "Employees", @q42nl
    @q42nl.subscribe "employees"

    headerHeight = 120 + 42

    Meteor.startup ->
        Session.setDefault "draggingId", null
        Session.setDefault "windowWidth", $(window).width()

    Template.qers.qer = -> @Employees.find({}, sort: name: 1)

    Template.qers.dragging = -> @floorplan.x isnt 0 and @floorplan.y isnt 0

    Template.qers.posX = -> @floorplan.x * Session.get("windowWidth")
    Template.qers.posY = -> @floorplan.y * Session.get("windowWidth") + headerHeight

    Template.qers.avatar_static = -> @imageStatic or @handle + "zw.jpg"

    Template.floorplan.events
        "mousemove, touchmove": (evt, template) ->
            return unless Session.get("draggingId") and Meteor.user()?.services?.google?.email?.match(/@q42.nl$/)
            imageW = Session.get("windowWidth")
            newX = (evt.pageX / imageW)
            newY = if evt.pageY < headerHeight then 0 else (evt.pageY - headerHeight) / imageW
            q42nl.call "updatePosition", Session.get("draggingId"), newX, newY
            evt.preventDefault() # prevent phones from scrolling while touchmoving
        "mouseup, touchend": -> Session.set "draggingId", null

    Template.qers.events
        "mousedown .qer, touchstart .qer": (evt) -> Session.set "draggingId", @_id

    $(window).resize -> Session.set "windowWidth", $(window).width()

    $(window).mousedown -> $(document.body).addClass "mousedown"
    $(window).mouseup -> $(document.body).removeClass "mousedown"