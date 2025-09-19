<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Hash;

class ProfilGuruController extends Controller
{
    /**
     * Tampilkan profil guru yang sedang login
     */
    public function show(Request $request)
    {
        $guru = $request->user(); // user() otomatis model Guru (pakai Sanctum)

        return response()->json([
            'status' => 'success',
            'data'   => $this->transformGuru($guru),
        ], 200);
    }

    /**
     * Update profil guru (termasuk upload foto profil + ubah password)
     */
    public function update(Request $request)
    {
        $guru = $request->user();

        $rules = [
            'nama'        => 'sometimes|string|max:255',
            'nip'         => 'sometimes|nullable|string|max:100',
            'telepon'     => 'sometimes|nullable|string|max:30', // ✅ bawa dari revisiku
            'jabatan'     => 'sometimes|nullable|string|max:255',
            'tahun_masuk' => 'sometimes|nullable|digits:4|integer|min:1900|max:' . date('Y'),
            'foto_profil' => 'sometimes|nullable|image|mimes:jpeg,png,jpg,webp|max:4096',
            'password'    => 'sometimes|nullable|string|min:6|confirmed',
        ];

        $validator = Validator::make($request->all(), $rules);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'errors' => $validator->errors(),
            ], 422);
        }

        // Ambil data yang boleh diupdate
        $data = $request->only(['nama', 'nip', 'telepon', 'jabatan', 'tahun_masuk']);

        // Update password kalau ada
        if ($request->filled('password')) {
            $data['password'] = Hash::make($request->password); // ✅ hash manual (cara aman)
        }

        // Upload foto profil kalau ada
        if ($request->hasFile('foto_profil')) {
            $path = $request->file('foto_profil')->store('guru', 'public');

            // Hapus foto lama jika ada
            if ($guru->foto_profil && Storage::disk('public')->exists($guru->foto_profil)) {
                Storage::disk('public')->delete($guru->foto_profil);
            }

            $data['foto_profil'] = $path;
        }

        // Simpan perubahan
        $guru->update($data);

        return response()->json([
            'status'  => 'success',
            'message' => 'Profil berhasil diperbarui',
            'data'    => $this->transformGuru($guru),
        ], 200);
    }

    /**
     * Helper untuk membentuk response profil
     */
    protected function transformGuru($guru)
    {
        return [
            'id'             => $guru->id,
            'nama'           => $guru->nama,
            'email'          => $guru->email,
            'nip'            => $guru->nip,
            'telepon'        => $guru->telepon,
            'jabatan'        => $guru->jabatan,
            'tahun_masuk'    => $guru->tahun_masuk,
            'foto_profil'    => $guru->foto_profil, // path relatif
            'foto_profil_url'=> $guru->foto_profil ? Storage::url($guru->foto_profil) : null,
            'created_at'     => $guru->created_at,
            'updated_at'     => $guru->updated_at,
        ];
    }
}
