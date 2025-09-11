<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\AbsensiGuru;
use Carbon\Carbon;

class AbsensiGuruController extends Controller
{
    /**
     * Guru Check-in
     */
    public function checkIn(Request $request)
    {
        $request->validate([
            'foto' => 'required|image|mimes:jpg,jpeg,png|max:2048',
        ]);

        $guru = $request->user();

        // Cek apakah sudah check-in di tanggal hari ini
        $sudahCheckIn = AbsensiGuru::where('guru_id', $guru->id)
            ->where('tanggal', today())
            ->exists();

        if ($sudahCheckIn) {
            return response()->json(['message' => 'Anda sudah melakukan check-in hari ini'], 422);
        }

        // Simpan foto
        $path = $request->file('foto')->store('absensi/foto_check_in', 'public');

        // Tentukan status check-in (Masuk/Terlambat)
        $batasCheckin = Carbon::createFromTime(7, 30, 0); // 07:30
        $statusCheckin = now()->gt($batasCheckin) ? 'Terlambat' : 'Masuk';

        $absensi = AbsensiGuru::create([
            'guru_id'         => $guru->id,
            'tanggal'         => today(), // tambahkan kolom tanggal
            'check_in'        => now(),
            'foto_check_in'   => $path,
            'status_check_in' => $statusCheckin,
            'status_check_out'=> 'Belum Check-out', // default
        ]);

        return response()->json([
            'message' => 'Check-in berhasil',
            'data' => $absensi
        ], 201);
    }

    /**
     * Guru Check-out
     */
    public function checkOut(Request $request)
    {
        $request->validate([
            'foto' => 'required|image|mimes:jpg,jpeg,png|max:2048',
        ]);

        $guru = $request->user();

        // Cari absensi hari ini yang belum check-out
        $absensi = AbsensiGuru::where('guru_id', $guru->id)
            ->where('tanggal', today())
            ->whereNull('check_out')
            ->latest('check_in')
            ->first();

        if (!$absensi) {
            return response()->json(['message' => 'Tidak ada data check-in yang perlu check-out'], 422);
        }

        // Simpan foto
        $path = $request->file('foto')->store('absensi/foto_check_out', 'public');

        $absensi->update([
            'check_out'        => now(),
            'foto_check_out'   => $path,
            'status_check_out' => 'Berhasil',
        ]);

        return response()->json([
            'message' => 'Check-out berhasil',
            'data' => $absensi
        ]);
    }

    /**
     * Riwayat Absensi Guru (20 terakhir)
     */
    public function riwayat(Request $request)
    {
        $guru = $request->user();

        $riwayat = AbsensiGuru::where('guru_id', $guru->id)
            ->orderByDesc('tanggal')
            ->paginate(20);

        $data = $riwayat->getCollection()->map(function ($item) {
            return [
                'id' => $item->id,
                'tanggal' => $item->tanggal, // pakai kolom tanggal langsung
                'checkin' => $item->check_in ? $item->check_in->format('H:i:s') : null,
                'foto_checkin_url' => $item->foto_check_in ? asset('storage/' . $item->foto_check_in) : null,
                'status_checkin' => $item->status_check_in,
                'checkout' => $item->check_out ? $item->check_out->format('H:i:s') : null,
                'foto_checkout_url' => $item->foto_check_out ? asset('storage/' . $item->foto_check_out) : null,
                'status_checkout' => $item->status_check_out,
                'aksi_checkin' => '/api/guru/absensi/check-in',
                'aksi_checkout' => '/api/guru/absensi/check-out',
            ];
        });

        return response()->json([
            'data' => $data,
            'meta' => [
                'current_page' => $riwayat->currentPage(),
                'last_page' => $riwayat->lastPage(),
                'per_page' => $riwayat->perPage(),
                'total' => $riwayat->total(),
            ]
        ]);
    }

    /**
     * List absensi semua guru berdasarkan tanggal (untuk admin)
     */
    public function listByDate($tanggal)
    {
        $absensi = AbsensiGuru::with('guru')
            ->where('tanggal', $tanggal)
            ->orderBy('check_in', 'asc')
            ->get();

        return response()->json([
            'tanggal' => $tanggal,
            'data' => $absensi
        ]);
    }
}
