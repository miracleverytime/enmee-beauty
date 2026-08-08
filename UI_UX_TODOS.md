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

- [x] **#5 Skeleton loader di settings** — `SettingItemSkeleton` & `SectionHeaderSkeleton` ditambahin di `skeleton_loader.dart`. Settings screen punya 220ms loading state + `AnimatedSwitcher` fade ke konten (konsisten dengan loading state di tab lain).
- [x] **#6 Indikator sort/filter aktif** — Widget `SortIndicator` di `lib/widgets/sort_indicator.dart` (chip pill dengan icon swap_vert + label + tombol X). Tampil di product toolbar via `AnimatedSize` cuma saat sort bukan default (Nama A-Z). Tap body buka sort sheet, tap X reset ke default.
- [x] **#7 Haptic feedback** — Wrapper `Haptics` di `lib/utils/haptics.dart` (selection/light/medium/heavy/error). Dipakai di: theme toggle (light), stats collapse × 3 screen (medium), FAB (medium), tab switch (selection), search clear (selection via SearchField), sort change & sort clear (selection), period selector report (selection).
- [x] **#8 Haptic on destructive actions** — Delete produk (medium buka dialog + heavy confirm), delete transaksi long-press (medium buka dialog + heavy confirm).
- [x] **#10 Tab label visible di bottom nav** — `app_bottom_nav_bar.dart`: icon-only (label dihapus), plus background pill (`AnimatedContainer` 320ms, primary 12% opacity) yang muncul di item aktif. `AppNavItem.label` field juga dihapus.

---

## Low Impact / Nice-to-have

- [ ] **#11 Page transition consistency** — `navigateTo` di `page_transitions.dart` udah ada. Cek apakah dipakai konsisten di semua push (add product, add transaction).
- [ ] **#12 Long press hint consistency** — `transaction_list_screen.dart:676` punya long-press-to-delete. `product_list` punya explicit delete button. Cek konsistensi UX.
- [x] **#13 Formatter terpusat** — `lib/utils/formatters.dart`: `Formatters.number()`, `currency()`, `currencyRp()`, `compact()` (return `CompactNumber` value+unit), & `dateShort()`. Refactor 5 file (product_list, transaction_list, report, add_transaction, product_card) — semua method duplikat `_formatCurrency`/`_formatCurrencyCompact`/`_formatNumber`/`_formatCurrencyShort`/`_formatDate` dihapus. Format konsisten: "Rp 1.500.000", "1,2 JT", "1.234".
- [x] **#14 Date formatter** — `_formatDate` di transaction_list diganti jadi `Formatters.dateShort()` (sama: "Hari ini · HH.mm" / "DD MMM · HH.mm").
- [x] **#15 Stagger animation untuk list items** — `lib/widgets/staggered_item.dart`: `StaggeredListView` (API mirip `ListView.separated` + `RefreshIndicator`-friendly). Saat pertama paint, 8 item pertama muncul berurutan (fade + slide-up 6%, delay 50ms, durasi 320ms). Item ke-9+ langsung muncul tanpa animasi. Dipakai di product, transaction, report list.
- [ ] **#16 Hapus shadow di dark mode** — FAB shadow di `main_shell.dart:107` + header card shadow di `page_header.dart`. Di dark mode shadow kurang guna, bisa di-skip atau dikurangi.

---

## Info

- [ ] **#17 Aksesibilitas** — `Semantics` label untuk icon button (theme toggle, notif, delete). Sekarang cuma `IconButton` tanpa tooltip — screen reader user bakal bingung.
- [x] **#18 Text contrast check** — Warna `lightTextSecondary` diperbarui dari `#6B7280` ke `#4B5563` (rasio kontras ~7:1) dan `lightTextMuted` dari `#9CA3AF` ke `#6B7280` (rasio kontras 4.6:1 terhadap putih/light bg), memenuhi standar WCAG AA (minimal 4.5:1). Warna Dark Mode (`#95A3B6`) sudah memenuhi WCAG AA (~6.2:1 terhadap dark surface).

---

## Selesai

- [x] **Extract widget `PageHeader` reusable** — 4 file screen duplikat header dikonsolidasi ke `lib/widgets/page_header.dart`.
- [x] **Pindahkan theme toggle ke Settings** — Tombol theme dihapus dari 3 tab, dipindah ke section "Tampilan" di Settings dengan switch Mode Gelap.
