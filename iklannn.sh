#!/bin/bash

# OTOMATIS CARI FILE LAYOUT YANG BENAR
FILE=$(find /var/www/pterodactyl -name "*.blade.php" | grep -E "(layouts|templates)" | grep -v ".bak" | head -n1)

if [ -z "$FILE" ]; then
    echo "❌ File layout tidak ditemukan!"
    exit 1
fi

CADANGAN="${FILE}.bak"
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

echo "✅ File ditemukan di: $FILE"

bersihkan_cache() {
    cd /var/www/pterodactyl && php artisan view:clear
}

pasang_iklan() {
    echo "🔧 Memulai Pemasangan..."
    if [ ! -f "$CADANGAN" ]; then
        echo "💾 Membuat cadangan file asli..."
        cp "$FILE" "$CADANGAN"
    fi

    if grep -q "$KODE_PENANDA" "$FILE"; then
        echo "⚠️ Iklan sudah terpasang!"
        exit 0
    fi

    # Perbaiki perintah sed biar gak error
    sed -i '/<\/body>/i '"$KODE_IKLAN"'' "$FILE"
    bersihkan_cache
    echo "✅ BERHASIL DIPASANG!"
    echo "💾 Cadangan: $CADANGAN"
}

hapus_iklan() {
    echo "🗑️ Memulai Penghapusan..."
    if [ -f "$CADANGAN" ]; then
        cp "$CADANGAN" "$FILE"
    else
        sed -i "/$KODE_PENANDA/,+8d" "$FILE"
    fi
    bersihkan_cache
    echo "✅ BERHASIL DIKEMBALIKAN!"
}

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
