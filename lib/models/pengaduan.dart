class Pengaduan {
  final int id;
  final String kategoriMasalah;
  final String deskripsi;
  final String status_pengajuan;

  Pengaduan({
    required this.id,
    required this.kategoriMasalah,
    required this.deskripsi,
    required this.status_pengajuan,
  });

  factory Pengaduan.fromJson(Map<String, dynamic> json) {
    return Pengaduan(
      id: json['ID_Pengaduan'] ?? 0,
      kategoriMasalah: json['kategori_masalah'] ?? 'Tidak ada kategori',
      deskripsi: json['deskripsi'] ?? 'Tidak ada deskripsi',
      status_pengajuan: json['status_pengajuan'] ?? 'pending',
    );
  }
}