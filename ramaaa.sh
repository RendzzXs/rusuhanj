#!/bin/bash

# Script Install & Uninstall Iklan Pterodactyl
# Created by: Your Name
# Version: 1.0

# Warna untuk output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Konfigurasi
PANEL_PATH="/var/www/pterodactyl"
BACKUP_DIR="/root/backup_pterodactyl"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Fungsi untuk menampilkan banner
show_banner() {
    clear
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}    PTERODACTYL ADS MANAGER v1.0      ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

# Fungsi untuk backup file
backup_file() {
    local file=$1
    local backup_name=$(basename "$file").backup_$TIMESTAMP
    
    if [ -f "$file" ]; then
        mkdir -p "$BACKUP_DIR"
        cp "$file" "$BACKUP_DIR/$backup_name"
        echo -e "${GREEN}✓ Backup berhasil: $backup_name${NC}"
        return 0
    else
        echo -e "${RED}✗ File tidak ditemukan: $file${NC}"
        return 1
    fi
}

# Fungsi untuk restore backup
restore_backup() {
    local file=$1
    local latest_backup=$(ls -t "$BACKUP_DIR"/$(basename "$file").backup_* 2>/dev/null | head -n1)
    
    if [ -n "$latest_backup" ] && [ -f "$latest_backup" ]; then
        cp "$latest_backup" "$file"
        echo -e "${GREEN}✓ Restore berhasil dari: $(basename "$latest_backup")${NC}"
        return 0
    else
        echo -e "${RED}✗ Tidak ada backup untuk $file${NC}"
        return 1
    fi
}

# Fungsi install iklan
install_ads() {
    show_banner
    echo -e "${YELLOW}Memulai proses instalasi iklan...${NC}"
    echo ""
    
    # Cek apakah panel terinstall
    if [ ! -d "$PANEL_PATH" ]; then
        echo -e "${RED}✗ Panel Pterodactyl tidak ditemukan di $PANEL_PATH${NC}"
        exit 1
    fi
    
    # File yang akan dimodifikasi
    FILES=(
        "$PANEL_PATH/resources/views/layouts/admin.blade.php"
        "$PANEL_PATH/resources/views/layouts/client.blade.php"
    )
    
    # Backup dan install untuk setiap file
    for file in "${FILES[@]}"; do
        if [ -f "$file" ]; then
            echo -e "${BLUE}→ Memproses: $(basename "$file")${NC}"
            
            # Backup file
            backup_file "$file"
            
            # Script iklan yang akan disisipkan
            ADS_SCRIPT='<script>
  atOptions = {
    '\''key'\'' : '\''12d156d505c347dde06b05fc590ec757'\'',
    '\''format'\'' : '\''iframe'\'',
    '\''height'\'' : 60,
    '\''width'\'' : 468,
    '\''params'\'' : {}
  };
</script>
<script src="https://www.highperformanceformat.com/12d156d505c347dde06b05fc590ec757/invoke.js"></script>'
            
            # Cek apakah iklan sudah ada
            if grep -q "12d156d505c347dde06b05fc590ec757" "$file"; then
                echo -e "${YELLOW}⚠ Iklan sudah terinstall di $(basename "$file")${NC}"
            else
                # Sisipkan script sebelum </body>
                sed -i "s|</body>|$ADS_SCRIPT\n</body>|" "$file"
                echo -e "${GREEN}✓ Iklan berhasil ditambahkan ke $(basename "$file")${NC}"
            fi
            echo ""
        else
            echo -e "${RED}✗ File tidak ditemukan: $(basename "$file")${NC}"
        fi
    done
    
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}✓ Instalasi iklan selesai!${NC}"
    echo -e "${YELLOW}Backup disimpan di: $BACKUP_DIR${NC}"
    echo -e "${GREEN}========================================${NC}"
}

# Fungsi uninstall iklan
uninstall_ads() {
    show_banner
    echo -e "${YELLOW}Memulai proses uninstall iklan...${NC}"
    echo ""
    
    # File yang akan diproses
    FILES=(
        "$PANEL_PATH/resources/views/layouts/admin.blade.php"
        "$PANEL_PATH/resources/views/layouts/client.blade.php"
    )
    
    for file in "${FILES[@]}"; do
        if [ -f "$file" ]; then
            echo -e "${BLUE}→ Memproses: $(basename "$file")${NC}"
            
            # Cek apakah ada iklan
            if grep -q "12d156d505c347dde06b05fc590ec757" "$file"; then
                # Backup sebelum menghapus
                backup_file "$file"
                
                # Hapus script iklan
                sed -i '/<script>/,/<\/script>/d' "$file"
                sed -i '/highperformanceformat.com\/12d156d505c347dde06b05fc590ec757/d' "$file"
                
                echo -e "${GREEN}✓ Iklan berhasil dihapus dari $(basename "$file")${NC}"
            else
                echo -e "${YELLOW}⚠ Tidak ditemukan iklan di $(basename "$file")${NC}"
            fi
            echo ""
        else
            echo -e "${RED}✗ File tidak ditemukan: $(basename "$file")${NC}"
        fi
    done
    
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}✓ Uninstall iklan selesai!${NC}"
    echo -e "${YELLOW}Backup disimpan di: $BACKUP_DIR${NC}"
    echo -e "${GREEN}========================================${NC}"
}

# Fungsi restore dari backup
restore_from_backup() {
    show_banner
    echo -e "${YELLOW}Restore dari backup terakhir...${NC}"
    echo ""
    
    if [ ! -d "$BACKUP_DIR" ]; then
        echo -e "${RED}✗ Tidak ada folder backup${NC}"
        exit 1
    fi
    
    FILES=(
        "$PANEL_PATH/resources/views/layouts/admin.blade.php"
        "$PANEL_PATH/resources/views/layouts/client.blade.php"
    )
    
    for file in "${FILES[@]}"; do
        if [ -f "$file" ]; then
            echo -e "${BLUE}→ Restore: $(basename "$file")${NC}"
            restore_backup "$file"
            echo ""
        fi
    done
    
    echo -e "${GREEN}✓ Restore selesai!${NC}"
}

# Fungsi menu
show_menu() {
    show_banner
    echo -e "${YELLOW}Pilih opsi:${NC}"
    echo ""
    echo -e "1) ${GREEN}Install Iklan${NC}"
    echo -e "2) ${RED}Uninstall Iklan${NC}"
    echo -e "3) ${BLUE}Restore dari Backup${NC}"
    echo -e "4) ${YELLOW}Keluar${NC}"
    echo ""
    read -p "Masukkan pilihan [1-4]: " choice
    
    case $choice in
        1) install_ads ;;
        2) uninstall_ads ;;
        3) restore_from_backup ;;
        4) echo -e "${GREEN}Terima kasih!${NC}"; exit 0 ;;
        *) echo -e "${RED}Pilihan tidak valid!${NC}"; sleep 2; show_menu ;;
    esac
}

# Cek akses root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Harap jalankan sebagai root!${NC}"
    exit 1
fi

# Jalankan menu
show_menu
