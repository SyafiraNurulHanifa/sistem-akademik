<?php

namespace App\Http\Controllers;

use App\Models\Guru;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

class GuruController extends Controller
{
    // GET /api/guru
    public function index()
    {
        return response()->json(Guru::all(), Response::HTTP_OK);
    }

    // POST /api/guru
    public function store(Request $request)
    {
        $data = $request->validate([
            'nama'    => 'required|string|max:255',
            'email'   => 'required|email|unique:gurus,email',
            'mapel'   => 'required|string|max:255',
            'telepon' => 'nullable|string|max:30',
        ]);

        $guru = Guru::create($data);
        return response()->json($guru, Response::HTTP_CREATED);
    }

    // GET /api/guru/{id}
    public function show($id)
    {
        $guru = Guru::findOrFail($id);
        return response()->json($guru, Response::HTTP_OK);
    }

    // PUT /api/guru/{id}
    public function update(Request $request, $id)
    {
        $guru = Guru::findOrFail($id);

        $data = $request->validate([
            'nama'    => 'sometimes|required|string|max:255',
            'email'   => 'sometimes|required|email|unique:gurus,email,'.$guru->id,
            'mapel'   => 'sometimes|required|string|max:255',
            'telepon' => 'nullable|string|max:30',
        ]);

        $guru->update($data);
        return response()->json($guru, Response::HTTP_OK);
    }

    // DELETE /api/guru/{id}
    public function destroy($id)
    {
        $guru = Guru::findOrFail($id);
        $guru->delete();
        return response()->json(['message' => 'Guru deleted successfully'], Response::HTTP_OK);
    }
}
