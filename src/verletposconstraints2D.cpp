#include "VerletPosConstraints2D.h"

using namespace godot;


void VerletPosConstraints::_register_methods() {
	register_method("set_arrays", &VerletPosConstraints::set_arrays);
	register_method("set_initial_positions", &VerletPosConstraints::set_initial_positions);
	register_method("set_first_particle_position", &VerletPosConstraints::set_first_particle_position);
	register_method("get_last_particle_position", &VerletPosConstraints::get_last_particle_position);
	register_method("offset_particle_position_after_lasso", &VerletPosConstraints::offset_particle_position_after_lasso);
	register_method("begin_simulation", &VerletPosConstraints::begin_simulation);
	register_method("get_pos_curr", &VerletPosConstraints::get_pos_curr);
	register_method("try_apply_impulse", &VerletPosConstraints::try_apply_impulse);
	register_method("is_impulse_applied", &VerletPosConstraints::is_impulse_applied);
	register_method("set_player_body", &VerletPosConstraints::set_player_body);
	register_method("fix_last_area", &VerletPosConstraints::fix_last_area);
	register_method("is_able_to_hit", &VerletPosConstraints::is_able_to_hit);
	register_method("get_pull_rope_direction", &VerletPosConstraints::get_pull_rope_direction);
	register_method("try_lasso_from_hitting_player", &VerletPosConstraints::try_lasso_from_hitting_player);
	register_method("get_first_collision_to_body", &VerletPosConstraints::get_first_collision_to_body);
	register_method("set_last_particle_pointer", &VerletPosConstraints::set_last_particle_pointer);
	register_method("check_lasso_with_collision", &VerletPosConstraints::check_lasso_with_collision);
	register_method("is_limiting_rope_length", &VerletPosConstraints::is_limiting_rope_length);
	register_method("get_limit_rope_length_center", &VerletPosConstraints::get_limit_rope_length_center);
	register_method("get_limit_rope_length_size", &VerletPosConstraints::get_limit_rope_length_size);

	register_method("apply_constraints", &VerletPosConstraints::apply_constraints<State::LOOSE>);
	register_method("verlet_process", &VerletPosConstraints::verlet_process);
	register_method("lasso_momentum", &VerletPosConstraints::lasso_momentum);
	register_method("simulate", &VerletPosConstraints::simulate);

	register_property<VerletPosConstraints, float>("start_at_particle", &VerletPosConstraints::start_at_particle, 0);
	register_property<VerletPosConstraints, int>("iterations", &VerletPosConstraints::iterations, 5);
    register_property<VerletPosConstraints, int>("simulation_particles", &VerletPosConstraints::simulation_particles, 50);
	register_property<VerletPosConstraints, int>("nb_particles_sharing_area", &VerletPosConstraints::nb_particles_sharing_area, 10);
	register_property<VerletPosConstraints, float>("segment_length", &VerletPosConstraints::segment_length, 1.0);
	register_property<VerletPosConstraints, float>("stiffness", &VerletPosConstraints::stiffness, 1.0);
	register_property<VerletPosConstraints, float>("impulse_factor", &VerletPosConstraints::impulse_factor, 1.0);
	register_property<VerletPosConstraints, float>("clockwise", &VerletPosConstraints::clockwise, 1.0);
	register_property<VerletPosConstraints, float>("goal_radius", &VerletPosConstraints::goal_radius, 1.0);
	register_property<VerletPosConstraints, float>("max_length", &VerletPosConstraints::max_length, 1000);
	register_property<VerletPosConstraints, float>("total_length", &VerletPosConstraints::total_length, 0);

	register_property<VerletPosConstraints, Array>("areas", &VerletPosConstraints::areas, Array());

	register_signal<VerletPosConstraints>((char*)"hit", "body", GODOT_VARIANT_TYPE_OBJECT);
	register_signal<VerletPosConstraints>((char*)"state_changed", "new_state", GODOT_VARIANT_TYPE_INT);
}

VerletPosConstraints::VerletPosConstraints() {
}

VerletPosConstraints::~VerletPosConstraints() {
}

void VerletPosConstraints::_init() {
	state = State::LOOSE;
	apply_impulse = false;
	lone_kinematic = nullptr;
	lasso_index = -1;
	orbit_angle = 0;
	orbit_radius = 0;
}


void VerletPosConstraints::set_state(State new_state) {
	state = new_state;
	emit_signal("state_changed", new_state);
}


void VerletPosConstraints::set_last_particle_pointer(CollisionObject2D* last_particle_pointer) {
	last_particle = last_particle_pointer;
}


Vector2 VerletPosConstraints::get_last_particle_position() {
	return get_orbit_position();
}


Vector2 VerletPosConstraints::get_pull_rope_direction() {
	if (state == LAST_FIXED) {
		if (first_collision_index > 0) {
			return (pos_curr_container[first_collision_index] - pos_curr_container[0]).normalized();
		}
		else {
			return (pos_curr_container[simulation_particles - 1] - pos_curr_container[0]).normalized();
		}
	}
	if (state == LASSO) {
		return (pos_curr_container[lasso_index] - pos_curr_container[0]).normalized();
	}
	return Vector2::ZERO;
}


void VerletPosConstraints::fix_last_area(Vector2 at_position) {
	if (state == LOOSE || state == TIGHT) {
		set_state(LAST_FIXED);
		auto pos_curr = pos_curr_container.write();
		pos_curr[simulation_particles - 1] = at_position;
	}
}


void VerletPosConstraints::try_lasso_from_hitting_player() {
	if (state == State::TIGHT) {
		set_state(State::CHECK_LONE_KINEMATIC);
		lasso_index = 0;
	}
}


bool VerletPosConstraints::is_able_to_hit() {
	return (state == LOOSE || state == TIGHT);
}


bool VerletPosConstraints::is_impulse_applied() {
	return apply_impulse;
}


void VerletPosConstraints::try_apply_impulse() {
	if (state == State::LASSO) {
		apply_impulse = true;
	}
	else if (state == State::LONE_KINEMATIC) {
		apply_impulse = true;
		orbit_center_is_player = false;
		change_orbit_with_position(last_collision_point, lone_kinematic->get_global_position());
		lone_kinematic->start_rope_interaction();
	}
}


void VerletPosConstraints::set_player_body(Variant v) {
	player_body = Object::cast_to<Area2D>(v);
}


const PoolVector2Array VerletPosConstraints::get_pos_curr() {
	return pos_curr_container;
}


void VerletPosConstraints::begin_simulation(Vector2 direction, float clockwise_param, float spin_speed_param, float impulse_speed_param) {
	_init();
	clockwise = clockwise_param;
	auto r_theta = Math::cartesian2polar(direction);
	orbit_angle = r_theta.y;
	goal_radius = r_theta.x;
	spin_speed = spin_speed_param;
	impulse_speed = impulse_speed_param;
	compute_start_at_particle(goal_radius, 0);
}


void VerletPosConstraints::set_arrays(PoolVector2Array pos_curr_, PoolVector2Array pos_prev_) {
	pos_curr_container = pos_curr_;
	pos_prev_container = pos_prev_;
}



Vector2 VerletPosConstraints::get_orbit_position() {
	auto offset = Math::polar2cartesian(Vector2(orbit_radius, orbit_angle));
	return orbit_center + offset;
}


void VerletPosConstraints::change_orbit_with_position(Vector2 new_orbit_center, Vector2 original_position) {
	if (last_collision_index > 0 || !orbit_center_is_player) {
		auto old_length = orbit_radius;
		orbit_center = new_orbit_center;
		auto offset = original_position - orbit_center;
		auto r_theta = Math::cartesian2polar(offset);
		orbit_radius = r_theta.x;
		orbit_angle = r_theta.y;
		orbit_center_is_player = (last_collision_index == 0);
	}
	else {
		// Move with the lasso arount, lasso does not change radius
		orbit_center = new_orbit_center;
	}
}


void VerletPosConstraints::change_orbit(Vector2 new_orbit_center) {
	auto original_position = get_orbit_position();
	change_orbit_with_position(new_orbit_center, original_position);
}


void VerletPosConstraints::compute_orbit_position(float delta) {
	if (state == State::LOOSE) {
		orbit_center = pos_curr_container[0];
		orbit_radius += delta * impulse_speed;
		if (orbit_radius > goal_radius) {
			orbit_radius = goal_radius;
		}
		orbit_angle += clockwise * delta * orbit_radius * spin_speed;
	}
	else if (state == State::TIGHT) {
		if (orbit_center != last_collision_point) {
			change_orbit(last_collision_point);
		}
		orbit_angle += clockwise * delta * spin_speed * goal_radius * goal_radius / orbit_radius;
	}
	else if (state == State::LONE_KINEMATIC && apply_impulse) {
		if (orbit_center != last_collision_point) {
			change_orbit(last_collision_point);
		}
		auto angle_offset = clockwise * delta * spin_speed * goal_radius * goal_radius / orbit_radius;
		orbit_angle += angle_offset;
		auto new_position = get_orbit_position();
		lone_kinematic->move_to(new_position - lone_kinematic->get_global_position(), this, orbit_center);
		offset_particle_position_after_lasso(angle_offset);
	}
}


void VerletPosConstraints::set_initial_positions(Vector2 position) {
	auto pos_curr = pos_curr_container.write();
	auto pos_prev = pos_prev_container.write();
	for (int i = 0; i < simulation_particles; i++) {
		pos_curr[i] = position;
		pos_prev[i] = position;
	}
	orbit_center = position;
	orbit_center_is_player = true;
}


void VerletPosConstraints::offset_particle_position_after_lasso(float angle_offset) {
	auto pos_curr = pos_curr_container.write();
	auto pos_prev = pos_prev_container.write();
	for (int i = last_collision_index; i < simulation_particles; i++) {
		auto offset = pos_curr[i] - orbit_center;
		auto r_theta = Math::cartesian2polar(offset);
		r_theta.y += angle_offset;
		auto new_position = Math::polar2cartesian(r_theta) + orbit_center;
		pos_curr[i] = new_position;
		pos_prev[i] = new_position;
	}
}


void VerletPosConstraints::set_first_particle_position(Vector2 position) {
	auto pos_curr = pos_curr_container.write();
	auto pos_prev = pos_prev_container.write();
	for (int i = 0; i <= start_at_particle; i++) {
		pos_curr[i] = position;
		pos_prev[i] = position;
	}
}


void VerletPosConstraints::dispatch_apply_constraints() {
	switch (state) {
	case State::LOOSE:
		apply_constraints<State::LOOSE>();
		break;

	case State::TIGHT:
		apply_constraints<State::TIGHT>();
		break;

	case State::LASSO:
		apply_constraints<State::LASSO>();
		break;

	case State::CHECK_LONE_KINEMATIC:
		apply_constraints<State::CHECK_LONE_KINEMATIC>();
		break;

	case State::LONE_KINEMATIC:
		apply_constraints<State::LONE_KINEMATIC>();
		break;

	case State::LAST_FIXED:
		apply_constraints<State::LAST_FIXED>();
		break;
	}
}


void VerletPosConstraints::compute_start_at_particle(float length, float step) {
	auto goal_start_at_particle = simulation_particles * (1 - length / max_length);
	if (goal_start_at_particle < 0)
		goal_start_at_particle = 0;
	if (step <= 0) {
		start_at_particle = goal_start_at_particle;
	}
	else {
		if (start_at_particle > goal_start_at_particle) {
			start_at_particle -= step;
			if (start_at_particle < goal_start_at_particle) {
				start_at_particle = goal_start_at_particle;
			}
		}
		else if (start_at_particle < goal_start_at_particle) {
			start_at_particle += step;
			if (start_at_particle > goal_start_at_particle) {
				start_at_particle = goal_start_at_particle;
			}
		}
	}
}


bool VerletPosConstraints::is_limiting_rope_length() {
	if (state == State::LASSO || state == State::LAST_FIXED) {
		return true;
	}
	return false;
}


Vector2 VerletPosConstraints::get_limit_rope_length_center() {
	if (first_collision_index < 0) {
		return pos_curr_container[simulation_particles - 1];
	}
	return pos_curr_container[first_collision_index];
}


float VerletPosConstraints::get_limit_rope_length_size() {
	auto limit_center = get_limit_rope_length_center();
	return max_length - (total_length - limit_center.distance_to(pos_curr_container[0]));
}


void VerletPosConstraints::simulate(Vector2 first_particle_position, Vector2 last_particle_position, float delta) {
	set_first_particle_position(first_particle_position);

	total_length = compute_total_length();

	if (state == State::LOOSE || state == State::TIGHT) {
		auto pos_curr = pos_curr_container.write();
		pos_curr[simulation_particles - 1] = get_orbit_position();
	}
	if (state == State::LASSO || state == State::LAST_FIXED) {
		compute_start_at_particle(total_length, 0.3);
	}

	verlet_process(delta);

	update_bodies_transforms();
	
	last_collision_point = first_particle_position;
	last_collision_index = 0;
	first_collision_index = -1;

	dispatch_apply_constraints();

	update_areas_transform();

	check_lasso();

	compute_orbit_position(delta);
}


void VerletPosConstraints::check_lasso() {
	if (state == State::TIGHT || state == State::LAST_FIXED) {
		for (int i = int(start_at_particle) + 1; i < last_collision_index; i++) {
			auto area = (VerletParticleArea*)(areas[i]);
			if (area->check_lasso(i, pos_curr_container, last_collision_index, pos_curr_container[simulation_particles - 1], nb_particles_sharing_area, last_particle)) {
				lasso_index = i;
				set_state(State::CHECK_LONE_KINEMATIC);
				return;
			}
		}
	}
	return;
}


void VerletPosConstraints::check_lasso_with_collision(CollisionObject2D* body, Vector2 collision_position) {
	if (state == State::TIGHT || state == State::LAST_FIXED) {
		for (int i = int(start_at_particle) + 1; i < last_collision_index; i++) {
			auto area = (VerletParticleArea*)(areas[i]);
			if (area->check_lasso_with_collision(i, pos_curr_container, body, collision_position)) {
				lasso_index = i;
				set_state(State::CHECK_LONE_KINEMATIC);
				return;
			}
		}
	}
	return;
}


void VerletPosConstraints::verlet_process(float delta) {
	auto pos_curr = pos_curr_container.write();
	auto pos_prev = pos_prev_container.write();
	auto stop_at_particle = simulation_particles - 1;
	// velocity for other particles is already done by the orbit
	if (state == LONE_KINEMATIC && apply_impulse) {
		stop_at_particle = last_collision_index;
	}
	for (int i = int(start_at_particle) + 1; i < stop_at_particle; i++) {
		auto curr = pos_curr[i];
		auto prev = pos_prev[i];
		pos_curr[i] = 2.0 * curr - prev;
		pos_prev[i] = curr;
	}
}


float VerletPosConstraints::compute_total_length() {
	float total_length = 0;
	for (int i = int(start_at_particle); i < simulation_particles - 1; i++) {
		total_length += pos_curr_container[i].distance_to(pos_curr_container[i + 1]);
	}
	return total_length;
}


void VerletPosConstraints::update_areas_transform() {
	auto pos_curr = pos_curr_container;
	for (int i = int(start_at_particle); i < simulation_particles; i++) {
		auto area = Object::cast_to<VerletParticleArea>(areas[i]);
		auto transform = area->get_transform();
		transform.set_origin(pos_curr[i]);
		area->set_transform(transform);
		areas[i] = area;
	}
}


void VerletPosConstraints::apply_lasso_constraint(PoolVector2Array::Write& pos_curr, Vector2 update, int i) {
	update *= 0.5;
	pos_curr[i] += update;
	auto updated_pos = pos_curr[i + 1] - update;
	auto distance_i = pos_curr[lasso_index].distance_squared_to(updated_pos);
	while (lasso_index < simulation_particles - 1) {
		auto next_distance = pos_curr[lasso_index + 1].distance_squared_to(updated_pos);
		if (next_distance > distance_i)
			break;
		lasso_index++;
		distance_i = next_distance;
	}
	while (lasso_index > 1 + int(start_at_particle)) {
		auto next_distance = pos_curr[lasso_index - 1].distance_squared_to(updated_pos);
		if (next_distance > distance_i)
			break;
		lasso_index--;
		distance_i = next_distance;
	}
	pos_curr[simulation_particles - 1] = pos_curr[lasso_index];
	pos_curr[lasso_index] -= update;
}


void VerletPosConstraints::update_bodies_transforms() {
	for (int i = int(start_at_particle); i < simulation_particles - 1; i++) {
		auto area = (VerletParticleArea*)(areas[i]);
		area->update_transforms();
	}
}


template <bool is_lasso>
void VerletPosConstraints::verlet_update(PoolVector2Array::Write& pos_curr, int i) {
	Vector2 r = pos_curr[i + 1] - pos_curr[i];
	float length = r.length();
	float d = length - segment_length;
	if (length > 0)
		r = r / length;
	Vector2 update = r * d * stiffness;
	if (i == int(start_at_particle))
		pos_curr[i + 1] -= update;
	else if (i == simulation_particles - 2) {
		if constexpr (is_lasso) {
			apply_lasso_constraint(pos_curr, update, i);
		}
		else {
			pos_curr[i] += update;
		}
	}
	else {
		update *= 0.5;
		pos_curr[i] += update;
		pos_curr[i + 1] -= update;
	}
}


template <VerletPosConstraints::State state_const>
void VerletPosConstraints::apply_constraints() {
	auto pos_curr = pos_curr_container.write();

	for (int n = 0; n < iterations - 1; n++) {
		auto rope_has_collided = false;
		for (int i = int(start_at_particle); i < simulation_particles - 1; i++) {
			if constexpr (state_const == LASSO || state_const == CHECK_LONE_KINEMATIC || state_const == LONE_KINEMATIC) {
				verlet_update<true>(pos_curr, i);
			}
			else {
				verlet_update<false>(pos_curr, i);
			}

			const auto area = (VerletParticleArea*)(areas[i]);
			// Lasso must go through the player if the player is in the lasso loop
			auto collide_with_player = rope_has_collided && (state != State::LASSO || i < lasso_index);
			if constexpr (state_const == State::CHECK_LONE_KINEMATIC || state_const == State::LONE_KINEMATIC) {
				collide_with_player = false;
			}
			rope_has_collided |= area->apply_constraints(pos_curr[i], pos_curr[i + 1], false, impulse_factor, collide_with_player, player_body, last_particle);
		}
	}

	float final_length = 0;
	auto last_no_collision_index = 0;
	CollisionObject2D* body = nullptr;
	auto rope_has_collided = false;
	auto check_lone_kinematic = true;
	for (int i = int(start_at_particle); i < simulation_particles - 1; i++) {
		if constexpr (state_const == LASSO || state_const == CHECK_LONE_KINEMATIC || state_const == LONE_KINEMATIC) {
			verlet_update<true>(pos_curr, i);
		}
		else {
			verlet_update<false>(pos_curr, i);
		}

		const auto area = (VerletParticleArea*)(areas[i]);

		if constexpr (state_const == State::CHECK_LONE_KINEMATIC) {
			CollisionObject2D* body_returned = nullptr;
			auto tangent = pos_curr[i + 1] - pos_curr[i];
			// Dont collide with player this frame to check lone kinematic
			auto collide_with_player = false;
			const auto is_collision = area->apply_constraints_with_report_kinematic(pos_curr[i], pos_curr[i + 1], apply_impulse, impulse_factor, collide_with_player, player_body, clockwise, tangent, body_returned, last_particle);
			rope_has_collided |= is_collision;
			if (is_collision) {
				// if we are lasso ing a kinematic we only care about points before the lasso
				if (i < lasso_index) {
					last_collision_point = pos_curr[i];
					last_collision_index = i;
				}

				if (first_collision_index < 0) {
					first_collision_index = i;
				}

				// more than one collision in the lasso
				if (body && body_returned != body) {
					check_lone_kinematic = false;
				}
				body = body_returned;
			}
		}
		else {
			// Lasso must go through the player if the player is in the lasso loop
			auto collide_with_player = rope_has_collided && (state != State::LASSO || i < lasso_index);
			if constexpr (state_const == State::CHECK_LONE_KINEMATIC || state_const == State::LONE_KINEMATIC) {
				collide_with_player = false;
			}
			// Dont apply impulse here for flail, impulse is applied by the orbit
			auto local_apply_impulse = state == State::LAST_FIXED || state == State::LASSO;
			const auto is_collision = area->apply_constraints(pos_curr[i], pos_curr[i + 1], local_apply_impulse, impulse_factor, collide_with_player, player_body, last_particle);

			rope_has_collided |= is_collision;
			if (is_collision) {

				if constexpr (state_const == State::LONE_KINEMATIC) {
					// if we are lasso ing a kinematic we only care about points before the lasso
					if (i < lasso_index) {
						last_collision_point = pos_curr[i];
						last_collision_index = i;
					}
				}

				else {
					last_collision_point = pos_curr[i];
					last_collision_index = i;
				}

				if (first_collision_index < 0) {
					first_collision_index = i;
				}

				if constexpr (state_const == State::LOOSE) {
					final_length += pos_curr[last_no_collision_index].distance_to(pos_curr[i]);
					last_no_collision_index = i;
				}

			}
		}
	}

	if constexpr (state_const == State::LOOSE) {
		final_length += pos_curr[last_no_collision_index].distance_to(pos_curr[simulation_particles - 1]);
		if (final_length >= goal_radius) {
			set_state(State::TIGHT);
		}
	}
	else if constexpr (state_const == State::CHECK_LONE_KINEMATIC) {
		if (check_lone_kinematic) {
			check_lone_kinematic = false;
			auto body_as_kinematic = Object::cast_to<KinematicRopeCollider>(body);
			if (body_as_kinematic) {
				lone_kinematic = body_as_kinematic;
				set_state(State::LONE_KINEMATIC);
				return;
			}
		}
		set_state(State::LASSO);
	}
}


void VerletPosConstraints::lasso_momentum() {
	auto pos_curr = pos_curr_container.write();
	auto range = 5;
	auto velocity = (pos_curr[simulation_particles - 1] - pos_prev_container[simulation_particles - 1]) * 5 ;
	for (int i = 0; i < range; i++) {
		auto ind = lasso_index + i;
		if (ind < simulation_particles) {
			pos_curr[ind] = pos_prev_container[ind] + velocity;
		}
		ind = lasso_index - i;
		if (ind > 0) {
			pos_curr[ind] = pos_prev_container[ind] + velocity;
		}
	}
}


Vector2 VerletPosConstraints::get_first_collision_to_body(CollisionObject2D* body) {
	for (int i = int(start_at_particle); i < simulation_particles - 1; i++) {
		const auto area = (VerletParticleArea*)(areas[i]);
		if (area->is_colliding_with_body(pos_curr_container[i], pos_curr_container[i + 1], body)) {
			return pos_curr_container[i];
		}
	}
	return pos_curr_container[simulation_particles - 1];
}