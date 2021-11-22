#ifndef KINEMATIC_ROPE_COLLIDER_H
#define KINEMATIC_ROPE_COLLIDER_H

#include <Godot.hpp>
#include <Area2D.hpp>
#include <KinematicBody2D.hpp>
#include <KinematicCollision2D.hpp>

namespace godot {

class KinematicRopeCollider : public Area2D {
    GODOT_CLASS(KinematicRopeCollider, Area2D)

protected:
	bool is_interacting_with_rope = false;
	int interacting_particles_count = 0;

public:
	Vector2 accumulate = Vector2::ZERO;
	Vector2 move_to_target = Vector2::ZERO;
	Variant rope;
	bool is_moved = false;
	Vector2 orbit_center = Vector2::ZERO;

    static void _register_methods();

	KinematicRopeCollider();
    ~KinematicRopeCollider();

    void _init(); // our initializer called by Godot

	void start_rope_interaction();
	void add_accumulate(Vector2 velocity);

	void increment_particles_count();
	void decrement_particles_count();

	void move_to(Vector2 target, Variant v, Vector2 orbit_center_);
};


}

#endif