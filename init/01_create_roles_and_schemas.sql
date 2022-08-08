-- Create Roles
CREATE ROLE bamconfigbackend_owner NOLOGIN;
CREATE ROLE bamconfigbackend_user LOGIN PASSWORD 'dn6WC8NTtM3WmCXA';

-- Enable Schema Usage Pattern
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
ALTER ROLE bamconfigbackend_owner SET search_path = '$user';
ALTER ROLE bamconfigbackend_user SET search_path = '$user';

-- Create Schemas
CREATE SCHEMA bamconfigbackend_user AUTHORIZATION bamconfigbackend_owner;