<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AbsensiGuruController;
use App\Http\Controllers\AuthGuruController;
use App\Http\Controllers\AuthAdminController;
use App\Http\Controllers\GuruController;
use App\Http\Controllers\ProfilGuruController;

// ==========================
// ROUTE TERBUKA (tidak butuh token)
// ==========================

// ---- GURU ----
Route::post('/guru/register', [AuthGuruController::class, 'register']);
Route::post('/guru/login', [AuthGuruController::class, 'login']);

// ---- ADMIN ----
Route::post('/admin/register', [AuthAdminController::class, 'register']);
Route::post('/admin/login', [AuthAdminController::class, 'login']);

// ==========================
// ROUTE DENGAN AUTENTIKASI
// ==========================
Route::middleware('auth:sanctum')->group(function () {

    // --------------------------
    // ROUTE KHUSUS GURU
    // --------------------------
    Route::prefix('guru')->middleware('role:guru')->group(function () {
        // Auth
        Route::post('/logout', [AuthGuruController::class, 'logout']);
        Route::post('/logout-all', [AuthGuruController::class, 'logoutAll']);

        // Profil
        Route::get('/profile', [ProfilGuruController::class, 'show']);
        Route::put('/profile', [ProfilGuruController::class, 'update']);

        // Absensi
        Route::prefix('absensi')->group(function () {
            Route::post('/check-in', [AbsensiGuruController::class, 'checkIn']);
            Route::post('/check-out', [AbsensiGuruController::class, 'checkOut']);
            Route::get('/riwayat', [AbsensiGuruController::class, 'riwayat']); // ✅ bisa ditambah paginasi di controller
            Route::get('/dashboard', [AbsensiGuruController::class, 'dashboard']);
        });
    });

    // --------------------------
    // ROUTE KHUSUS ADMIN
    // --------------------------
    Route::prefix('admin')->middleware('role:admin')->group(function () {
        // Auth
        Route::post('/logout', [AuthAdminController::class, 'logout']);
        Route::post('/logout-all', [AuthAdminController::class, 'logoutAll']);
        Route::get('/me', [AuthAdminController::class, 'me']);

        // Absensi guru
        Route::prefix('absensi')->group(function () {
            Route::post('/', [AbsensiGuruController::class, 'adminStore']); 
            Route::get('/{tanggal}', [AbsensiGuruController::class, 'listByDate']);
        });

        // CRUD Guru
        Route::prefix('guru')->group(function () {
            Route::get('/', [GuruController::class, 'index']);
            Route::get('/{id}', [GuruController::class, 'show']);
            Route::put('/{id}', [GuruController::class, 'update']);
            Route::delete('/{id}', [GuruController::class, 'destroy']);
        });
    });
});
