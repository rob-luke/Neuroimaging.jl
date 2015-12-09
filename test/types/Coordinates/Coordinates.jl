# #####
#
# MNI 2 Tal
# Values from table IV in Lancaster et al 2007
#
# #####

# TODO Find better points to translate


mni = SPM(73.7, -26.0, 7.0)
tal = convert(Talairach, mni)

tal_true = [68.3, -26.9, 8.3]

@test_approx_eq_eps tal_true[1] tal.x 1.5
@test_approx_eq_eps tal_true[2] tal.y 1.5
@test_approx_eq_eps tal_true[3] tal.z 1.5

# Test as an electrode
e = Electrodes("SPM", "EEG", ["test"], [73.7], [-26.0], [7.0])
e = conv_spm_mni2tal(e)

@test_approx_eq_eps tal_true[1] e.x 1.5
@test_approx_eq_eps tal_true[2] e.y 1.5
@test_approx_eq_eps tal_true[3] e.z 1.5
@test e.coord_system == "Talairach"


mni = SPM(6.3, 75.1, 5.9)
tal = convert(Talairach, mni)

tal_true = [5.7, 67.5, 17.1]

@test_approx_eq_eps tal_true[1] tal.x 1.5
@test_approx_eq_eps tal_true[2] tal.y 1.5
@test_approx_eq_eps tal_true[3] tal.z 1.5


# #####
#
# BrainVision to Talairach
# TODO this just tests it runs, need to check values
#
# #####

bv = BrainVision(0, 0, 0)
tal = convert(Talairach, bv)


@test tal.x == 128
@test tal.y == 128
@test tal.z == 128


