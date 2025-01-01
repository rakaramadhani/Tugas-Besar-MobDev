import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/pengaduan.dart';

class PengaduanPage extends StatefulWidget {
  final String token;

  const PengaduanPage({super.key, required this.token});

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
      final List<Pengaduan> pengaduan = await apiService.getPengaduan(widget.token);
      if (mounted) {
        setState(() {
          pengaduanList = pengaduan;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading pengaduan: $e')),
        );
      }
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
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() {
                isLoading = true;
              });
              try {
                await apiService.deletePengaduan(widget.token, pengaduan.id);
                await _loadPengaduan();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Pengaduan berhasil dihapus')),
                );
              } catch (e) {
                setState(() {
                  isLoading = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: Text('Hapus'),
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
                decoration: InputDecoration(labelText: 'Kategori Masalah'),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Deskripsi'),
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
          TextButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                Navigator.pop(context);
                setState(() {
                  isLoading = true;
                });
                try {
                  await apiService.createPengaduan(
                    widget.token,
                    kategoriMasalah,
                    deskripsi,
                  );
                  await _loadPengaduan();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Pengaduan berhasil dibuat')),
                  );
                } catch (e) {
                  setState(() {
                    isLoading = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
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
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: pengaduanList.length,
              itemBuilder: (context, index) {
                final pengaduan = pengaduanList[index];
                return Card(
                  child: ListTile(
                    title: Text(pengaduan.kategoriMasalah),
                    subtitle: Text(pengaduan.deskripsi),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(pengaduan.status_pengajuan),
                        IconButton(
                          icon: Icon(Icons.delete),
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
