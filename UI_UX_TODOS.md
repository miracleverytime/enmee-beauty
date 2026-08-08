# UI/UX Improvement Backlog

Saran-saran UI/UX yang sudah diidentifikasi untuk aplikasi Enmee Beauty.
Diurut dari impact tertinggi ke terendah. Centang item yang sudah selesai.

---

## High Impact

- [ ] **#1 Animated content switching di tab** — Sekarang `IndexedStack` di `main_shell.dart:73` keep state tapi switch terasa abrupt. Tambahin animated transition (fade + slight slide) saat pindah tab.
- [ ] **#2 Empty state yang actionable** — Beberapa empty state masih generic. Tambahin saran kontekstual + CTA:
  - Produk: "Tambah produk pertamamu" + tombol
  - Laporan: "Mulai catat transaksi untuk lihat laporan"
  - Transaksi: "Tap + untuk tambah transaksi"
- [ ] **#3 Pull-to-refresh yang konsisten** — `product_list` & `transaction_list` punya `RefreshIndicator`. Cek `report_screen.dart:637` (ada), `settings_screen` (gak perlu).
- [ ] **#4 Search dengan clear button** — TextField di `product_list_screen.dart:580` & `transaction_list_screen.dart:572` belum punya tombol clear (X) saat ada query.

---

## Medium Impact

- [ ] **#5 Skeleton loader di settings** — `settings_screen.dart` render instan. Tambahin skeleton atau fade-in biar lebih polished.
- [ ] **#6 Indikator sort/filter aktif** — Sort bottom sheet di `product_list_screen.dart` gak ada indikator "sedang di-sort by X". Tambahin chip kecil: "Diurutkan: Harga ↓" di bawah search bar.
- [ ] **#7 Haptic feedback** di:
  - Toggle theme (settings)
  - Toggle stats collapse
  - FAB press
  - Tab switch
- [ ] **#8 Haptic on destructive actions** — Long press delete transaksi, hapus produk, hapus semua data. Sekarang cuma snackbar, gak ada feedback tactile.
- [ ] **#9 Empty state illustration** — Icon generic (`inventory_2_outlined`, `receipt_long_outlined`, `bar_chart_outlined`). Bisa pakai custom illustration/Lottie atau gradient background biar lebih menarik.
- [ ] **#10 Tab label visible di bottom nav** — `app_bottom_nav_bar.dart`. Cek apakah label selalu visible atau hanya saat aktif. Material 3 modern biasanya label selalu visible dengan animated pill untuk yang aktif.

---

## Low Impact / Nice-to-have

- [ ] **#11 Page transition consistency** — `navigateTo` di `page_transitions.dart` udah ada. Cek apakah dipakai konsisten di semua push (add product, add transaction).
- [ ] **#12 Long press hint consistency** — `transaction_list_screen.dart:676` punya long-press-to-delete. `product_list` punya explicit delete button. Cek konsistensi UX.
- [ ] **#13 Currency formatter terpusat** — Format "Rp 1.000", "Rp 1.000.000" (titik), "1.5 jt" tidak konsisten. Bikin helper `CurrencyFormatter.format()`.
- [ ] **#14 Date format consistency** — `transaction_list_screen.dart:907` punya custom formatter, mungkin bisa dipakai juga di laporan & tempat lain.
- [ ] **#15 Stagger animation untuk list items** — Saat data pertama load, list item di-stagger fade-in biar terasa smooth.
- [ ] **#16 Hapus shadow di dark mode** — FAB shadow di `main_shell.dart:107` + header card shadow di `page_header.dart`. Di dark mode shadow kurang guna, bisa di-skip atau dikurangi.

---

## Info

- [ ] **#17 Aksesibilitas** — `Semantics` label untuk icon button (theme toggle, notif, delete). Sekarang cuma `IconButton` tanpa tooltip — screen reader user bakal bingung.
- [ ] **#18 Text contrast check** — Warna `textMuted`, `textSecondary` cek WCAG contrast di light/dark mode.

---

## Selesai

- [x] **Extract widget `PageHeader` reusable** — 4 file screen duplikat header dikonsolidasi ke `lib/widgets/page_header.dart`.
- [x] **Pindahkan theme toggle ke Settings** — Tombol theme dihapus dari 3 tab, dipindah ke section "Tampilan" di Settings dengan switch Mode Gelap.
