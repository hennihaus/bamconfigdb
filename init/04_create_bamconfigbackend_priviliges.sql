-- Allow user to access schema
GRANT USAGE ON SCHEMA bamconfigbackend_user TO bamconfigbackend_user;

-- Allow user to access generated keys
GRANT USAGE ON SEQUENCE bamconfigbackend_user.statistic_statistic_id_seq TO bamconfigbackend_user;

-- Allow user to execute CRUD operations
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA bamconfigbackend_user TO bamconfigbackend_user;