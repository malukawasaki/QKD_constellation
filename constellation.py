import re

# [WALKER]:[ALTITUDE]:[INCLINATION]:[PLANE PARAMS]
constellation_code = [
    "D:8000:60:9/3/1",
]

regex_split_multicode = "\+"
regex_code = "^(?:([DS/\d]*):)?([\d\./]+):([\w\.]+):([\d\./]+)$"
regex_walker = "^([DS])/?([\d\.]+)?$"
regex_altitude = "^([\d\.]+)(?:/([\d\.]+))?(?:/([\d\.]+))?$"
regex_plane = "^([\d\.]+)(?:/([\d\.]+))?(?:/([\d\.]+))?(?:/([\d\.]+))?$"

for multicode in constellation_code:
    print(multicode)
    codes = re.split(regex_split_multicode, multicode)
    for code in codes:
        items = re.findall(regex_code, code)[0]
        walker_params = items[0]
        altitude_params = items[1]
        inclination = items[2]
        plane_params = items[3]
        print(f"inclination: {inclination}")

        if walker_params != '':
            items_walker = re.findall(regex_walker, walker_params)[0]
            delta_or_star = items_walker[0]
            raan_offset = items_walker[1]
            print(f"delta_or_star: {delta_or_star}")
            print(f"raan_offset: {raan_offset}")

        items_altitude = re.findall(regex_altitude, altitude_params)[0]
        apogee = items_altitude[0]
        perigee = items_altitude[1]
        arg_periapsis = items_altitude[2]
        print(f"apogee: {apogee}")
        print(f"perigee: {perigee}")
        print(f"arg_periapsis: {arg_periapsis}")

        items_plane = re.findall(regex_plane, plane_params)[0]
        n_sats = items_plane[0]
        n_planes = items_plane[1]
        f = items_plane[2]
        nu_offset = items_plane[3]
        print(f"n_sats: {n_sats}")
        print(f"n_planes: {n_planes}")
        print(f"f: {f}")
        print(f"nu_offset: {nu_offset}")