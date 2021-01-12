# sample LAMMPS input script for thermal conductivity of Pb
# Muller-Plathe method via fix thermal_conductivity 


# setup problem
variable    t equal 300
variable    dt equal 0.001

units		metal
boundary    p p p
atom_style	atomic

read_data   Plumbene_new.lmpdat
replicate       5 8 1
mass		1 207.20000  ##Lead

pair_style      eam/alloy
pair_coeff      * * Pb.eam.alloy Pb

neighbor	2.0 bin
neigh_modify	 delay 0 every 1 check yes
timestep     ${dt}

# 1st equilibration run
velocity	all create $t 345352 mom yes rot yes dist gaussian

fix		1 all nvt temp $t $t 10 drag 0.2
thermo	 1000
run		400000

velocity	all scale $t

unfix		1

# 2nd equilibration run

compute		ke all ke/atom
variable	temp atom c_ke/(1.5*8.617e-5)

fix		1 all nve

compute   layers all chunk/atom bin/1d x lower 0.05 units reduced
fix		2 all ave/chunk 10 100 1000 layers v_temp file profile1.mp

fix		3 all thermal/conductivity 100 x 30

variable        tdiff equal f_2[11][3]-f_2[1][3]
thermo_style	custom step temp epair etotal lx ly lz f_3 v_tdiff

thermo		1000
run		800000

# thermal conductivity calculation
# reset fix thermal/conductivity to zero energy accumulation

fix		3 all thermal/conductivity 100 x 20

fix             ave all ave/time 1 1 1000 v_tdiff ave running
thermo_style	custom step temp epair etotal f_3 v_tdiff f_ave

run		800000
