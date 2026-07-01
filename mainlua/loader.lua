-- ====================================================================
-- FILE: loader.lua (Tersimpan di GitHub)
-- FUNGSI: Menyatukan chunk, memverifikasi anti-tamper, dan mengeksekusi
-- ====================================================================

-- Mengembalikan fungsi agar bisa langsung dijalankan oleh script client
return function(chunk_data, expected_checksum, start_key)
    local bit = require("bit")
    
    -- 1. Menggabungkan semua chunk menjadi satu string panjang
    local reassembled_data = table.concat(chunk_data)
    
    local original_bytecode = ""
    local calc_checksum = 0
    local current_key = start_key
    
    -- 2. Proses Dekripsi & Pengecekan Checksum
    -- Mengambil setiap angka di balik format "\angka"
    for val in string.gmatch(reassembled_data, "\\(%d+)") do
        local encrypted_byte = tonumber(val)
        
        -- Membuka kunci (Dekripsi XOR)
        local decrypted_byte = bit.bxor(encrypted_byte, current_key)
        
        -- Menghitung ulang checksum
        calc_checksum = (calc_checksum + decrypted_byte) % 256
        
        -- Menyimpan byte asli
        original_bytecode = original_bytecode .. string.char(decrypted_byte)
        
        -- Memutar kunci (Rolling Key) agar terus berubah setiap byte
        current_key = (current_key + 17) % 256
    end
    
    -- 3. Verifikasi Anti-Tamper
    if calc_checksum ~= expected_checksum then
        print("[Sistem] Keamanan Terpicu: Data telah dimodifikasi!")
        return -- Berhenti eksekusi jika file dirusak
    end
    
    -- 4. Eksekusi Script Langsung di Memori
    local run_func, err = load(original_bytecode, "=(secure_payload)")
    if type(run_func) == "function" then
        local success, run_err = pcall(run_func)
        if not success then
            print("[Sistem] Error Eksekusi: " .. tostring(run_err))
        end
    else
        print("[Sistem] Gagal memuat struktur bytecode.")
    end
end
