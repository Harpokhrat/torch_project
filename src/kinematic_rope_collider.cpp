#include "kinematic_rope_collider.h"

using namespace godot;

void KinematicRopeCollider::_register_methods() {
	register_property<KinematicRopeCollider, bool>("is_moved", &KinematicRopeCollider::is_moved, false);
	register_property<KinematicRopeCollider, Vector2>("accumulate", &KinematicRopeCollider::accumulate, Vector2::ZERO);
	register_property<KinematicRopeCollider, Vector2>("move_to_target", &KinematicRopeCollider::move_to_target, Vector2::ZERO);
	register_property<KinematicRopeCollider, Variant>("rope", &KinematicRopeCollider::rope, Variant());
	register_property<KinematicRopeCollider, Vector2>("orbit_center", &KinematicRopeCollider::orbit_center, Vector2::ZERO);

	register_method("add_accumulate", &KinematicRopeCollider::add_accumulate);

	register_signal<KinematicRopeCollider>((char*)"rope_interaction_started", Dictionary::make());
	register_signal<KinematicRopeCollider>((char*)"rope_interaction_ended", Dictionary::make());
	register_signal<KinematicRopeCollider>((char*)"move_asked", Dictionary::make());
}

KinematicRopeCollider::KinematicRopeCollider() {
}

KinematicRopeCollider::~KinematicRopeCollider() {
}

void KinematicRopeCollider::_init() {
}

void KinematicRopeCollider::add_accumulate(Vector2 velocity) {
	//start_rope_interaction();

	is_moved = true;
	accumulate += velocity;
}

void KinematicRopeCollider::start_rope_interaction() {
	if (!is_interacting_with_rope) {
		is_interacting_with_rope = true;
		emit_signal("rope_interaction_started");
	}
}


void KinematicRopeCollider::move_to(Vector2 target, Variant v, Vector2 orbit_center_) {
	move_to_target = target;
	rope = v;
	orbit_center = orbit_center_;
	emit_signal("move_asked");
}


void KinematicRopeCollider::decrement_particles_count() {
	interacting_particles_count--;
	if (interacting_particles_count == 0) {
		if (is_interacting_with_rope) {
			emit_signal("rope_interaction_ended");
			is_interacting_with_rope = false;
		}
	}
}


void KinematicRopeCollider::increment_particles_count() {
	interacting_particles_count++;
}