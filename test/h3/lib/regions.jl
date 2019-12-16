module test_h3_lib_regions

using Test
using H3.Lib

Lib.polyfill
Lib.maxPolyfillSize
Lib.h3SetToLinkedGeo
Lib.destroyLinkedPolygon


using .Lib: H3Index, GeoCoord, Geofence, GeoPolygon

# https://github.com/uber/h3/blob/master/src/apps/testapps/testPolyfill.c#L25

sfVerts = [GeoCoord(0.659966917655, -2.1364398519396),
           GeoCoord(0.6595011102219, -2.1359434279405),
           GeoCoord(0.6583348114025, -2.1354884206045),
           GeoCoord(0.6581220034068, -2.1382437718946),
           GeoCoord(0.6594479998527, -2.1384597563896),
           GeoCoord(0.6599990002976, -2.1376771158464)]
sfGeofence = Geofence(6, pointer(sfVerts))
sfGeoPolygon = GeoPolygon(sfGeofence, 0, C_NULL)
@test Lib.maxPolyfillSize(Ref(sfGeoPolygon), 9) == 7057

holeVerts = [GeoCoord(0.6595072188743, -2.1371053983433),
             GeoCoord(0.6591482046471, -2.1373141048153),
             GeoCoord(0.6592295020837, -2.1365222838402)]
holeGeofence = Geofence(3, pointer(holeVerts))
holeGeoPolygon = GeoPolygon(sfGeofence, 1, pointer_from_objref(Ref(holeGeofence)))
@test Lib.maxPolyfillSize(Ref(holeGeoPolygon), 9) == 7057

emptyVerts = [GeoCoord(0.659966917655, -2.1364398519394),
              GeoCoord(0.659966917655, -2.1364398519395),
              GeoCoord(0.659966917655, -2.1364398519396)]
emptyGeofence = Geofence(3, pointer(emptyVerts))
emptyGeoPolygon = GeoPolygon(emptyGeofence, 0, C_NULL)
@test Lib.maxPolyfillSize(Ref(emptyGeoPolygon), 9) == 1

verts = [GeoCoord(0.01, 0.01),
         GeoCoord(0.01, -0.01),
         GeoCoord(-0.01, -0.01),
         GeoCoord(-0.01, 0.01)]
fence = Geofence(4, pointer(verts))
polygon = GeoPolygon(fence, 0, C_NULL)

countActualHexagons(hexagons::Vector{H3Index})::Int = length(filter(!iszero, hexagons))

hexagons = Lib.polyfill(Ref(sfGeoPolygon), 9)
@test countActualHexagons(hexagons) == 1253

refpolygon = Lib.h3SetToLinkedGeo(H3Index[])
Lib.destroyLinkedPolygon(refpolygon)

end # module test_h3_lib_regions
