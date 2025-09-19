<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use App\Models\Guru;

class AuthGuruController extends Controller
{
    /**
     * Register Guru
     */
    public function register(Request $request)
    {
        $data = $request->validate([
            'nama'                  => 'required|string|max:255',
            'email'                 => 'required|email|unique:gurus,email',
            'jabatan'               => 'required|string|max:255',
            'password'              => 'required|string|min:6|confirmed', 
            // konfirmasi password wajib pakai field: password_confirmation
        ]);

        $guru = Guru::create([
            'nama'     => $data['nama'],
            'email'    => $data['email'],
            'jabatan'  => $data['jabatan'],
            'password' => Hash::make($data['password']), // ✅ pastikan hash disini
        ]);

        // ✅ Token dengan ability "guru"
        $token = $guru->createToken('guru-token', ['guru'])->plainTextToken;

        return response()->json([
            'status'  => 'success',
            'message' => 'Registrasi guru berhasil',
            'data'    => [
                'token' => $token,
                'guru'  => [
                    'id'      => $guru->id,
                    'nama'    => $guru->nama,
                    'email'   => $guru->email,
                    'jabatan' => $guru->jabatan,
                ]
            ]
        ], 201);
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

        // ✅ Token dengan ability "guru"
        $token = $guru->createToken('guru-token', ['guru'])->plainTextToken;

        return response()->json([
            'status'  => 'success',
            'message' => 'Login berhasil',
            'data'    => [
                'token' => $token,
                'guru'  => [
                    'id'      => $guru->id,
                    'nama'    => $guru->nama,
                    'email'   => $guru->email,
                    'jabatan' => $guru->jabatan,
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
     * Logout dari semua device
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
