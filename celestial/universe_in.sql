-- Input file for creating the Universe database

-- Connect to the database to create it
DROP DATABASE universe;
CREATE DATABASE universe;
\c universe;

-- Table of galaxy types
CREATE TABLE galaxy_type(
  galaxy_type_id SERIAL PRIMARY KEY,
  name VARCHAR(50) UNIQUE NOT NULL,
  description TEXT,
  looks_cool BOOLEAN
);
INSERT INTO galaxy_type(name, description, looks_cool) VALUES
  ('E', 'Elliptical', FALSE),
  ('S', 'Spiral', TRUE),
  ('SB', 'Barred Spiral', TRUE);

-- Table of galaxies
CREATE TABLE galaxy(
  galaxy_id SERIAL PRIMARY KEY,
  name VARCHAR(50) UNIQUE NOT NULL,
  galaxy_type_id INT REFERENCES galaxy_type(galaxy_type_id),
  distance_kpc NUMERIC(9, 3),
  diameter_kpc NUMERIC(5, 2),
  magnitude NUMERIC(5, 3)
);
INSERT INTO galaxy(name, galaxy_type_id, distance_kpc, diameter_kpc, magnitude) VALUES
  ('Milky Way', 3, 8.277, 26.8, NULL),
  ('Large Magellanic Cloud', 3, 49.97, 9.86, 0.13),
  ('Andromeda', 2, 765, 46.56, 3.44),
  ('Messier 87', 1, 16400, 40.55, 8.6),
  ('Antennae galaxies', 3, 16970, 150, 11.2),
  ('NGC 3147', 2, 39600, NULL, 10.6),
  ('ESO 383-76', 1, 200590, 136.9, 11.252);

-- Table of star types
CREATE TABLE star_type(
  star_type_id SERIAL PRIMARY KEY,
  name VARCHAR(50) UNIQUE NOT NULL,
  description TEXT,
  temperature_K INT
);
INSERT INTO star_type(name, description, temperature_K) VALUES
  ('WR', 'Wolf-Rayet', 100000),
  ('O', 'Blue supergiant', 30000),
  ('B', 'Blue giant', 20000),
  ('A', 'A dwarf', 9000),
  ('F', 'Yellow-white dwarf', 7000),
  ('G', 'Yellow giant', 5500),
  ('K', 'Orange dwarf', 4500),
  ('M', 'Red dwarf', 3000),
  ('P', 'Pulsar', NULL);

-- Table of stars
CREATE TABLE star(
  star_id SERIAL PRIMARY KEY,
  name VARCHAR(50) UNIQUE NOT NULL,
  galaxy_id INT REFERENCES galaxy(galaxy_id),
  star_type_id INT REFERENCES star_type(star_type_id),
  distance_pc NUMERIC(10, 5),
  magnitude NUMERIC(5, 3)
);
INSERT INTO star(name, galaxy_id, star_type_id, distance_pc, magnitude) VALUES
  ('Helios', 1, 6, 0, -26.74),
  ('Proxima Centauri', 1, 8, 1.30197, 11),
  ('Beta Virginis', 1, 5, 10.93, 3.604),
  ('51 Pegasi', 1, 6, 15.53, 5.49),
  ('Kepler-452', 1, 6, 561, 13.426),
  ('PSR B1257+12', 1, 9, 710, NULL),
  ('HD 15558', 1, 2, 1700, 7.87),
  ('Melnick 42', 2, 2, 49970, 12.78),
  ('RMC 136a1', 2, 1, 49970, 12.23);

-- Table of planets
CREATE TABLE planet(
  planet_id SERIAL PRIMARY KEY,
  name VARCHAR(50) UNIQUE NOT NULL,
  star_id INT REFERENCES star(star_id) NOT NULL,
  semi_major_axis_AU NUMERIC(10, 8),
  orbital_period_d NUMERIC(14, 9),
  in_habitable_zone BOOLEAN
);
INSERT INTO planet(name, star_id, semi_major_axis_AU, orbital_period_d, in_habitable_zone) VALUES
  ('Mercury', 1, 0.387098, 87.9691, FALSE),
  ('Venus', 1, 0.723332, 224.701, TRUE),
  ('Earth', 1, 1, 365.256363004, TRUE),
  ('Mars', 1, 1.52368055, 686.980, TRUE),
  ('Jupiter', 1, 5.2038, 4332.59, FALSE),
  ('Saturn', 1, 9.5826, 10755.70, FALSE),
  ('Uranus', 1, 19.19126, 30688.5, FALSE),
  ('Neptune', 1, 30.07, 60195, FALSE),
  ('PSR B1257+12 b', 6, 0.19, 25.262, FALSE),
  ('Proxima Centauri d', 2, 0.02885, 5.122, FALSE),
  ('Proxima Centauri b', 2, 0.04856, 11.1868, TRUE),
  ('51 Pegasi b', 4, 0.0527, 4.230785, NULL),
  ('Kepler-452b', 5, 1.046, 384.843, TRUE);

-- Table of moons
CREATE TABLE moon(
  moon_id SERIAL PRIMARY KEY,
  name VARCHAR(50) UNIQUE NOT NULL,
  planet_id INT REFERENCES planet(planet_id),
  semi_major_axis_km INT,
  orbital_period_d NUMERIC(11, 9),
  radius_km NUMERIC(6, 2)
);
INSERT INTO moon(name, planet_id, semi_major_axis_km, orbital_period_d, radius_km) VALUES
  ('Luna', 3, 384399, 27.321661, 1737.4),
  ('Phobos', 4, 9376, 0.31891023, 11.08),
  ('Deimos', 4, 23463, 1.263, 6.27),
  ('Ganymede', 5, 1070400, 7.15455296, 2634.1),
  ('Callisto', 5, 1882700, 16.6890184, 2410.3),
  ('Io', 5, 421700, 1.769137786, 1821.6),
  ('Europa', 5, 670900, 3.551181, 1560.8),
  ('Titan', 6, 1221870, 15.945, 2574.73),
  ('Rhea', 6, 527108, 4.518212, 763.5),
  ('Iapetus', 6, 3560820, 79.3215, 734.4),
  ('Dione', 6, 377396, 2.736915, 561.4),
  ('Tethys', 6, 294619, 1.887802, 531.1),
  ('Enceladus', 6, 237948, 1.370218, 252.1),
  ('Mimas', 6, 185539, 0.942421959, 198.2),
  ('Titania', 7, 435910, 8.706234, 788.4),
  ('Oberon', 7, 583520, 13.463234, 761.4),
  ('Umbriel', 7, 266000, 4.144, 584.7),
  ('Ariel', 7, 191020, 2.520, 578.9),
  ('Miranda', 7, 129390, 1.413479, 235.8),
  ('Triton', 8, 354759, 5.876854, 1353.4);
