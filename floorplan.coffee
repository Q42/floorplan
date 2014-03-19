Accounts.config
    restrictCreationByEmailDomain: "q42.nl"
    loginExpirationInDays: null

@Partners = new Meteor.Collection "partners"

if Meteor.isClient
    @q42nl = DDP.connect "http://q42.nl"
    @Employees = new Meteor.Collection "Employees", @q42nl
    @q42nl.subscribe "employees"

    headerHeight = 120 + 50

    Meteor.startup ->
        Session.setDefault "createPartner", no
        Session.setDefault "selectedLocation", "q070"
        Session.setDefault "draggin", no
        Session.setDefault "draggingId", null
        Session.setDefault "windowWidth", $(window).width()

    Template.header.events
        "click .add": (evt) ->
            evt.preventDefault()
            Session.set "createPartner", not Session.get("createPartner")
        "click nav a:not(.button)": (evt) ->
            Session.set "selectedLocation", $(evt.target).data("location")
            evt.preventDefault()

    Template.header.selected = (str) -> "selected" if Session.equals "selectedLocation", str
    Template.header.showCreatePartnerForm = -> Session.equals "createPartner", yes

    Template.qers.qer = -> @Employees.find {}, sort: name: 1
    Template.qers.dragging = -> Session.equals("dragging", yes)
    Template.qers.positioning = -> @floorplan[Session.get("selectedLocation")]?.x isnt 0 and @floorplan[Session.get("selectedLocation")]?.y isnt 0
    Template.qers.posX = -> (@floorplan[Session.get("selectedLocation")]?.x * Session.get("windowWidth")) or 0
    Template.qers.posY = -> (@floorplan[Session.get("selectedLocation")]?.y * Session.get("windowWidth") - 50 + headerHeight) or 0
    Template.qers.image = -> @imageAnimated or (@handle + "gif.gif")

    Template.partners.partner = -> @Partners.find {}, sort: name: 1
    Template.partners.dragging = -> Session.equals("dragging", yes)
    Template.partners.positioning = -> @floorplan[Session.get("selectedLocation")]?.x isnt 0 and @floorplan[Session.get("selectedLocation")]?.y isnt 0
    Template.partners.posX = -> (@floorplan[Session.get("selectedLocation")]?.x * Session.get("windowWidth")) or 0
    Template.partners.posY = -> (@floorplan[Session.get("selectedLocation")]?.y * Session.get("windowWidth") + headerHeight) or 0
    Template.partners.initials = -> _.map(@name.split(" "), (w) -> w[0]).join("").toUpperCase()

    Template.floorplan.floorplan = -> "floorplan-" + Session.get("selectedLocation")

    Template.createPartner.events
        "click #add": (evt) ->
            Meteor.call "createPartner", $("#partner-name").val()
            evt.preventDefault()
            $("#partner-name").val("")
            Session.set "createPartner", no
        "click #cancel": -> Session.set "createPartner", no

    Template.floorplan.events
        "mouseup, touchend": -> Session.set "draggingId", null
        "mousemove, touchmove": (evt) ->
            return unless Meteor.userId()

            imageW = Session.get("windowWidth")
            newX = (evt.pageX / imageW)
            newY = if evt.pageY < headerHeight then 0 else (evt.pageY - headerHeight) / imageW

            if Session.get("draggingId")
                if Employees.findOne Session.get("draggingId")
                    q42nl.call "updatePosition", Session.get("draggingId"), newX, newY, Session.get("selectedLocation")
                else
                    Meteor.call "updatePartnerPosition", Session.get("draggingId"), newX, newY, Session.get("selectedLocation")

                # prevent phones from scrolling while touchmoving
                evt.preventDefault()

    Template.qers.events
        "mousedown .qer, touchstart .qer": (evt) -> Session.set "draggingId", @_id
    Template.partners.events
        "mousedown .qer, touchstart .qer": (evt) -> Session.set "draggingId", @_id

    $(window).resize -> Session.set "windowWidth", $(window).width()

    $(window).mousedown -> $(document.body).addClass "mousedown"
    $(window).mouseup -> $(document.body).removeClass "mousedown"



if Meteor.isServer

    Meteor.methods
        createPartner: (name) ->
            return unless Meteor.userId()
            floorplan =
                q070: x: 0, y: 0
                q020bg: x: 0, y: 0
                q020boven: x: 0, y: 0
            Partners.insert name: name, floorplan: floorplan
        updatePartnerPosition: (id, x, y, loc) ->
            return unless Meteor.userId()
            obj = {}
            obj["floorplan." + loc] = {}
            obj["floorplan." + loc].x = x
            obj["floorplan." + loc].y = y
            Partners.update id, $set: obj
        removePartner: (name) ->
            return unless Meteor.userId()
            Partners.remove name: name