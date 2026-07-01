-- Nama File: loader.lua (Taruh ini di GitHub)
-- Script ini akan didownload dan dieksekusi oleh script lokal pengguna

return function(encrypted_data)
    if not encrypted_data or #encrypted_data == 0 then
        return
    end

    local restored_bytecode = ""
    local key = 0x5A -- Kunci awal harus sama dengan alat enkripsi

    -- Proses Dekripsi: Membalikkan Lapis 1 dan Lapis 2
    for i = 1, #encrypted_data do
        local b2 = string.byte(encrypted_data, i)
        
        -- Membalikkan Lapis 2: Kunci Berputar
        local step1 = (b2 - key) % 256
        
        -- Membalikkan Lapis 1: Inversi
        local original_byte = 255 - step1 

        restored_bytecode = restored_bytecode .. string.char(original_byte)
        
        -- Putar kunci untuk byte berikutnya
        key = (key + 17) % 256
    end

    -- Menjalankan bytecode yang sudah dipulihkan
    local jalankan_fungsi, err = load(restored_bytecode)
    
    if jalankan_fungsi then
        jalankan_fungsi() 
        if type(main) == "function" then
            -- Memastikan fungsi main() dipanggil jika ada
            lua_thread.create(main)
        end
    else
        print("Gagal memuat kode dari memori.")
    end
end
