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

Meteor.startup(function() {
  FloorplanLocation.allow({
    insert: function (userId) {
      return userId
    },
    update: function (userId) {
      return userId
    }
  });

  Partners.allow({
    insert: function (userId) {
      return userId
    },
    update: function (userId) {
      return userId
    }
  });


  FloorplanLocation.deny({
    remove() { return true; },
  });

  Partners.deny({
    remove() { return true; },
  });
});

Meteor.publish('floorplan.location', function(allUsersList) {
  if (!this.userId) {
    return this.ready();
  }

  const numberOfFloorplans = FloorplanLocation.find({_id : { $in: allUsersList}}).fetch();
  console.log('floorplan.location check:', numberOfFloorplans.length, allUsersList.length);
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
  removePartner: function (id) {
    if (!Meteor.userId()) {
      return;
    }
    return Partners.remove({
      _id: id
    });
  }
});
