Meteor.startup(function () {
  ServiceConfiguration.configurations.upsert(
    {service: "google"},
    {$set: {clientId: Meteor.settings.googleClientId, secret: Meteor.settings.googleSecret}}
  );

  Accounts.config({
    restrictCreationByEmailDomain: 'q42.nl'
  });
});