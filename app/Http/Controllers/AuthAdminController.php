<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Admin;
use Illuminate\Support\Facades\Hash;

class AuthAdminController extends Controller
{
    /**
     * Register Admin
     */
    public function register(Request $request)
    {
        $data = $request->validate([
            'name'     => 'required|string|max:255',
            'email'    => 'required|string|email|unique:admins,email',
            'password' => 'required|string|min:6|confirmed',
        ]);

        // Hash password
        $data['password'] = Hash::make($data['password']);

        $admin = Admin::create($data);

        $token = $admin->createToken('admin-token')->plainTextToken;

        return response()->json([
            'status'  => 'success',
            'message' => 'Admin berhasil registrasi',
            'data'    => [
                'token' => $token,
                'admin' => [
                    'id'    => $admin->id,
                    'name'  => $admin->name,
                    'email' => $admin->email,
                ]
            ]
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

        $token = $admin->createToken('admin-token')->plainTextToken;

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
     * Logout Admin (hapus token aktif saja)
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
     * Logout Admin dari semua device
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
     * Data Admin yang sedang login
     */
    public function me(Request $request)
    {
        return response()->json([
            'status'  => 'success',
            'message' => 'Data admin yang sedang login',
            'data'    => [
                'id'    => $request->user()->id,
                'name'  => $request->user()->name,
                'email' => $request->user()->email,
            ]
        ], 200);
    }
}
