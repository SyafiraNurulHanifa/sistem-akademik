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
            'data' => $this->transformGuru($guru),
        ], 200);
    }

    /**
     * Update profil guru (termasuk upload foto profil)
     */
    public function update(Request $request)
    {
        $guru = $request->user();

        $rules = [
            'nama' => 'sometimes|string|max:255',
            // email otomatis dari registrasi → biasanya tidak bisa diubah
            'nip' => 'sometimes|nullable|string|max:100',
            'jabatan' => 'sometimes|nullable|string|max:255',
            'tahun_masuk' => 'sometimes|nullable|digits:4|integer|min:1900|max:' . date('Y'),
            'foto_profil' => 'sometimes|nullable|image|mimes:jpeg,png,jpg,webp|max:4096',
            'password' => 'sometimes|nullable|string|min:6|confirmed',
        ];

        $validator = Validator::make($request->all(), $rules);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'errors' => $validator->errors(),
            ], 422);
        }

        // update field sederhana
        $fillable = ['nama','nip','jabatan','tahun_masuk'];
        foreach ($fillable as $f) {
            if ($request->has($f)) {
                $guru->{$f} = $request->input($f);
            }
        }

        // update password jika ada
        if ($request->filled('password')) {
            $guru->password = Hash::make($request->input('password'));
        }

        // upload foto profil
        if ($request->hasFile('foto_profil')) {
            $file = $request->file('foto_profil');
            $path = $file->store('guru', 'public'); // simpan di storage/app/public/guru/

            // hapus foto lama jika ada
            if ($guru->foto_profil && Storage::disk('public')->exists($guru->foto_profil)) {
                Storage::disk('public')->delete($guru->foto_profil);
            }

            $guru->foto_profil = $path;
        }

        $guru->save();

        return response()->json([
            'status' => 'success',
            'message' => 'Profil berhasil diperbarui',
            'data' => $this->transformGuru($guru),
        ], 200);
    }

    /**
     * Helper untuk membentuk response profil
     */
    protected function transformGuru($guru)
    {
        return [
            'id' => $guru->id,
            'nama' => $guru->nama,
            'email' => $guru->email,
            'nip' => $guru->nip,
            'jabatan' => $guru->jabatan,
            'tahun_masuk' => $guru->tahun_masuk,
            'foto_profil' => $guru->foto_profil, // path relatif
            'foto_profil_url' => $guru->foto_profil_url ?? ($guru->foto_profil ? Storage::url($guru->foto_profil) : null),
            'created_at' => $guru->created_at,
            'updated_at' => $guru->updated_at,
        ];
    }
}
