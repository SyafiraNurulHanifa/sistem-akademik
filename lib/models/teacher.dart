class Teacher {
  final int id;
  final String nama;
  final String email;
  final String? mapel;
  final String? telepon;
  final String? nip;
  final String? jabatan;
  final String? tahunMasuk;
  final String? fotoProfil;

  Teacher({
    required this.id,
    required this.nama,
    required this.email,
    this.mapel,
    this.telepon,
    this.nip,
    this.jabatan,
    this.tahunMasuk,
    this.fotoProfil,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      mapel: json['mapel'],
      telepon: json['telepon'],
      nip: json['nip'],
      jabatan: json['jabatan'],
      tahunMasuk: (json['tahun_masuk'] ?? json['tahunMasuk'])?.toString(),
      fotoProfil: json['foto_profil'] ?? json['fotoProfil'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'mapel': mapel,
      'telepon': telepon,
      'nip': nip,
      'jabatan': jabatan,
      'tahun_masuk': tahunMasuk,
      'foto_profil': fotoProfil,
    };
  }
}
