#!/bin/bash

FILE="/var/www/pterodactyl/resources/views/layouts/main.blade.php"
CADANGAN="/var/www/pterodactyl/resources/views/layouts/main.blade.php.bak"
KODE_PENANDA="12d156d505c347dde06b05fc590ec757"
KODE_IKLAN='<!-- IKLAN OTOMATIS -->
<script>
  atOptions = {
    "key" : "12d156d505c347dde06b05fc590ec757",
    "format" : "iframe",
    "height" : 60,
    "width" : 468,
    "params" : {}
  };
</script>
<script src="https://www.highperformanceformat.com/12d156d505c347dde06b05fc590ec757/invoke.js"></script>'

# Cek folder Pterodactyl
if [ ! -d "/var/www/pterodactyl" ]; then
    echo "❌ Folder Pterodactyl tidak ditemukan!"
    exit 1
fi

bersihkan_cache() {
    cd /var/www/pterodactyl && php artisan view:clear
}

pasang_iklan() {
    echo "🔧 Memulai Pemasangan..."
    # Bikin cadangan pertama kali kalau belum ada
    if [ ! -f "$CADANGAN" ]; then
        echo "💾 Membuat cadangan file asli..."
        cp "$FILE" "$CADANGAN"
    fi

    # Cek udah terpasang belum
    if grep -q "$KODE_PENANDA" "$FILE"; then
        echo "⚠️ Iklan sudah terpasang sebelumnya!"
        exit 0
    fi

    # Masukkan kode sebelum </body>
    sed -i "s|</body>|$KODE_IKLAN\n</body>|" "$FILE"
    bersihkan_cache
    echo "✅ BERHASIL DIPASANG!"
    echo "📏 Ukuran: 468 x 60 piksel"
    echo "💾 Cadangan aman di: $CADANGAN"
}

hapus_iklan() {
    echo "🗑️ Memulai Penghapusan..."
    if [ ! -f "$CADANGAN" ]; then
        echo "⚠️ File cadangan tidak ditemukan, akan hapus kode saja..."
        sed -i "/$KODE_PENANDA/,+8d" "$FILE"
    else
        echo "🔄 Mengembalikan dari cadangan..."
        cp "$CADANGAN" "$FILE"
    fi
    bersihkan_cache
    echo "✅ BERHASIL DIHAPUS & DIKEMBALIKAN SEPERTI SEMULA!"
}

# MENU UTAMA
clear
echo "=========================================="
echo "    🛠️ PENGATURAN IKLAN PTERODACTYL"
echo "=========================================="
echo "1. 📦 Install Iklan"
echo "2. 🗑️ Uninstall & Kembalikan Awal"
echo "3. ❌ Keluar"
echo "=========================================="
read -p "Pilih menu [1-3]: " PILIH

case $PILIH in
    1) pasang_iklan ;;
    2) hapus_iklan ;;
    3) echo "👋 Keluar..."; exit 0 ;;
    *) echo "❌ Pilihan tidak valid!"; exit 1 ;;
esac
