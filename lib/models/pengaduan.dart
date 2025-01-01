class Pengaduan {
  final int id;
  final String kategoriMasalah;
  final String deskripsi;
  final String status_pengajuan;

  Pengaduan({
    required this.id,
    required this.kategoriMasalah,
    required this.deskripsi,
    this.status_pengajuan = 'pending',
  });

  factory Pengaduan.fromJson(Map<String, dynamic> json) {
    return Pengaduan(
      id: json['ID_Pengaduan'],
      kategoriMasalah: json['kategori_masalah'],
      deskripsi: json['deskripsi'],
      status_pengajuan: json['status_pengajuan'] ?? 'pending',
    );
  }
}