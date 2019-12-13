class ContactModel {
  String ContactId;
  String ContactImage;
  String ContactName;
  String ContactEmail;
  String ContactPhone;
  String ContactDateBirth;
  String ContactGender;
  String ContactNote;

  ContactModel({
    this.ContactId,
    this.ContactImage,
    this.ContactName,
    this.ContactEmail,
    this.ContactPhone,
    this.ContactDateBirth,
    this.ContactGender,
    this.ContactNote,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
        ContactId: json["ContactId"],
        ContactImage: json["ContactImage"],
        ContactName: json["ContactName"],
        ContactEmail: json["ContactEmail"],
        ContactPhone: json["ContactPhone"],
        ContactDateBirth: json["ContactDateBirth"],
        ContactGender: json["ContactGender"],
        ContactNote: json["ContactNote"]);
  }
}