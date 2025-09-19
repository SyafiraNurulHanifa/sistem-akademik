<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use App\Models\Admin;

class AuthAdminController extends Controller
{
    /**
     * Register Admin
     */
    public function register(Request $request)
    {
        $data = $request->validate([
            'name'                  => 'required|string|max:255',
            'email'                 => 'required|email|unique:admins,email',
            'password'              => 'required|string|min:6|confirmed',
        ]);

        $admin = Admin::create([
            'name'     => $data['name'],
            'email'    => $data['email'],
            'password' => Hash::make($data['password']),
        ]);

        return response()->json([
            'status'  => 'success',
            'message' => 'Registrasi admin berhasil',
            'data'    => $admin
        ], 201);
    }

    /**
     * Login Admin
     */
    public function login(Request $request)
    {
        $data = $request->validate([
            'email'    => 'required|email',
            'password' => 'required|string|min:6',
        ]);

        $admin = Admin::where('email', $data['email'])->first();

        if (!$admin || !Hash::check($data['password'], $admin->password)) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Email atau password salah',
            ], 401);
        }

        // ✅ Token dibuat dengan ability "admin" agar bisa diverifikasi RoleMiddleware
        $token = $admin->createToken('admin-token', ['admin'])->plainTextToken;

        return response()->json([
            'status'  => 'success',
            'message' => 'Login berhasil',
            'data'    => [
                'token' => $token,
                'admin' => [
                    'id'    => $admin->id,
                    'name'  => $admin->name,
                    'email' => $admin->email,
                ]
            ]
        ], 200);
    }

    /**
     * Logout Admin
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

    /**
     * Profil Admin yang sedang login
     */
    public function me(Request $request)
    {
        return response()->json([
            'status'  => 'success',
            'message' => 'Data admin saat ini',
            'data'    => $request->user()
        ], 200);
    }
}
