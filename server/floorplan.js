Meteor.methods({
  createPartner: function (name) {
    var floorplan;
    if (!Meteor.userId()) {
      return;
    }
    floorplan = {
      q070: {
        x: 0,
        y: 0
      },
      q020bg: {
        x: 0,
        y: 0
      },
      q020boven: {
        x: 0,
        y: 0
      }
    };
    return Partners.insert({
      name: name,
      floorplan: floorplan
    });
  },
  updatePartnerPosition: function (id, x, y, loc) {
    var obj;
    if (!Meteor.userId()) {
      return;
    }
    obj = {};
    obj["floorplan." + loc] = {};
    obj["floorplan." + loc].x = x;
    obj["floorplan." + loc].y = y;
    return Partners.update(id, {
      $set: obj
    });
  },
  removePartner: function (name) {
    if (!Meteor.userId()) {
      return;
    }
    return Partners.remove({
      name: name
    });
  }
});
