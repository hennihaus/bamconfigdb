CREATE RULE protect_example_team AS ON DELETE TO bamconfigbackend_user.team WHERE team_type = 'EXAMPLE' DO INSTEAD NOTHING;