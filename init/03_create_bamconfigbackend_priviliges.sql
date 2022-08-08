-- Allow user to access schema
GRANT USAGE ON SCHEMA bamconfigbackend_user TO bamconfigbackend_user;

-- Allow user to execute CRUD operations
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA bamconfigbackend_user TO bamconfigbackend_user;