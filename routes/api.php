<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AbsensiGuruController;
use App\Http\Controllers\AuthGuruController;
use App\Http\Controllers\AuthAdminController;
use App\Http\Controllers\GuruController;
use App\Http\Controllers\ProfilGuruController;

// ==========================
// ROUTE TERBUKA (bebas akses)
// ==========================

// ---- GURU ----
Route::post('/guru/register', [AuthGuruController::class, 'store']);
Route::post('/guru/login', [AuthGuruController::class, 'login']);

// ---- ADMIN ----
Route::post('/admin/register', [AuthAdminController::class, 'register']);
Route::post('/admin/login', [AuthAdminController::class, 'login']);

// ==========================
// ROUTE YANG MEMBUTUHKAN LOGIN
// ==========================
Route::middleware('auth:sanctum')->group(function () {

    // ---- GURU ----
    Route::prefix('guru')->group(function () {
        Route::post('/logout', [AuthGuruController::class, 'logout']);

        // Profil
        Route::get('/profile', [ProfilGuruController::class, 'show']);
        Route::put('/profile', [ProfilGuruController::class, 'update']);

        // Absensi
        Route::prefix('absensi')->group(function () {
            Route::post('/check-in', [AbsensiGuruController::class, 'checkIn']);
            Route::post('/check-out', [AbsensiGuruController::class, 'checkOut']);
            Route::get('/riwayat', [AbsensiGuruController::class, 'riwayat']);
            Route::get('/dashboard', [AbsensiGuruController::class, 'dashboard']);
        });
    });

    // ---- ADMIN ----
    Route::prefix('admin')->group(function () {
        Route::post('/logout', [AuthAdminController::class, 'logout']);
        Route::post('/logout-all', [AuthAdminController::class, 'logoutAll']);
        Route::get('/me', [AuthAdminController::class, 'me']);

        // Absensi guru
        Route::prefix('absensi')->group(function () {
            Route::post('/', [AbsensiGuruController::class, 'adminStore']);
            Route::get('/{tanggal}', [AbsensiGuruController::class, 'listByDate']);
            Route::put('/edit/{guru_id}/{tanggal}', [AbsensiGuruController::class, 'adminUpdate']);
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
