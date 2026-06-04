import 'package:flutter/material.dart';
 
// class 1 (ResetPasswordPage) - wadah
// Stateful -> Halaman yg isinya bisa berubah-ubah (Kalau ada sesuatu yang berubah di layar). Contoh hal reset password - ada loading spinner yg muncul/hilang, ada tampilan yg berubah dari form ke "email terkirim"
// Stateless -> Halaman yg isinya tidak pernah berubah. Contoh halaman "Tentang Aplikasi" yang hanya menampilkan teks statis
// super.key -> ID Unik utk setiap widget - utk melacak widget mana yg perlu diupdate
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});
 
  @override
  // createState() = flutter memanggil sekali saja saat halaman pertama dibuat
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}
 
// var yang bisa berubah dan mempengaruhi tampilan
// class 2 (_ResetPasswordPageState) - core isi nya
// tanda (_) didepan artinya private. hanya bisa dipakai di class ini saja
class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _emailController = TextEditingController(); // TextEditingController -> pengontrol utk text field. kita bisa baca apa yg diketik user
  final _formKey = GlobalKey<FormState>(); // utk memicu validasi semua field dari form sekaligus
  bool _isLoading = false; // variabel untuk tahu apakah sedang loading atau tidak. Digunakan untuk menampilkan spinner atau tombol normal.
  bool _emailSent = false; // variabel untuk tahu apakah email sudah "terkirim". Kalau true, tampilan berubah dari form ke halaman sukses.
 
  // Dispose utk membersihkan resource, dispose() dipanggil saat seluruh halaman ResetPasswordPage ditutup/dihapus dr layar.
  // Contoh : Navigator.pop(context) -> waktu kita klik "Kembali ke Login", dispose() baru dijalankan
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1A1D3B),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _emailSent ? _buildSuccessView() : _buildFormView(),
        ),
      ),
    );
  }
 
  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20), // jarak dalam (spt CSS padding)
            decoration: BoxDecoration(
              color: const Color(0xFFFF9F43).withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.lock_reset_rounded,
              size: 48,
              color: Color(0xFFFF9F43),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Reset Password',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1D3B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Masukkan email Anda dan kami akan mengirimkan link reset password.',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Email',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF1A1D3B),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Masukkan email Anda',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon:
                  Icon(Icons.email_outlined, color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                    color: Color(0xFF4F7EFF), width: 1.5),
              ),
            ),
            validator: (v) {
              if (v!.isEmpty) return 'Email tidak boleh kosong';
              if (!v.contains('@')) return 'Format email tidak valid';
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() => _isLoading = true);
                        await Future.delayed(const Duration(seconds: 2));
                        setState(() {
                          _isLoading = false;
                          _emailSent = true; // ganti tampilan ke sukses
                        });
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F7EFF),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text(
                      'Kirim Link Reset',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _buildSuccessView() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            size: 56,
            color: Color(0xFF10B981),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Email Terkirim!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1D3B),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Link reset password telah dikirim ke\n${_emailController.text}',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade500, height: 1.5),
        ),
        const SizedBox(height: 36),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F7EFF),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Kembali ke Login',
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => setState(() => _emailSent = false),
          child: const Text(
            'Kirim ulang',
            style: TextStyle(color: Color(0xFF4F7EFF)),
          ),
        ),
      ],
    );
  }
}
 