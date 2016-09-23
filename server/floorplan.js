const floorplan = {
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

Meteor.publish('floorplan.location', function(allUsersList) {
  if (!this.userId) {
    return this.ready();
  }

  const numberOfFloorplans = FloorplanLocation.find({_id : { $in: allUsersList}}).fetch();
  if (numberOfFloorplans.length < allUsersList.length) {
    //some floorplans are missing
    createAllFloorplans(allUsersList);
  }

  return FloorplanLocation.find({});
});

Meteor.publish('partners.location', function() {
  return Partners.find({});
});

function createAllFloorplans(allUsersList) {
  _.each(allUsersList, (userId) => {
    const result = FloorplanLocation.findOne(userId);
    if (!result) {
      createFloorplan(userId);
    }
  });
}

function createFloorplan(userId) {
  var obj ={};
  obj._id = userId;
  obj.floorplan = _.clone(floorplan);
  FloorplanLocation.insert(obj);
}

Meteor.methods({
  createPartner: function (name) {
    if (!Meteor.userId()) {
      return;
    }
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
  removePartner: function (id) {
    if (!Meteor.userId()) {
      return;
    }
    return Partners.remove({
      _id: id
    });
  },
  updateQerPosition: function (id, x, y, loc) {
    var obj;
    if (!Meteor.userId()) {
      return;
    }
    obj = {};
    obj["floorplan." + loc] = {};
    obj["floorplan." + loc].x = x;
    obj["floorplan." + loc].y = y;
    return FloorplanLocation.update(id, {
      $set: obj
    });
  }
});
