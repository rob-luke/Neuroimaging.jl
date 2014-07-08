using EEG
using Base.Test

# #####
#
# MNI 2 Tal
# Values from table IV in Lancaster et al 2007
#
# #####

# TODO: Find better points to translate

mni = [73.7, -26.0, 7.0]
tal_true = [68.3, -26.9, 8.3]
tal_x, tal_y, tal_z = conv_spm_mni2tal(mni[1], mni[2], mni[3])

@test_approx_eq_eps tal_true[1] tal_x 1.5
@test_approx_eq_eps tal_true[2] tal_y 1.5
@test_approx_eq_eps tal_true[3] tal_z 1.5


mni = [6.3, 75.1, 5.9]
tal_true = [5.7, 67.5, 17.1]
tal_x, tal_y, tal_z = conv_spm_mni2tal(mni[1], mni[2], mni[3])

@test_approx_eq_eps tal_true[1] tal_x 1.5
@test_approx_eq_eps tal_true[2] tal_y 1.5
@test_approx_eq_eps tal_true[3] tal_z 1.5
