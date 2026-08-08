# UI/UX Improvement Backlog

Saran-saran UI/UX yang sudah diidentifikasi untuk aplikasi Enmee Beauty.
Diurut dari impact tertinggi ke terendah. Centang item yang sudah selesai.

---

## High Impact

- [x] **#1 Animated content switching di tab** — Wrapper `_AnimatedTab` di `main_shell.dart` (fade + slide up 4% saat tab diaktifkan). State tiap tab tetap terjaga via `IndexedStack`.
- [x] **#2 Empty state yang actionable** — Widget `EmptyState` reusable di `lib/widgets/empty_state.dart`. Product & transaction punya CTA "Tambah Produk/Transaksi"; report pakai empty state informatif. Semua pakai icon dalam circle ber-border biar lebih polished.
- [x] **#3 Pull-to-refresh yang konsisten** — Audit selesai: product, transaction, report sudah punya `RefreshIndicator`. Settings gak perlu (statis).
- [x] **#4 Search dengan clear button** — Widget `SearchField` reusable di `lib/widgets/search_field.dart` dengan suffix icon X reaktif (muncul saat ada query, hilang saat kosong). Dipakai di product, transaction, dan report screen. Dispose controller ditambahkan di 3 screen.

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
