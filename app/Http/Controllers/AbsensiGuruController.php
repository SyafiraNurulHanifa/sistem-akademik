<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\AbsensiGuru;
use Carbon\Carbon;

class AbsensiGuruController extends Controller
{
    // Lokasi sekolah (ganti sesuai koordinat sekolahmu)
    private $schoolLat = -7.2575;
    private $schoolLng = 112.7521;

    /**
     * Hitung jarak dengan rumus Haversine (meter)
     */
    private function haversine($lat1, $lon1, $lat2, $lon2)
    {
        $earthRadius = 6371000; // meter
        $dLat = deg2rad($lat2 - $lat1);
        $dLon = deg2rad($lon2 - $lon1);

        $a = sin($dLat/2) * sin($dLat/2) +
             cos(deg2rad($lat1)) * cos(deg2rad($lat2)) *
             sin($dLon/2) * sin($dLon/2);

        $c = 2 * atan2(sqrt($a), sqrt(1-$a));

        return $earthRadius * $c;
    }

    /**
     * Guru Check-in
     */
    public function checkIn(Request $request)
    {
        $request->validate([
            'foto'      => 'required|image|mimes:jpg,jpeg,png|max:2048',
            'latitude'  => 'required|numeric',
            'longitude' => 'required|numeric',
        ]);

        $guru = $request->user();

        // Cek jarak
        $distance = $this->haversine(
            $this->schoolLat, $this->schoolLng,
            $request->latitude, $request->longitude
        );

        if ($distance > 500) {
            return response()->json([
                'status' => 'error',
                'message' => 'Anda berada di luar radius 500 meter dari sekolah.'
            ], 422);
        }

        // Cek apakah sudah check-in
        if (AbsensiGuru::where('guru_id', $guru->id)->where('tanggal', today())->exists()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Anda sudah melakukan check-in hari ini'
            ], 422);
        }

        // Upload foto
        $path = $request->file('foto')->store('absensi/foto_check_in', 'public');

        // Status check-in
        $batasCheckin = Carbon::createFromTime(7, 30, 0);
        $statusCheckin = now()->gt($batasCheckin) ? 'Terlambat' : 'Masuk';

        $absensi = AbsensiGuru::create([
            'guru_id'          => $guru->id,
            'tanggal'          => today(),
            'check_in'         => now(),
            'foto_check_in'    => $path,
            'status_check_in'  => $statusCheckin,
            'status_check_out' => 'Belum Check-out',
            'latitude'         => $request->latitude,
            'longitude'        => $request->longitude,
        ]);

        return response()->json([
            'status'  => 'success',
            'message' => 'Check-in berhasil',
            'data'    => $absensi
        ]);
    }

    /**
     * Guru Check-out
     */
    public function checkOut(Request $request)
    {
        $request->validate([
            'foto'      => 'required|image|mimes:jpg,jpeg,png|max:2048',
            'latitude'  => 'required|numeric',
            'longitude' => 'required|numeric',
        ]);

        $guru = $request->user();

        // Cek jarak
        $distance = $this->haversine(
            $this->schoolLat, $this->schoolLng,
            $request->latitude, $request->longitude
        );

        if ($distance > 500) {
            return response()->json([
                'status' => 'error',
                'message' => 'Anda berada di luar radius 500 meter dari sekolah.'
            ], 422);
        }

        // Cari absensi hari ini
        $absensi = AbsensiGuru::where('guru_id', $guru->id)
            ->where('tanggal', today())
            ->whereNull('check_out')
            ->first();

        if (!$absensi) {
            return response()->json([
                'status' => 'error',
                'message' => 'Tidak ada data check-in untuk check-out.'
            ], 422);
        }

        // Upload foto
        $path = $request->file('foto')->store('absensi/foto_check_out', 'public');

        $absensi->update([
            'check_out'        => now(),
            'foto_check_out'   => $path,
            'status_check_out' => 'Pulang',
            'latitude'         => $request->latitude,
            'longitude'        => $request->longitude,
        ]);

        return response()->json([
            'status'  => 'success',
            'message' => 'Check-out berhasil',
            'data'    => $absensi
        ]);
    }

    /**
     * Riwayat absensi guru login
     */
    public function riwayat(Request $request)
    {
        $guru = $request->user();
        $riwayat = $guru->absensiGuru()->latest()->paginate(20);

        return response()->json([
            'status'  => 'success',
            'message' => 'Riwayat absensi berhasil diambil',
            'data'    => $riwayat
        ]);
    }

    /**
     * Dashboard guru
     */
    public function dashboard(Request $request)
    {
        $guru = $request->user();
        $bulan = now()->month;
        $tahun = now()->year;

        $absensi = $guru->absensiGuru()
            ->whereMonth('tanggal', $bulan)
            ->whereYear('tanggal', $tahun)
            ->get();

        return response()->json([
            'status'  => 'success',
            'message' => 'Dashboard berhasil diambil',
            'data'    => [
                'total_hadir' => $absensi->count(),
                'detail'      => $absensi
            ]
        ]);
    }

    /**
     * Admin: buat absensi manual
     */
    public function adminStore(Request $request)
    {
        $data = $request->validate([
            'guru_id' => 'required|exists:gurus,id',
            'tanggal' => 'required|date',
            'status_check_in' => 'required|string',
        ]);

        // Cek duplikat
        if (AbsensiGuru::where('guru_id', $data['guru_id'])->where('tanggal', $data['tanggal'])->exists()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Absensi untuk guru ini di tanggal tersebut sudah ada'
            ], 422);
        }

        $absensi = AbsensiGuru::create([
            'guru_id'         => $data['guru_id'],
            'tanggal'         => $data['tanggal'],
            'status_check_in' => $data['status_check_in'],
            'check_in'        => now(),
            'status_check_out'=> 'Belum Check-out',
        ]);

        return response()->json([
            'status'  => 'success',
            'message' => 'Absensi berhasil ditambahkan oleh admin',
            'data'    => $absensi
        ]);
    }

    /**
     * Admin: daftar absensi per tanggal
     */
    public function listByDate($tanggal)
    {
        $absensi = AbsensiGuru::whereDate('tanggal', $tanggal)->with('guru')->get();

        return response()->json([
            'status'  => 'success',
            'message' => 'Data absensi tanggal ' . $tanggal,
            'data'    => $absensi
        ]);
    }
}
