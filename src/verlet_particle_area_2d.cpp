#include "verlet_particle_area_2d.h"

using namespace godot;

void VerletParticleArea::_register_methods() {
	register_method("_on_Area_body_shape_entered", &VerletParticleArea::_on_Area_body_shape_entered);
	register_method("_on_Area_body_shape_exited", &VerletParticleArea::_on_Area_body_shape_exited);
}

VerletParticleArea::VerletParticleArea() {
}

VerletParticleArea::~VerletParticleArea() {
}

void VerletParticleArea::_init() {
    this->connect("body_shape_entered", this, "_on_Area_body_shape_entered");
	this->connect("body_shape_exited", this, "_on_Area_body_shape_exited");
	this->connect("area_shape_entered", this, "_on_Area_body_shape_entered");
	this->connect("area_shape_exited", this, "_on_Area_body_shape_exited");
}


void VerletParticleArea::_on_Area_body_shape_entered(int _body_id, Variant body, int body_shape, int _local_shape) {
	auto body_as_co = (CollisionObject2D*)(body);
	if (!body_as_co)
		return;
	const auto shape_owner = body_as_co->shape_find_owner(body_shape);
	const auto transform = body_as_co->get_global_transform() * body_as_co->shape_owner_get_transform(shape_owner);
	const auto shape = body_as_co->shape_owner_get_shape(shape_owner, body_shape);
	bodies.append(body);
	bodies_rid.append(body_as_co->get_rid().get_id());
	shape_transforms.append(transform);
	shape_owners.append(shape_owner);
	shapes.append(shape);

	auto kinematic = Object::cast_to<KinematicRopeCollider>(body);
	if (kinematic) {
		kinematic->increment_particles_count();
	}
}


int find_in_int_array(int to_find, PoolIntArray in, int start_at) {
	auto size = in.size();
	start_at = start_at < 0 ? 0 : start_at;
	for (int i = start_at; i < size; i++) {
		if (in[i] == to_find) {
			return i;
		}
	}
	return -1;
}


void VerletParticleArea::_on_Area_body_shape_exited(int _body_id, Variant body, int body_shape, int _local_shape) {
	int ind = -1;
	auto body_as_co = (CollisionObject2D*)(body);
	if (!body_as_co)
		return;
	auto rid = body_as_co->get_rid().get_id();
	while ((ind = find_in_int_array(rid, bodies_rid, ind-1)) >= 0) {
		remove_from_arrays(ind);
	}

	auto kinematic = Object::cast_to<KinematicRopeCollider>(body);
	if (kinematic) {
		kinematic->decrement_particles_count();
	}
}


void VerletParticleArea::remove_from_arrays(int ind) {
	bodies_rid.remove(ind);
	bodies.remove(ind);
	shape_transforms.remove(ind);
	shape_owners.remove(ind);
	shapes.remove(ind);
}


void VerletParticleArea::update_transforms() {
	for (int i = 0; i < bodies.size(); i++) {
		const auto body = (CollisionObject2D*)(bodies[i]);
		const auto shape_owner = shape_owners[i];
		const auto transform = body->get_global_transform() * body->shape_owner_get_transform(shape_owner);
		shape_transforms[i] = transform;
	}
}


template <typename T> int sign(T val) {
    return (T(0) < val) - (val < T(0));
}


bool apply_circle_constraints(const Transform2D& shape_transform, float shape_radius, const Vector2& position, Vector2& displacement) {
	auto center = shape_transform.get_origin();

	const auto scales = shape_transform.get_scale();
	const auto max_scale = scales.x > scales.y ? scales.x : scales.y;
	const auto radius = shape_radius * max_scale;
	auto direction = position - center;
	auto distance = direction.length();
	if (distance > radius) {
		return false;
	}

	if (distance != 0) {
		direction /= distance;
	}
	auto new_position = center + direction * radius;
	displacement = new_position - position;

	return true;
}


bool apply_box_constraints(const Transform2D& shape_transform, Vector2 extents, const Vector2& position, Vector2& displacement) {
	auto local_position = shape_transform.xform_inv(position);
	const auto diff = local_position.abs() - extents;
	if (diff.x > 0 || diff.y > 0) {
		return false;
	}

	auto center = Vector2(shape_transform.get_origin());
	const auto scales = shape_transform.get_scale();
	const auto max_scale = scales.x > scales.y ? scales.x : scales.y;
	const auto radius = extents.y * max_scale * (1 + sqrt(2)) * 0.5;
	auto direction = position - center;
	const auto distance = direction.length();
	//if (distance > radius) {
	//	return false;
	//}

	if (diff.x < diff.y) {
		local_position.y = extents.y * sign(local_position.y);
	}
	else {
		local_position.x = extents.x * sign(local_position.x);
	}
	auto new_position = shape_transform.xform(local_position);
	displacement = new_position - position;
	return true;
}


CollisionObject2D* VerletParticleArea::apply_constraints_dispatch_with_index(Vector2& position, Vector2& next_position, int i, Vector2& displacement,\
																	bool collide_with_player, CollisionObject2D* player_hurtbox, CollisionObject2D* last_particle) {
	const auto shape_transform = Transform2D(shape_transforms[i]);
	auto body = (CollisionObject2D*)(bodies[i]);
	const auto shape = (Shape2D *)(shapes[i]);

	return apply_constraints_dispatch(position, next_position, shape_transform, body, shape, displacement, collide_with_player, player_hurtbox, last_particle);
}


CollisionObject2D* VerletParticleArea::apply_constraints_dispatch(Vector2& position, Vector2& next_position, \
		const Transform2D& shape_transform, CollisionObject2D* body, const Shape2D* shape, \
		Vector2& displacement, bool collide_with_player, CollisionObject2D* player_hurtbox, CollisionObject2D* last_particle) {

	auto is_collision = false;

	// collision with player is only for lasso
	if (body == player_hurtbox && !collide_with_player) {
		return nullptr;
	}

	if (body == last_particle) {
		return nullptr;
	}

	auto geometry = Geometry::get_singleton();
	const auto closest_point = geometry->get_closest_point_to_segment_2d(shape_transform.get_origin(), position, next_position);
	const auto c_shape = Object::cast_to<CircleShape2D>(shape);
	if (c_shape) {
		is_collision = apply_circle_constraints(shape_transform, c_shape->get_radius(), closest_point, displacement);
	}
	else {
		const auto b_shape = Object::cast_to<RectangleShape2D>(shape);
		if (b_shape) {
			is_collision = apply_box_constraints(shape_transform, b_shape->get_extents(), closest_point, displacement);
		}
	}

	if (is_collision) {
		position += displacement;
		next_position += displacement;
		return body;
	}

	return nullptr;
}


bool VerletParticleArea::is_colliding_with_body(const Vector2& position, const Vector2& next_position, CollisionObject2D* body) {
	for (int i = 0; i < bodies.size(); i++) {
		auto body_in_memory = (CollisionObject2D*)(bodies[i]);
		if (body == body_in_memory) {
			const auto shape_transform = Transform2D(shape_transforms[i]);
			const auto shape = (Shape2D*)(shapes[i]);

			auto position_local = position;
			auto next_position_local = next_position;
			auto displacement = Vector2::ZERO;
			auto collide_with_player = false;
			CollisionObject2D* player_hurtbox = nullptr;

			if (apply_constraints_dispatch(position_local, next_position_local, shape_transform, body, shape, displacement, collide_with_player, player_hurtbox, nullptr)) {
				return true;
			}
		}
	}
	return false;
}


bool VerletParticleArea::apply_constraints(Vector2& position, Vector2& next_position, bool apply_impulse, float impulse_factor,\
											bool collide_with_player, CollisionObject2D* player_hurtbox, CollisionObject2D* last_particle) {
	auto displacement = Vector2::ZERO;

	for (int i = 0; i < bodies.size(); i++) {
		auto body_collided = apply_constraints_dispatch_with_index(position, next_position, i, displacement, collide_with_player, player_hurtbox, last_particle);

		if (body_collided) {
			auto kinematic = Object::cast_to<KinematicRopeCollider>(body_collided);
			if (apply_impulse && kinematic) {
				kinematic->add_accumulate(-displacement * impulse_factor);
			}
			return true;
		}
	}
	return false;
}


bool VerletParticleArea::apply_constraints_with_report_kinematic(Vector2& position, Vector2& next_position, bool apply_impulse, float impulse_factor,\
			bool collide_with_player, CollisionObject2D* player_hurtbox,\
			float clockwise, const Vector2& tangent, CollisionObject2D *& obj, CollisionObject2D* last_particle) {
	auto displacement = Vector2::ZERO;
	CollisionObject2D* ret = nullptr;

	for (int i = 0; i < bodies.size(); i++) {
		auto body_collided = apply_constraints_dispatch_with_index(position, next_position, i, displacement, collide_with_player, player_hurtbox, last_particle);

		if (body_collided) {
			if (tangent.cross(displacement) * clockwise < 0) {
				obj = body_collided;
			}

			auto kinematic = Object::cast_to<KinematicRopeCollider>(body_collided);
			if (apply_impulse && kinematic) {
				kinematic->add_accumulate(-displacement * impulse_factor);
			}
			return true;
		}
	}
	return false;
}


bool VerletParticleArea::check_lasso(int index,  PoolVector2Array pos_curr, int last_collision_index, Vector2 last_particle_position, int nb_particles_sharing_area, CollisionObject2D* last_particle) {
	for (int i = 0; i < bodies.size(); i++) {

		auto body_in_memory = (CollisionObject2D*)(bodies[i]);
		if (body_in_memory == last_particle) {
			auto rope_segment_b_index = index - 1;
			rope_segment_b_index = rope_segment_b_index < 0 ? 1 : rope_segment_b_index;
			auto rope_segment_a = pos_curr[index];
			auto rope_segment_b = pos_curr[rope_segment_b_index];
			auto last_segment_b = last_particle_position;
			auto last_collision_point = pos_curr[last_collision_index];

			auto geometry = Geometry::get_singleton();
			if (geometry->segment_intersects_segment_2d(rope_segment_a, rope_segment_b, last_collision_point, last_segment_b)) {
				return true;
			}
		}
	}
	return false;
}


bool VerletParticleArea::check_lasso_with_collision(int index, PoolVector2Array pos_curr, CollisionObject2D* colliding_with, Vector2 collision_position) {
	for (int i = 0; i < bodies.size(); i++) {

		auto body_in_memory = (CollisionObject2D*)(bodies[i]);
		if (body_in_memory == colliding_with) {
			auto rope_segment_b_index = index - 1;
			rope_segment_b_index = rope_segment_b_index < 0 ? 1 : rope_segment_b_index;
			auto rope_segment_a = pos_curr[index];
			auto rope_segment_b = pos_curr[rope_segment_b_index];
			const auto shape_transform = Transform2D(shape_transforms[i]);
			auto last_segment_b = shape_transform.get_origin();
			auto last_collision_point = collision_position;

			auto geometry = Geometry::get_singleton();
			if (geometry->segment_intersects_segment_2d(rope_segment_a, rope_segment_b, last_collision_point, last_segment_b)) {
				return true;
			}
		}
	}
	return false;
}