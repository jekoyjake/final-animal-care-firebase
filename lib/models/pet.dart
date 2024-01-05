class PetModel {
  final String id;
  final String name;
  final String species;
  final int age;
  final String breed;
  final String photoUrl;
  final String ownerUid;

  PetModel(
      {required this.id,
      required this.name,
      required this.species,
      required this.age,
      required this.breed,
      required this.photoUrl,
      required this.ownerUid});
}
