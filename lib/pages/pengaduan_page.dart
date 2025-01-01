import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/pengaduan.dart';

class PengaduanPage extends StatefulWidget {
  final String token;

  PengaduanPage({required this.token});

  @override
  _PengaduanPageState createState() => _PengaduanPageState();
}

class _PengaduanPageState extends State<PengaduanPage> {
  final ApiService apiService = ApiService();
  List<Pengaduan> pengaduanList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPengaduan();
  }

  Future<void> _loadPengaduan() async {
    try {
      final List<Pengaduan> pengaduan =
          await apiService.getPengaduan(widget.token);
      setState(() {
        pengaduanList = pengaduan;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading pengaduan: $e')),
      );
    }
  }

  Future<void> _showDeleteConfirmation(Pengaduan pengaduan) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus pengaduan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await apiService.deletePengaduan(widget.token, pengaduan.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Pengaduan berhasil dihapus'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
                await _loadPengaduan();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreatePengaduanDialog() async {
    final formKey = GlobalKey<FormState>();
    String kategoriMasalah = 'Keamanan';
    String deskripsi = '';

    final List<String> kategoriOptions = [
      'Keamanan',
      'Kebersihan',
      'Fasilitas Umum',
      'Lainnya'
    ];

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Buat Pengaduan Baru'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Kategori Masalah',
                  border: OutlineInputBorder(),
                ),
                value: kategoriMasalah,
                items: kategoriOptions.map((String kategori) {
                  return DropdownMenuItem<String>(
                    value: kategori,
                    child: Text(kategori),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    kategoriMasalah = newValue;
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pilih kategori masalah';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi harus diisi';
                  }
                  return null;
                },
                onSaved: (value) => deskripsi = value ?? '',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                Navigator.pop(context);

                try {
                  await apiService.createPengaduan(
                    widget.token,
                    kategoriMasalah,
                    deskripsi,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Pengaduan berhasil dibuat'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                  await _loadPengaduan();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Pengaduan'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : pengaduanList.isEmpty
              ? Center(child: Text('Tidak ada pengaduan'))
              : ListView.builder(
                  itemCount: pengaduanList.length,
                  itemBuilder: (context, index) {
                    final pengaduan = pengaduanList[index];
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(pengaduan.kategoriMasalah),
                        subtitle: Text(pengaduan.deskripsi),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(pengaduan.status_pengajuan),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteConfirmation(pengaduan),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePengaduanDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
