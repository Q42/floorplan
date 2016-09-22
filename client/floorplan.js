var headerHeight;

//this.Employees = new Meteor.Collection("Employees", this.q42nl);
//this.q42nl = DDP.connect("http://q42.nl");
//this.q42nl.subscribe("employees");

Accounts.ui.config({
  requestOfflineToken: {
    google: true
  },
  forceApprovalPrompt: {
    google: true
  }
});

CompanyApi.subscribe("employees.all", null, {
  fields: {
    name: 1,
    shortName: 1,
    gravatar: 1
  }
});


headerHeight = 120 + 50;

Meteor.startup(function () {
  Session.setDefault("createPartner", false);
  Session.setDefault("selectedLocation", "q070");
  Session.setDefault("draggin", false);
  Session.setDefault("draggingId", null);
  return Session.setDefault("windowWidth", $(window).width());
});
Template.header.events({
  "click .add": function (evt) {
    evt.preventDefault();
    return Session.set("createPartner", !Session.get("createPartner"));
  },
  "click nav a:not(.button)": function (evt) {
    Session.set("selectedLocation", $(evt.target).data("location"));
    return evt.preventDefault();
  }
});

Template.header.helpers({
  selected: function (str) {
    if (Session.equals("selectedLocation", str)) {
      return "selected";
    }
  },
  showCreatePartnerForm: function () {
    return Session.equals("createPartner", true);
  }
});

Template.qers.helpers({
  qer: function () {
    return Employees.find({}, {
      sort: {
        name: 1
      }
    });
  },
  image: function () {
    return this.handle + "gif.gif";
  }
});

Template.qers.dragging = function () {
  return Session.equals("dragging", true);
};
Template.qers.positioning = function () {
  var ref, ref1;
  return ((ref = this.floorplan[Session.get("selectedLocation")]) != null ? ref.x : void 0) !== 0 && ((ref1 = this.floorplan[Session.get("selectedLocation")]) != null ? ref1.y : void 0) !== 0;
};
Template.qers.posX = function () {
  var ref;
  return (((ref = this.floorplan[Session.get("selectedLocation")]) != null ? ref.x : void 0) * Session.get("windowWidth")) || 0;
};
Template.qers.posY = function () {
  var ref;
  return (((ref = this.floorplan[Session.get("selectedLocation")]) != null ? ref.y : void 0) * Session.get("windowWidth") - 50 + headerHeight) || 0;
};

Template.partners.helpers({
  partner: function () {
    return Partners.find({}, {
      sort: {
        name: 1
      }
    });
  }
});

Template.partners.dragging = function () {
  return Session.equals("dragging", true);
};
Template.partners.positioning = function () {
  var ref, ref1;
  return ((ref = this.floorplan[Session.get("selectedLocation")]) != null ? ref.x : void 0) !== 0 && ((ref1 = this.floorplan[Session.get("selectedLocation")]) != null ? ref1.y : void 0) !== 0;
};
Template.partners.posX = function () {
  var ref;
  return (((ref = this.floorplan[Session.get("selectedLocation")]) != null ? ref.x : void 0) * Session.get("windowWidth")) || 0;
};
Template.partners.posY = function () {
  var ref;
  return (((ref = this.floorplan[Session.get("selectedLocation")]) != null ? ref.y : void 0) * Session.get("windowWidth") + headerHeight) || 0;
};
Template.partners.initials = function () {
  return _.map(this.name.split(" "), function (w) {
    return w[0];
  }).join("").toUpperCase();
};

Template.floorplan.helpers({
  floorplan: function () {
    return "floorplan-" + Session.get("selectedLocation");
  }
});

Template.createPartner.events({
  "click #add": function (evt) {
    Meteor.call("createPartner", $("#partner-name").val());
    evt.preventDefault();
    $("#partner-name").val("");
    return Session.set("createPartner", false);
  },
  "click #cancel": function () {
    return Session.set("createPartner", false);
  }
});
Template.floorplan.events({
  "mouseup, touchend": function () {
    return Session.set("draggingId", null);
  },
  "mousemove, touchmove": function (evt) {
    var imageW, newX, newY;
    if (!Meteor.userId()) {
      return;
    }
    imageW = Session.get("windowWidth");
    newX = evt.pageX / imageW;
    newY = evt.pageY < headerHeight ? 0 : (evt.pageY - headerHeight) / imageW;
    if (Session.get("draggingId")) {
      if (Employees.findOne(Session.get("draggingId"))) {
        q42nl.call("updatePosition", Session.get("draggingId"), newX, newY, Session.get("selectedLocation"));
      } else {
        Meteor.call("updatePartnerPosition", Session.get("draggingId"), newX, newY, Session.get("selectedLocation"));
      }
      return evt.preventDefault();
    }
  }
});
Template.qers.events({
  "mousedown .qer, touchstart .qer": function (evt) {
    return Session.set("draggingId", this._id);
  }
});
Template.partners.events({
  "mousedown .qer, touchstart .qer": function (evt) {
    return Session.set("draggingId", this._id);
  }
});
$(window).resize(function () {
  return Session.set("windowWidth", $(window).width());
});
$(window).mousedown(function () {
  return $(document.body).addClass("mousedown");
});
$(window).mouseup(function () {
  return $(document.body).removeClass("mousedown");
});