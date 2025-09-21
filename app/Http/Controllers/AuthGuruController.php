<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use App\Models\Guru;
use Illuminate\Http\Response;

class AuthGuruController extends Controller
{

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
     * Login Guru
     */
    public function login(Request $request)
    {
        $data = $request->validate([
            'email'    => 'required|email',
            'password' => 'required|string|min:6',
        ]);

        $guru = Guru::where('email', $data['email'])->first();

        if (!$guru || !Hash::check($data['password'], $guru->password)) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Email atau password salah',
            ], 401);
        }

        // Buat token Sanctum
        $token = $guru->createToken('guru-token')->plainTextToken;

        return response()->json([
            'status'  => 'success',
            'message' => 'Login berhasil',
            'data'    => [
                'token' => $token,
                'guru'  => [
                    'id'      => $guru->id,
                    'nama'    => $guru->nama,
                    'email'   => $guru->email,
                    'mapel'   => $guru->mapel,
                    'telepon' => $guru->telepon,
                ]
            ]
        ], 200);
    }

    /**
     * Logout Guru (hapus token aktif saja)
     */
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'status'  => 'success',
            'message' => 'Logout berhasil',
        ], 200);
    }

    /**
     * Logout dari semua device (opsional)
     */
    public function logoutAll(Request $request)
    {
        $request->user()->tokens()->delete();

        return response()->json([
            'status'  => 'success',
            'message' => 'Logout dari semua device berhasil',
        ], 200);
    }
}
