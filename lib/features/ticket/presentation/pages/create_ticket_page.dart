import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/features/auth/presentation/providers/auth_provider.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/features/ticket/data/repositories/ticket_repository.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/features/ticket/presentation/providers/ticket_provider.dart';

class CreateTicketPage extends ConsumerStatefulWidget {
  const CreateTicketPage({super.key});

  @override
  ConsumerState<CreateTicketPage> createState() => _CreateTicketPageState();
}

class _CreateTicketPageState extends ConsumerState<CreateTicketPage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _priority = 'medium';
  String _category = 'Hardware';
  bool _isLoading = false;
  final List<String> _attachments = [];

  final List<String> _priorities = ['low', 'medium', 'high', 'critical'];
  final List<String> _categories = [
    'Hardware', 'Software', 'Network', 'Email', 'Lainnya'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // Kamera — di emulator tidak ada kamera fisik, di device asli bisa
  Future<void> _pickFromCamera() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image != null && mounted) {
        setState(() => _attachments.add(image.name));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Foto "${image.name}" berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Kamera tidak dapat diakses di emulator. '
              'Coba di device asli, atau gunakan Galeri.',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Galeri
  Future<void> _pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null && mounted) {
        setState(() => _attachments.add(image.name));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Foto "${image.name}" berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Galeri tidak dapat dibuka.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Tiket Baru')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Judul Tiket',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Masukkan judul masalah',
                ),
                validator: (v) =>
                    v!.isEmpty ? 'Judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),

              const Text('Deskripsi',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Jelaskan masalah secara detail',
                ),
                validator: (v) =>
                    v!.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),

              const Text('Kategori',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _category,
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
                decoration: const InputDecoration(),
              ),
              const SizedBox(height: 16),

              const Text('Prioritas',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _priorities.map((p) {
                  return ChoiceChip(
                    label: Text(p.toUpperCase()),
                    selected: _priority == p,
                    selectedColor: _getPriorityColor(p).withOpacity(0.2),
                    onSelected: (_) => setState(() => _priority = p),
                    labelStyle: TextStyle(
                      color: _priority == p ? _getPriorityColor(p) : null,
                      fontWeight: _priority == p
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              const Text('Lampiran (Opsional)',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),

              // Dua tombol terpisah — Galeri dan Kamera
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickFromGallery,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Galeri'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickFromCamera,
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Kamera'),
                    ),
                  ),
                ],
              ),

              // Info emulator
              const SizedBox(height: 6),
              Text(
                '* Kamera hanya berfungsi di device asli (bukan emulator)',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),

              if (_attachments.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: List.generate(
                    _attachments.length,
                    (i) => Chip(
                      avatar: const Icon(Icons.image_outlined, size: 16),
                      label: Text(
                        _attachments[i],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () =>
                          setState(() => _attachments.removeAt(i)),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _isLoading = true);
                            try {
                              final userId =
                                  ref.read(authProvider).user?.id ?? '1';
                              final token = ref.read(tokenProvider);
                              await TicketRepository().createTicket(
                                title: _titleController.text,
                                description: _descController.text,
                                priority: _priority,
                                category: _category,
                                createdBy: userId,
                                token: token,
                              );
                              ref.invalidate(ticketNotifierProvider);
                              ref.invalidate(ticketStatsProvider);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Tiket berhasil dibuat!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                Navigator.pop(context);
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            } finally {
                              if (mounted)
                                setState(() => _isLoading = false);
                            }
                          }
                        },
                  icon: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.send_outlined),
                  label: const Text('Kirim Tiket'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(String p) {
    switch (p) {
      case 'low': return Colors.green;
      case 'medium': return Colors.orange;
      case 'high': return Colors.red;
      case 'critical': return const Color(0xFF7C0000);
      default: return Colors.grey;
    }
  }
}