# SEAPEDIA E-Commerce Platform

SEAPEDIA adalah platform *marketplace multi-role* yang dibangun dengan Flutter, Riverpod, go_router, dan Supabase. Platform ini mengakomodasi 4 jenis pengguna utama: Admin, Seller, Buyer, dan Driver. Proyek ini menyelesaikan seluruh Level 1 hingga Level 7 dari tahap implementasi UI hingga *Security Hardening*.

---

## 1. Persiapan & Cara Setup

### Prasyarat
- Flutter SDK (Versi terbaru stabil)
- Proyek Supabase aktif

### Konfigurasi Kredensial Supabase
1. Buat proyek di [Supabase](https://supabase.com).
2. Salin *URL* dan *Anon Key* dari pengaturan API Supabase.
3. Buka file `lib/main.dart` dan masukkan kredensial:
```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

### Inisialisasi Database (Demo Seed Data)
Buka menu SQL Editor di Supabase Dashboard dan eksekusi skrip:
- `level1-schema.sql` (sampai Level 6)
- `level7-final-seed.sql` (untuk memasukkan kategori produk & voucher dasar).

---

## 2. Role-Based Access Control (RBAC) & Demo Akun

Setiap peran diverifikasi di *server-side* menggunakan **Row Level Security (RLS)** dan di-*client-side* melalui `go_router` redirect. Jika peran aktif tidak sesuai dengan *URL path*, pengguna akan dialihkan kembali.

Berikut adalah daftar peran dan hak aksesnya:
- **Buyer**: Dapat mencari produk, menggunakan keranjang belanja, checkout, memberi ulasan, dan mengelola profil/dompet.
- **Seller**: Dapat membuat toko, menambah/mengubah produk, mengelola pesanan masuk, dan melihat laporan keuangan.
- **Driver**: Dapat mencari pekerjaan pengiriman (*job*), menyelesaikan pengiriman, dan melihat pendapatan harian.
- **Admin**: Dapat mengelola sistem voucher/promo, dan memproses *refund* otomatis untuk pesanan yang kadaluarsa (overdue).

> **Akses Demo Akun**: Anda dapat mendaftar langsung lewat aplikasi (Form Register). Aplikasi otomatis akan menyuntikkan *role* berdasarkan kotak centang (checkbox) yang dipilih saat pendaftaran. Akun bisa memiliki peran ganda (Multi-Role), dan Anda dapat beralih peran lewat halaman profil (*Role Selection*).

---

## 3. Dokumentasi Keputusan Bisnis & Fitur

### A. Single-Store Checkout, Diskon & PPN 12%
- Sistem checkout hanya mengizinkan pembelian dari **satu toko per transaksi**. Jika ada produk dari toko berbeda di keranjang, pengguna wajib memilih produk dari toko yang sama sebelum checkout.
- Total Pesanan (Subtotal) = Jumlah `(Harga Produk * Kuantitas)`.
- Diskon Promo dipotong dari **Subtotal murni**, sebelum biaya lainnya.
- **PPN 12%** dibebankan berdasarkan `(Subtotal - Diskon)`.
- Pajak dan diskon ditambahkan secara otomatis pada saat perhitungan total akhir. Pembayaran murni menggunakan **Dompet Internal (Wallet)**.

### B. Aturan Earning Driver
- Pendapatan Driver adalah murni dari **Ongkos Kirim**. Biaya pengiriman sudah ditetapkan *flat* berdasarkan SLA (misal: Instant = 20rb). Saat status pesanan berubah menjadi `Pesanan Selesai`, ongkos kirim tersebut sepenuhnya dicatat sebagai *income* bagi Driver yang mengambil pekerjaan tersebut dan langsung masuk ke saldo dompet Driver.

### C. Aturan SLA Overdue (Auto Refund)
Sistem memiliki SLA (Service Level Agreement) waktu pengiriman:
- **Instant**: Overdue jika belum selesai dalam > 1 hari.
- **Next Day**: Overdue jika belum selesai dalam > 2 hari.
- **Regular**: Overdue jika belum selesai dalam > 5 hari.

**Simulasi Waktu:** Admin Dashboard menyediakan tombol "Maju 1 Hari". Ini akan menambahkan variabel *offset* di sisi Flutter untuk mensimulasikan percepatan waktu. Pesanan yang melewati batas SLA otomatis muncul di Dashboard Admin, dan Admin dapat menekan tombol **Proses Refund**. Dana akan dikembalikan ke dompet Buyer dan stok produk direstorasi.

---

## 4. Keamanan & Mitigasi (Level 7)

Aplikasi telah diperkuat keamanannya dari serangan injeksi dan modifikasi lintas pengguna.

1. **Pencegahan SQL Injection**: Aplikasi secara eksklusif menggunakan Supabase *Postgrest API* (`.from('table').select(...)`) dari SDK resmi Flutter. Semua parameter di-*bind* di belakang layar dengan aman, menihilkan risiko SQLi.
2. **Pencegahan XSS (Cross-Site Scripting)**: Walaupun Flutter di *mobile/desktop* tidak secara alami mengeksekusi HTML, kami menerapkan `sanitizer` kustom pada formulir teks bebas (seperti Komentar Ulasan) yang membuang *tag HTML*.
3. **Validasi Input**: Validasi ketat diterapkan di sisi *client* (Form *Checkout*, Registrasi, *Review*, Harga, dll) dan sisi *database* (Tipe data numerik positif dan teks terbatas). Seluruh field input teks panjang telah dibatasi dengan `maxLength` guna mencegah *buffer overflow* / perusakan *layout*.
4. **Keamanan Sesi & Logout**: Memanggil `Supabase.instance.client.auth.signOut()` menghapus sesi dan token pengguna baik di sisi server dan *client storage*.
5. **Enforcement RLS**: *Row-Level Security* terpasang pada semua tabel publik. *User* hanya bisa *insert/update/delete* record yang `user_id`-nya cocok dengan profilnya sendiri, menjaga integritas kepemilikan data antar *Seller/Buyer*.

---

## 5. Dokumentasi API Database (Supabase)

Aplikasi tidak memakai REST API eksternal, melainkan langsung menggunakan Postgrest via SDK Flutter. Berikut struktur utamanya:

- `users` (auth.users): Autentikasi bawaan Supabase.
- `profiles`: Data publik akun (username, full name). Akses: *Public Read*, *Owner Update*.
- `user_roles`: Menyimpan peran per akun (buyer, seller, driver, admin).
- `stores`: Registrasi toko. Terhubung dengan user ID.
- `products`: Daftar produk. *Public Read*, *Seller Update/Insert/Delete*.
- `addresses`: Daftar alamat *Buyer*. *Owner Only*.
- `orders` & `order_items`: Informasi pesanan dan rincian barang. *Buyer/Seller/Driver/Admin Read* bergantung pada relasi ID. *Owner Update*.
- `wallets` & `wallet_transactions`: Saldo & riwayat mutasi finansial. Transaksi internal dikunci secara ketat.

---

## 6. Panduan Testing Singkat (End-to-End Demo)

1. **Jalankan Aplikasi**: `flutter run`.
2. **Registrasi Buyer**: Daftar akun baru, centang "Buyer".
3. **Setup Dompet (Buyer)**: Masuk ke halaman dompet, isi saldo *dummy*.
4. **Registrasi Seller**: Logout, daftar akun baru, centang "Seller".
5. **Buat Produk (Seller)**: Buat toko dan tambah produk (misalnya: Ikan Kerapu).
6. **Beli Produk (Buyer)**: Logout, login sebagai Buyer. Masukkan barang ke keranjang, checkout. Pilih pembayaran *Wallet*.
7. **Terima Pesanan (Seller)**: Login sebagai Seller. Masuk ke tab Pesanan Masuk, ubah status ke `Diproses` lalu `Dikirim`.
8. **Pengiriman (Driver)**: Logout, daftar/login sebagai Driver. Ambil *job* yang statusnya `Dikirim`, lalu tekan selesaikan pesanan.
9. **Cek Pemasukan**: Cek dompet *Driver* (bertambah sesuai ongkir) dan dompet *Seller* (bertambah sesuai harga barang dipotong komisi, jika ada).
10. **Test XSS**: Cobalah mengirim ulasan produk dengan teks `<script>alert('hack')</script>`. Sistem akan menyanitasi pesan tersebut dan menyimpannya murni tanpa eksekusi tag.
