<?php

namespace App\Http\Controllers;

use App\Models\Guru;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Http\Response;

class GuruController extends Controller
{
    /**
     * GET /api/guru
     * Ambil semua data guru
     */
    public function index()
    {
        $guru = Guru::all();
        return response()->json([
            'status'  => 'success',
            'message' => 'Daftar guru berhasil diambil',
            'data'    => $guru
        ], Response::HTTP_OK);
    }

    /**
     * POST /api/guru
     * Tambah guru baru
     */
    public function store(Request $request)
    {
        $data = $request->validate([
            'nama'     => 'required|string|max:255',
            'email'    => 'required|email|unique:gurus,email',
            'jabatan'  => 'required|string|max:255',
            'telepon'  => 'nullable|string|max:30',
            'password' => 'required|string|min:6',
        ]);
        // Hash password sebelum disimpan
        $data['password'] = Hash::make($data['password']);

        $guru = Guru::create($data);

        return response()->json([
            'status'  => 'success',
            'message' => 'Guru berhasil ditambahkan',
            'data'    => $guru
        ], Response::HTTP_CREATED);
    }

    /**
     * GET /api/guru/{id}
     * Ambil detail guru
     */
    public function show($id)
    {
        $guru = Guru::findOrFail($id);
        return response()->json([
            'status'  => 'success',
            'message' => 'Detail guru berhasil diambil',
            'data'    => $guru
        ], Response::HTTP_OK);
    }

    /**
     * PUT /api/guru/{id}
     * Update data guru
     */
    public function update(Request $request, $id)
    {
        $guru = Guru::findOrFail($id);

        $data = $request->validate([
            'nama'     => 'sometimes|required|string|max:255',
            'email'    => 'sometimes|required|email|unique:gurus,email,' . $guru->id,
            'mapel'    => 'sometimes|required|string|max:255',
            'telepon'  => 'nullable|string|max:30',
            'password' => 'sometimes|nullable|string|min:6', // ✅ fix: bisa update password
        ]);

        $guru->update($data);

        return response()->json([
            'status'  => 'success',
            'message' => 'Data guru berhasil diperbarui',
            'data'    => $guru
        ], Response::HTTP_OK);
    }

    /**
     * DELETE /api/guru/{id}
     * Hapus guru
     */
    public function destroy($id)
    {
        $guru = Guru::findOrFail($id);
        $guru->delete();

        return response()->json([
            'status'  => 'success',
            'message' => 'Guru berhasil dihapus'
        ], Response::HTTP_OK);
    }
}
