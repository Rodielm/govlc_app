class Monument {
  String type;
  Properties properties;
  Geometry geometry;

  Monument({this.type, this.properties, this.geometry});

  Monument.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    properties = json['properties'] != null
        ? new Properties.fromJson(json['properties'])
        : null;
    geometry = json['geometry'] != null
        ? new Geometry.fromJson(json['geometry'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    if (this.properties != null) {
      data['properties'] = this.properties.toJson();
    }
    if (this.geometry != null) {
      data['geometry'] = this.geometry.toJson();
    }
    return data;
  }
}

class Properties {
  String nombre;
  String numpol;
  String idnotes;
  String codvia;
  String telefono;
  String ruta;

  Properties(this.nombre, this.numpol, this.idnotes, this.codvia, this.telefono,
      this.ruta);

  Properties.fromJson(Map<String, dynamic> json) {
    nombre = json['nombre'];
    numpol = json['numpol'];
    idnotes = json['idnotes'];
    codvia = json['codvia'];
    telefono = json['telefono'];
    ruta = json['ruta'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nombre'] = this.nombre;
    data['numpol'] = this.numpol;
    data['idnotes'] = this.idnotes;
    data['codvia'] = this.codvia;
    data['telefono'] = this.telefono;
    data['ruta'] = this.ruta;
    return data;
  }
}

class Geometry {
  String type;
  List<double> coordinates;

  Geometry({this.type, this.coordinates});

  Geometry.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    coordinates = json['coordinates'].cast<double>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['coordinates'] = this.coordinates;
    return data;
  }
}
