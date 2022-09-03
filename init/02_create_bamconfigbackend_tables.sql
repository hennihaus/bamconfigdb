DROP TABLE IF EXISTS bamconfigbackend_user.credit_configuration;
DROP TABLE IF EXISTS bamconfigbackend_user.statistic;
DROP TABLE IF EXISTS bamconfigbackend_user.student;
DROP TABLE IF EXISTS bamconfigbackend_user.team;
DROP TABLE IF EXISTS bamconfigbackend_user.bank;
DROP TABLE IF EXISTS bamconfigbackend_user.endpoint;
DROP TABLE IF EXISTS bamconfigbackend_user.endpoint_type_enum;
DROP TABLE IF EXISTS bamconfigbackend_user.task_parameter;
DROP TABLE IF EXISTS bamconfigbackend_user.task_response;
DROP TABLE IF EXISTS bamconfigbackend_user.parameter;
DROP TABLE IF EXISTS bamconfigbackend_user.parameter_type_enum;
DROP TABLE IF EXISTS bamconfigbackend_user.response;
DROP TABLE IF EXISTS bamconfigbackend_user.task;
DROP TABLE IF EXISTS bamconfigbackend_user.task_integration_step_enum;
DROP TABLE IF EXISTS bamconfigbackend_user.contact;

CREATE TABLE IF NOT EXISTS bamconfigbackend_user.team
(
    team_uuid UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    team_username TEXT NOT NULL UNIQUE,
    team_password TEXT NOT NULL UNIQUE,
    team_jms_queue TEXT NOT NULL UNIQUE,
    team_created_timestamp_with_time_zone TIMESTAMPTZ NOT NULL DEFAULT now(),
    team_updated_timestamp_with_time_zone TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT team_username_length CHECK (length(team_username) >= 6 AND length(team_username) <= 50),
    CONSTRAINT team_password_length CHECK (length(team_password) >= 56 AND length(team_password) <= 112),
    CONSTRAINT team_jms_queue_length CHECK (length(team_jms_queue) >= 6 AND length(team_jms_queue) <= 50)
);

CREATE TABLE IF NOT EXISTS bamconfigbackend_user.student
(
    student_uuid UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    team_uuid UUID NOT NULL REFERENCES bamconfigbackend_user.team ON DELETE CASCADE ON UPDATE NO ACTION,
    student_firstname TEXT NOT NULL,
    student_lastname TEXT NOT NULL,
    student_created_timestamp_with_time_zone TIMESTAMPTZ NOT NULL DEFAULT now(),
    student_updated_timestamp_with_time_zone TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT student_firstname_length CHECK (length(student_firstname) >= 2 AND length(student_firstname) <= 50),
    CONSTRAINT student_lastname_length CHECK (length(student_lastname) >= 2 AND length(student_lastname) <= 50)
);

CREATE TABLE IF NOT EXISTS bamconfigbackend_user.contact
(
    contact_uuid UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    contact_firstname TEXT NOT NULL,
    contact_lastname TEXT NOT NULL,
    contact_email TEXT NOT NULL,
    contact_created_timestamp_with_time_zone TIMESTAMPTZ NOT NULL DEFAULT now(),
    contact_updated_timestamp_with_time_zone TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT contact_firstname_length CHECK (length(contact_firstname) >= 2 AND length(contact_firstname) <= 50),
    CONSTRAINT contact_lastname_length CHECK (length(contact_lastname) >= 2 AND length(contact_lastname) <= 50),
    CONSTRAINT contact_email_pattern CHECK (contact_email ~* '^[A-Za-z0-9._+%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$')
);

CREATE TABLE IF NOT EXISTS bamconfigbackend_user.task_integration_step_enum
(
    task_integration_step INTEGER PRIMARY KEY,
    CONSTRAINT task_integration_step_positive_exclusive_zero CHECK (task_integration_step >= 1)
);

CREATE TABLE IF NOT EXISTS bamconfigbackend_user.task
(
    task_uuid UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    contact_uuid UUID NOT NULL UNIQUE REFERENCES bamconfigbackend_user.contact ON DELETE CASCADE ON UPDATE NO ACTION,
    task_integration_step INTEGER NOT NULL UNIQUE REFERENCES bamconfigbackend_user.task_integration_step_enum ON DELETE CASCADE ON UPDATE NO ACTION,
    task_title TEXT NOT NULL UNIQUE,
    task_description TEXT NOT NULL,
    task_is_open_api_verbose BOOLEAN NOT NULL,
    task_created_timestamp_with_time_zone TIMESTAMPTZ NOT NULL DEFAULT now(),
    task_updated_timestamp_with_time_zone TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT task_title_length CHECK (length(task_title) >= 6 AND length(task_title) <= 50),
    CONSTRAINT task_description_length CHECK (length(task_description) >= 0 AND length(task_description) <= 2000)
);

CREATE TABLE IF NOT EXISTS bamconfigbackend_user.endpoint_type_enum
(
    endpoint_type TEXT PRIMARY KEY,
    CONSTRAINT endpoint_type_length CHECK (length(endpoint_type) >= 1),
    CONSTRAINT endpoint_type_uppercase CHECK (upper(endpoint_type) = endpoint_type)
);

CREATE TABLE IF NOT EXISTS bamconfigbackend_user.endpoint
(
    endpoint_uuid UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    task_uuid UUID NOT NULL REFERENCES bamconfigbackend_user.task ON DELETE CASCADE ON UPDATE NO ACTION,
    endpoint_type TEXT NOT NULL REFERENCES bamconfigbackend_user.endpoint_type_enum ON DELETE CASCADE ON UPDATE NO ACTION,
    endpoint_url TEXT NOT NULL,
    endpoint_docs_url TEXT NOT NULL,
    CONSTRAINT endpoint_url_pattern CHECK (endpoint_url ~* '(^$|^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?)'),
    CONSTRAINT endpoint_docs_url_pattern CHECK (endpoint_docs_url ~* '(^$|^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?)')
);

CREATE TABLE IF NOT EXISTS bamconfigbackend_user.parameter_type_enum
(
    parameter_type TEXT PRIMARY KEY,
    CONSTRAINT parameter_type_length CHECK (length(parameter_type) >= 1),
    CONSTRAINT parameter_type_uppercase CHECK (upper(parameter_type) = parameter_type)
);

CREATE TABLE IF NOT EXISTS bamconfigbackend_user.parameter
(
    parameter_uuid UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    parameter_name TEXT NOT NULL UNIQUE,
    parameter_type TEXT NOT NULL REFERENCES bamconfigbackend_user.parameter_type_enum ON DELETE CASCADE ON UPDATE NO ACTION,
    parameter_description TEXT NOT NULL,
    parameter_example TEXT NOT NULL,
    parameter_created_timestamp_with_time_zone TIMESTAMPTZ NOT NULL DEFAULT now(),
    parameter_updated_timestamp_with_time_zone TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT parameter_name_length CHECK (length(parameter_name) >= 2 AND length(parameter_name) <= 50),
    CONSTRAINT parameter_description_length CHECK (length(parameter_description) >= 0 AND length(parameter_description) <= 100),
    CONSTRAINT parameter_example_length CHECK (length(parameter_example) >= 1 AND length(parameter_example) <= 50)
);

CREATE TABLE IF NOT EXISTS bamconfigbackend_user.task_parameter
(
    task_uuid UUID NOT NULL REFERENCES bamconfigbackend_user.task ON DELETE CASCADE ON UPDATE NO ACTION,
    parameter_uuid UUID NOT NULL REFERENCES bamconfigbackend_user.parameter ON DELETE CASCADE ON UPDATE NO ACTION,
    PRIMARY KEY (task_uuid, parameter_uuid)
);

CREATE TABLE IF NOT EXISTS bamconfigbackend_user.response
(
    response_uuid  UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    response_http_status_code INTEGER NOT NULL,
    response_content_type TEXT NOT NULL,
    response_description  TEXT NOT NULL,
    response_example_json JSONB NOT NULL,
    response_created_timestamp_with_time_zone TIMESTAMPTZ NOT NULL DEFAULT now(),
    response_updated_timestamp_with_time_zone TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT response_http_status_code_range CHECK (response_http_status_code >= -1 AND response_http_status_code <= 999),
    CONSTRAINT response_content_type_not_empty CHECK (length(response_content_type) >= 1),
    CONSTRAINT response_description_length CHECK (length(response_description) >= 1 AND length(response_description) <= 100),
    CONSTRAINT response_example_json_not_empty CHECK (response_example_json <> '{}')
);

CREATE TABLE IF NOT EXISTS bamconfigbackend_user.task_response
(
    task_uuid UUID NOT NULL REFERENCES bamconfigbackend_user.task ON DELETE CASCADE ON UPDATE NO ACTION,
    response_uuid UUID NOT NULL REFERENCES bamconfigbackend_user.response ON DELETE CASCADE ON UPDATE NO ACTION,
    PRIMARY KEY (task_uuid, response_uuid)
);

CREATE TABLE IF NOT EXISTS bamconfigbackend_user.bank
(
    bank_uuid UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    task_uuid UUID NOT NULL REFERENCES bamconfigbackend_user.task ON DELETE CASCADE ON UPDATE NO ACTION,
    bank_name TEXT NOT NULL UNIQUE,
    bank_jms_queue TEXT NOT NULL UNIQUE,
    bank_thumbnail_url TEXT NOT NULL,
    bank_is_async BOOLEAN NOT NULL,
    bank_is_active BOOLEAN NOT NULL,
    bank_created_timestamp_with_time_zone TIMESTAMPTZ NOT NULL DEFAULT now(),
    bank_updated_timestamp_with_time_zone TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT bank_name_length CHECK (length(bank_name) >= 6 AND length(bank_name) <= 50),
    CONSTRAINT bank_jms_queue_length CHECK (length(bank_jms_queue) >= 6 AND length(bank_jms_queue) <= 50),
    CONSTRAINT bank_thumbnail_url_pattern CHECK (bank_thumbnail_url ~* '(^$|^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?)')
);

CREATE TABLE IF NOT EXISTS bamconfigbackend_user.statistic
(
    statistic_id SERIAL PRIMARY KEY,
    bank_uuid UUID NOT NULL REFERENCES bamconfigbackend_user.bank ON DELETE CASCADE ON UPDATE NO ACTION,
    team_uuid UUID NOT NULL REFERENCES bamconfigbackend_user.team ON DELETE CASCADE ON UPDATE NO ACTION,
    statistic_requests_count BIGINT NOT NULL DEFAULT 0,
    statistic_created_timestamp_with_time_zone TIMESTAMPTZ NOT NULL DEFAULT now(),
    statistic_updated_timestamp_with_time_zone TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT bank_uuid_team_uuid_unique UNIQUE(bank_uuid, team_uuid),
    CONSTRAINT statistic_requests_count_positive_inclusive_zero CHECK (statistic_requests_count >= 0)
);

CREATE TABLE IF NOT EXISTS bamconfigbackend_user.credit_configuration_rating_level_enum
(
    credit_configuration_rating_level TEXT PRIMARY KEY,
    CONSTRAINT credit_configuration_rating_level_length CHECK (length(credit_configuration_rating_level) >= 1 AND length(credit_configuration_rating_level) <= 1),
    CONSTRAINT credit_configuration_rating_level_uppercase CHECK (upper(credit_configuration_rating_level) = credit_configuration_rating_level)
);


CREATE TABLE IF NOT EXISTS bamconfigbackend_user.credit_configuration
(
    credit_configuration_uuid UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    bank_uuid UUID NOT NULL UNIQUE REFERENCES bamconfigbackend_user.bank ON DELETE CASCADE ON UPDATE NO ACTION,
    credit_configuration_min_amount_in_euros INTEGER NOT NULL,
    credit_configuration_max_amount_in_euros INTEGER NOT NULL,
    credit_configuration_min_term_in_months INTEGER NOT NULL,
    credit_configuration_max_term_in_months INTEGER NOT NULL,
    credit_configuration_min_schufa_rating TEXT NOT NULL REFERENCES bamconfigbackend_user.credit_configuration_rating_level_enum ON DELETE CASCADE ON UPDATE NO ACTION,
    credit_configuration_max_schufa_rating TEXT NOT NULL REFERENCES bamconfigbackend_user.credit_configuration_rating_level_enum ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT min_amount_in_euros_positive_inclusive_zero CHECK (credit_configuration_min_amount_in_euros >= 0),
    CONSTRAINT max_amount_in_euros_positive_inclusive_zero CHECK (credit_configuration_max_amount_in_euros >= 0),
    CONSTRAINT min_term_in_months_positive_inclusive_zero CHECK (credit_configuration_min_term_in_months >= 0),
    CONSTRAINT max_term_in_months_positive_inclusive_zero CHECK (credit_configuration_max_term_in_months >= 0),
    CONSTRAINT min_amount_in_euros_smaller_equals_max_amount_in_euros CHECK (credit_configuration_min_amount_in_euros <= credit_configuration_max_amount_in_euros),
    CONSTRAINT min_term_in_months_smaller_equals_max_term_in_months CHECK (credit_configuration_min_term_in_months <= credit_configuration_max_term_in_months),
    CONSTRAINT min_schufa_rating_smaller_equals_max_schufa_rating CHECK (credit_configuration_min_schufa_rating <= credit_configuration_max_schufa_rating)
);

ALTER TABLE bamconfigbackend_user.team OWNER TO bamconfigbackend_owner;
ALTER TABLE bamconfigbackend_user.student OWNER TO bamconfigbackend_owner;
ALTER TABLE bamconfigbackend_user.contact OWNER TO bamconfigbackend_owner;
ALTER TABLE bamconfigbackend_user.task_integration_step_enum OWNER TO bamconfigbackend_owner;
ALTER TABLE bamconfigbackend_user.task OWNER TO bamconfigbackend_owner;
ALTER TABLE bamconfigbackend_user.endpoint_type_enum OWNER TO bamconfigbackend_owner;
ALTER TABLE bamconfigbackend_user.endpoint OWNER TO bamconfigbackend_owner;
ALTER TABLE bamconfigbackend_user.parameter_type_enum OWNER TO bamconfigbackend_owner;
ALTER TABLE bamconfigbackend_user.parameter OWNER TO bamconfigbackend_owner;
ALTER TABLE bamconfigbackend_user.task_parameter OWNER TO bamconfigbackend_owner;
ALTER TABLE bamconfigbackend_user.response OWNER TO bamconfigbackend_owner;
ALTER TABLE bamconfigbackend_user.task_response OWNER TO bamconfigbackend_owner;
ALTER TABLE bamconfigbackend_user.bank OWNER TO bamconfigbackend_owner;
ALTER TABLE bamconfigbackend_user.statistic OWNER TO bamconfigbackend_owner;
ALTER TABLE bamconfigbackend_user.credit_configuration_rating_level_enum OWNER TO bamconfigbackend_owner;
ALTER TABLE bamconfigbackend_user.credit_configuration OWNER TO bamconfigbackend_owner;