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
      final List<Pengaduan> pengaduan = await apiService.getPengaduan(widget.token);
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
                        trailing: Text(pengaduan.status_pengajuan),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implementasi tambah pengaduan
        },
        child: Icon(Icons.add),
      ),
    );
  }
}