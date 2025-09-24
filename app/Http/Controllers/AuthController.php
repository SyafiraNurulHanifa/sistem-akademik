<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AuthController extends Controller
{
    // Menampilkan halaman login
    public function showLoginForm()
    {
        return view('auth.login');
    }

    // Memproses permintaan login
    public function login(Request $request)
    {
        // 1. Validasi input
        $credentials = $request->validate([
            'username' => ['required'],
            'password' => ['required'],
        ]);

        // 2. Coba autentikasi
        if (Auth::attempt($credentials)) {
            $request->session()->regenerate();

            // 3. Arahkan pengguna ke dashboard sesuai peran
            return $this->redirectBasedOnRole(Auth::user());
        }

        // 4. Jika gagal, kembali dengan error
        return back()->withErrors([
            'username' => 'Username atau password salah.',
        ])->onlyInput('username');
    }

    // Menangani logout
    public function logout(Request $request)
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();
        return redirect('/login');
    }

    // Metode untuk mengarahkan berdasarkan peran
    protected function redirectBasedOnRole($user)
    {
        if ($user->role->name === 'admin') {
            return redirect()->intended('/admin/dashboard');
        } elseif ($user->role->name === 'guru') {
            return redirect()->intended('/guru/dashboard');
        } elseif ($user->role->name === 'siswa') {
            return redirect()->intended('/siswa/dashboard');
        }

        return redirect()->intended('/home');
    }
}