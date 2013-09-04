Meteor.startup ->
    #Employees.remove({})
    if Employees.find().count() is 0
        names = ["Alexander Overvoorde", "Arian van Gend", "Arjen van der Ende", "Bas Warmerdam", "Benjamin de Jager", "Bob van Oorschot", "Chris Waalberg", "Christiaan Hees", "Coen Bijpost", "Cynthia Wijntje", "Elaine Oliver", "Frank Raterink", "Gerard Dorst", "Guus Goossens", "Herman Banken", "Huib Piguillet", "Jaap Mengers", "Jaap Taal", "Jan-Willem Maneschijn", "Jasper Haggenburg", "Jasper Kaizer", "Jeroen Gijsman", "Johan Huijkman", "Kamil Afsar", "Kars Veling", "Katja Hollaar", "Korjan van Wieringen", "Laurens van den Oever", "Leonard Punt", "Lukas van Driel", "Marcel Duin", "Mark van Straten", "Martijn Laarman", "Martijn van Steenbergen", "Martin Kool", "Matthijs van der Meulen", "Michiel Post", "Rahul Choudhury", "Remco Veldkamp", "Richard Lems", "Roelf-Jan de Vries", "Sander de Vos", "Sjoerd Visscher", "Stef Brooijmans", "Suzanne Waalberg", "Tim Logtenberg", "Tim van Deursen", "Tim van Steenis", "Tom Lokhorst", "Wilbert Mekenkamp"]
        _.each names, (name) -> Employees.insert name: name, pos: x: 0, y: 0

Meteor.methods
    updatePosition: (id, x, y) ->
        if Meteor.user()?.services.google.email.match /@q42.nl$/
            Employees.update id, { $set: { "pos.x": x, "pos.y": y } }