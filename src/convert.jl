# Convert things
#
# conv_bv2tal
# conv_spm_mni2tal
#



function conv_spm_mni2tal(elec::Electrodes; verbose::Bool=false)

    elecNew = elec

    elecNew.xloc, elecNew.yloc, elecNew.zloc = conv_spm_mni2tal(elec.xloc, elec.yloc, elec.zloc, verbose=verbose)

    elecNew.coord_system = "Talairach"

    return elecNew
end


