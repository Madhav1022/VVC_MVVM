
class ContactModel {
  final String tableContact = 'tbl_contact';
  final String tblContactColId = 'id';
  final String tblContactColName = 'name';
  final String tblContactColMobile = 'mobile';
  final String tblContactColEmail = 'email';
  final String tblContactColAddress = 'address';
  final String tblContactColCompany = 'company';
  final String tblContactColDesignation = 'designation';
  final String tblContactColWebsite = 'website';
  final String tblContactColImage = 'image';
  final String tblContactColFavorite = 'favorite';

  int? id;
  String name;
  String mobile;
  String email;
  String address;
  String company;
  String designation;
  String website;
  String image;
  bool favorite;

  ContactModel({
    this.id,
    required this.name,
    required this.mobile,
    this.email = '',
    this.address = '',
    this.company = '',
    this.designation = '',
    this.website = '',
    this.image = '',
    this.favorite = false,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'mobile': mobile,
      'email': email,
      'address': address,
      'company': company,
      'designation': designation,
      'website': website,
      'image': image,
      'favorite': favorite ? 1 : 0,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory ContactModel.fromMap(Map<String, dynamic> map) => ContactModel(
    id: map['id'],
    name: map['name'],
    mobile: map['mobile'],
    email: map['email'],
    address: map['address'],
    company: map['company'],
    designation: map['designation'],
    website: map['website'],
    image: map['image'],
    favorite: map['favorite'] == 1,
  );
}