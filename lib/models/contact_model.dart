class ContactModel {
  int?    id;
  String? firebaseId;
  String  name;
  String  mobile;
  String  email;
  String  address;
  String  company;
  String  designation;
  String  website;
  String  image;
  bool    favorite;

  ContactModel({
    this.id,
    this.firebaseId,
    required this.name,
    required this.mobile,
    this.email       = '',
    this.address     = '',
    this.company     = '',
    this.designation = '',
    this.website     = '',
    this.image       = '',
    this.favorite    = false,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name':        name,
      'mobile':      mobile,
      'email':       email,
      'address':     address,
      'company':     company,
      'designation': designation,
      'website':     website,
      'image':       image,
      'favorite':    favorite ? 1 : 0,
      'firebase_id': firebaseId,    // ← new
    };
    if (id != null)    map['id'] = id;
    return map;
  }

  factory ContactModel.fromMap(Map<String, dynamic> map) => ContactModel(
    id:          map['id'] as int?,
    firebaseId:  map['firebase_id'] as String?,  // ← new
    name:        map['name']        as String,
    mobile:      map['mobile']      as String,
    email:       map['email']       as String,
    address:     map['address']     as String,
    company:     map['company']     as String,
    designation: map['designation'] as String,
    website:     map['website']     as String,
    image:       map['image']       as String,
    favorite:    (map['favorite']   as int) == 1,
  );
}
