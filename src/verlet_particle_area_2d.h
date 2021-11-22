#ifndef VERLETPARTICLEAREA_H
#define VERLETPARTICLEAREA_H

#include <Godot.hpp>
#include <Array.hpp>
#include <Area2D.hpp>
#include <Shape2D.hpp>
#include <CollisionObject2D.hpp>
#include <CapsuleShape2D.hpp>
#include <RectangleShape2D.hpp>
#include <CircleShape2D.hpp>
#include <Geometry.hpp>
#include "kinematic_rope_collider.h"

namespace godot {

class VerletParticleArea : public Area2D {
    GODOT_CLASS(VerletParticleArea, Area2D)

protected:
	Array shapes;
	Array bodies = Array();
	PoolIntArray bodies_rid = PoolIntArray();
	PoolIntArray shape_owners;
	Array shape_transforms;

	void remove_from_arrays(int ind);

public:
    static void _register_methods();

    VerletParticleArea();
    ~VerletParticleArea();

    void _init(); // our initializer called by Godot
	
	bool check_lasso(int index, PoolVector2Array pos_curr, int last_collision_index, Vector2 last_particle_position, int nb_particles_sharing_area, CollisionObject2D* last_particle);
	bool check_lasso_with_collision(int index, PoolVector2Array pos_curr, CollisionObject2D* colliding_with, Vector2 collision_position);
	void _on_Area_body_shape_entered(int _body_id, Variant body, int body_shape, int _local_shape);
	void _on_Area_body_shape_exited(int _body_id, Variant body, int body_shape, int _local_shape);
	void update_transforms();
	CollisionObject2D* apply_constraints_dispatch_with_index(Vector2& position, Vector2& next_position, int i, Vector2& displacement, \
		bool collide_with_player, CollisionObject2D* player_hurtbox, CollisionObject2D* last_particle);
	CollisionObject2D* apply_constraints_dispatch(Vector2& position, Vector2& next_position, \
		const Transform2D& shape_transform, CollisionObject2D* body, const Shape2D* shape, \
		Vector2& displacement, bool collide_with_player, CollisionObject2D* player_hurtbox, CollisionObject2D* last_particle);
	bool apply_constraints(Vector2& position, Vector2& next_position, bool apply_impulse, float impulse_factor, \
		bool collide_with_player, CollisionObject2D* player_hurtbox, CollisionObject2D* last_particle);
	bool apply_constraints_with_report_kinematic(Vector2& position, Vector2& next_position, bool apply_impulse, float impulse_factor, \
		bool collide_with_player, CollisionObject2D* player_hurtbox, \
		float clockwise, const Vector2& tangent, CollisionObject2D*& obj, CollisionObject2D* last_particle);
	bool is_colliding_with_body(const Vector2& position, const Vector2& next_position, CollisionObject2D* body);
};

}

#endif