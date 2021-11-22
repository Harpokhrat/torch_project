#ifndef VERLETPOSCONSTRAINTS_H
#define VERLETPOSCONSTRAINTS_H

#include <Godot.hpp>
#include <Array.hpp>
#include <PoolArrays.hpp>
#include <Vector2.hpp>
#include <Reference.hpp>
#include <KinematicCollision2D.hpp>

#include "verlet_particle_area_2D.h"

namespace godot {

class VerletPosConstraints : public Reference {
    GODOT_CLASS(VerletPosConstraints, Reference)

	enum State { LOOSE, TIGHT, LASSO, CHECK_LONE_KINEMATIC, LONE_KINEMATIC, LAST_FIXED };

private:
	PoolVector2Array pos_curr_container;
	PoolVector2Array pos_prev_container;
	Vector2 last_collision_point;
	float start_at_particle = 0;
	int last_collision_index;
	int first_collision_index;
	int iterations = 10;
	int simulation_particles = 10;
	int nb_particles_sharing_area = 10;
	float segment_length = 1;
	float stiffness = 1;
	float impulse_factor = 1;
	float impulse_speed = 1;
	float spin_speed = 1;
	float clockwise = 1;
	float goal_radius = 10;
	bool apply_impulse = false;
	KinematicRopeCollider* lone_kinematic = nullptr;
	CollisionObject2D* player_body = nullptr;
	CollisionObject2D* last_particle = nullptr;
	int lasso_index = -1;
	Array areas;
	State state;
	
	float max_length = 1000;
	float orbit_angle = 0;
	float orbit_radius = 0;
	Vector2 orbit_center = Vector2::ZERO;
	bool orbit_center_is_player = true;
	float total_length = 0;

	void begin_simulation(Vector2 direction, float clockwise_param, float spin_speed_param, float impulse_speed_param);
	void update_bodies_transforms();
	template <bool apply_lasso_constraint>
	void verlet_update(PoolVector2Array::Write& pos_curr, int i);
	void apply_lasso_constraint(PoolVector2Array::Write& pos_curr, Vector2 update, int i);
	float compute_total_length();
	void update_areas_transform();

	Vector2 get_orbit_position();
	void compute_orbit_position(float delta);
	void change_orbit(Vector2 new_orbit_center);
	void change_orbit_with_position(Vector2 new_orbit_center, Vector2 original_position);
	void dispatch_apply_constraints();
	void compute_start_at_particle(float length, float step);
	void set_state(State new_state);

public:
    static void _register_methods();

    VerletPosConstraints();
    ~VerletPosConstraints();

    void _init(); // our initializer called by Godot

	bool is_limiting_rope_length();
	Vector2 get_limit_rope_length_center();
	float get_limit_rope_length_size();
	void set_last_particle_pointer(CollisionObject2D* last_particle_pointer);
	Vector2 get_pull_rope_direction();
	bool is_able_to_hit();
	void set_player_body(Variant v);
	const PoolVector2Array get_pos_curr();
	void set_arrays(PoolVector2Array pos_curr_, PoolVector2Array pos_prev_);
	void set_initial_positions(Vector2 position);
	void set_first_particle_position(Vector2 position);
	Vector2 get_last_particle_position();
	void offset_particle_position_after_lasso(float angle_offset);
	void try_apply_impulse();
	bool is_impulse_applied();
	void fix_last_area(Vector2 at_position);
	void try_lasso_from_hitting_player();
	Vector2 get_first_collision_to_body(CollisionObject2D* body);
	void check_lasso();
	void check_lasso_with_collision(CollisionObject2D* body, Vector2 collision_position);
	
	void verlet_process(float delta);
	template<State state_const>
	void apply_constraints();

	void lasso_momentum();
	void simulate(Vector2 first_particle_position, Vector2 last_particle_position, float delta);
};

}

#endif