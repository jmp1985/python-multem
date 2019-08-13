/*
 *  multem_ext.cu
 *
 *  Copyright (C) 2019 Diamond Light Source
 *
 *  Author: James Parkhurst
 *
 *  This code is distributed under the GPLv3 license, a copy of 
 *  which is included in the root directory of this package.
 */

#include <sstream>
#include <iostream>
#include <stdexcept>
#include <cuda_runtime.h>
#include <multem/multem_ext.h>
#include <types.cuh>
#include <input_multislice.cuh>
#include <device_functions.cuh>
#include <multem.cu>

namespace multem {

  namespace detail {

    mt::eDevice string_to_device_enum(const std::string &device) {
      if (device == "host") {
        return mt::e_host;
      } else if (device == "device") {
        return mt::e_device;
      } else if (device == "host_device") {
        return mt::e_host_device;
      }
      throw std::runtime_error("Unknown device");
    }

    mt::ePrecision string_to_precision_enum(const std::string &precision) {
      if (precision == "float") {
        return mt::eP_float;
      } else if (precision == "double") {
        return mt::eP_double;
      }
      throw std::runtime_error("Unknown precision");
    }

    mt::eElec_Spec_Int_Model string_to_interaction_model_enum(const std::string &interaction_model) {
      if (interaction_model == "Multislice") {
        return mt::eESIM_Multislice;
      } else if (interaction_model == "Phase_Object") {
        return mt::eESIM_Phase_Object;
      } else if (interaction_model == "Weak_Phase_Object") {
        return mt::eESIM_Weak_Phase_Object;
      }
      throw std::runtime_error("Invalid interaction model");
    }

    mt::ePotential_Type string_to_potential_type_enum(const std::string &potential_type) {
      if (potential_type == "Doyle_0_4") {
        return mt::ePT_Doyle_0_4;
      } else if (potential_type == "Peng_0_4") {
        return mt::ePT_Peng_0_4;
      } else if (potential_type == "Peng_0_12") {
        return mt::ePT_Peng_0_12;
      } else if (potential_type == "Kirkland_0_12") {
        return mt::ePT_Kirkland_0_12;
      } else if (potential_type == "Weickenmeier_0_12") {
        return mt::ePT_Weickenmeier_0_12;
      } else if (potential_type == "Lobato_0_12") {
        return mt::ePT_Lobato_0_12;
      } else if (potential_type == "none") {
        return mt::ePT_none;
      }
      throw std::runtime_error("Invalid potential type");
    }

    mt::ePhonon_Model string_to_phonon_model_enum(const std::string &pn_model) {
      if (pn_model == "Still_Atom") {
        return mt::ePM_Still_Atom;
      } else if (pn_model == "Absorptive_Model") {
        return mt::ePM_Absorptive_Model;
      } else if (pn_model == "Frozen_Phonon") {
        return mt::ePM_Frozen_Phonon;
      }
      throw std::runtime_error("Invalid phonon model");
    }

    mt::eRot_Point_Type string_to_rot_point_type_enum(const std::string &spec_rot_center_type) {
      if (spec_rot_center_type == "geometric_center") {
        return mt::eRPT_geometric_center;
      } else if (spec_rot_center_type == "User_Define") {
        return mt::eRPT_User_Define;
      }
      throw std::runtime_error("Invalid spec rot center type");
    }

    mt::eThick_Type string_to_thick_type_enum(const std::string &thick_type) {
      if (thick_type == "Whole_Spec") {
        return mt::eTT_Whole_Spec;
      } else if (thick_type == "Through_Thick") {
        return mt::eTT_Through_Thick;
      } else if (thick_type == "Through_Slices") {
        return mt::eTT_Through_Slices;
      }
      throw std::runtime_error("Invalid thickness type");
    }

    mt::ePotential_Slicing string_to_potential_slicing_enum(const std::string &potential_slicing) {
      if (potential_slicing == "Planes") {
        return mt::ePS_Planes;
      } else if (potential_slicing == "dz_Proj") {
        return mt::ePS_dz_Proj;
      } else if (potential_slicing == "dz_Sub") {
        return mt::ePS_dz_Sub;
      } else if (potential_slicing == "Auto") {
        return mt::ePS_Auto;
      }
      throw std::runtime_error("Invalid potential slicing");
    }

    mt::eTEM_Sim_Type string_to_tem_sim_type_enum(const std::string &simulation_type) {
      if (simulation_type == "STEM") {
        return mt::eTEMST_STEM ;
      } else if (simulation_type == "ISTEM") {
        return mt::eTEMST_ISTEM ;
      } else if (simulation_type == "CBED") {
        return mt::eTEMST_CBED ;
      } else if (simulation_type == "CBEI") {
        return mt::eTEMST_CBEI ;
      } else if (simulation_type == "ED") {
        return mt::eTEMST_ED ;
      } else if (simulation_type == "HRTEM") {
        return mt::eTEMST_HRTEM ;
      } else if (simulation_type == "PED") {
        return mt::eTEMST_PED ;
      } else if (simulation_type == "HCTEM") {
        return mt::eTEMST_HCTEM ;
      } else if (simulation_type == "EWFS") {
        return mt::eTEMST_EWFS ;
      } else if (simulation_type == "EWRS") {
        return mt::eTEMST_EWRS ;
      } else if (simulation_type == "EELS") {
        return mt::eTEMST_EELS ;
      } else if (simulation_type == "EFTEM") {
        return mt::eTEMST_EFTEM ;
      } else if (simulation_type == "IWFS") {
        return mt::eTEMST_IWFS ;
      } else if (simulation_type == "IWRS") {
        return mt::eTEMST_IWRS ;
      } else if (simulation_type == "PPFS") {
        return mt::eTEMST_PPFS ;
      } else if (simulation_type == "PPRS") {
        return mt::eTEMST_PPRS ;
      } else if (simulation_type == "TFFS") {
        return mt::eTEMST_TFFS ;
      } else if (simulation_type == "TFRS") {
        return mt::eTEMST_TFRS ;
      } else if (simulation_type == "PropFS") {
        return mt::eTEMST_PropFS ;
      } else if (simulation_type == "PropRS") {
        return mt::eTEMST_PropRS ;
      }
      throw std::runtime_error("Invalid simulation type");
    }

    mt::eIncident_Wave_Type string_to_incident_wave_type_enum(const std::string &iw_type) {
      if (iw_type == "Plane_Wave") {
        return mt::eIWT_Plane_Wave;
      } else if (iw_type == "Convergent_Wave") { 
        return mt::eIWT_Convergent_Wave;
      } else if (iw_type == "User_Define_Wave") { 
        return mt::eIWT_User_Define_Wave;
      } else if (iw_type == "Auto") { 
        return mt::eIWT_Auto;
      }
      throw std::runtime_error("Invalid iw type");
    }

    mt::eIllumination_Model string_to_illumination_model_enum(const std::string &illumination_model) {
      if (illumination_model == "Coherent") {
        return mt::eIM_Coherent;
      } else if (illumination_model == "Partial_Coherent") {
        return mt::eIM_Partial_Coherent;
      } else if (illumination_model == "Trans_Cross_Coef") {
        return mt::eIM_Trans_Cross_Coef;
      } else if (illumination_model == "Full_Integration") {
        return mt::eIM_Full_Integration;
      } else if (illumination_model == "none") {
        return mt::eIM_none;
      }
      throw std::runtime_error("Invalid illumination model");
    }
      
    mt::eOperation_Mode string_to_operation_mode_enum(const std::string &operation_mode) {
      if (operation_mode == "Normal") {
        return mt::eOM_Normal;
      } else if (operation_mode == "Advanced") {
        return mt::eOM_Advanced;
      }
      throw std::runtime_error("Invalid operation mode");
    }

    mt::eLens_Var_Type string_to_lens_var_type_enum(const std::string &cdl_var_type) {
      if (cdl_var_type == "off") {
        return mt::eLVT_off;
      } else if (cdl_var_type == "m") {
        return mt::eLVT_m;
      } else if (cdl_var_type == "f") {
        return mt::eLVT_f;
      } else if (cdl_var_type == "Cs3") {
        return mt::eLVT_Cs3;
      } else if (cdl_var_type == "Cs5") {
        return mt::eLVT_Cs5;
      } else if (cdl_var_type == "mfa2") {
        return mt::eLVT_mfa2;
      } else if (cdl_var_type == "afa2") {
        return mt::eLVT_afa2;
      } else if (cdl_var_type == "mfa3") {
        return mt::eLVT_mfa3;
      } else if (cdl_var_type == "afa3") {
        return mt::eLVT_afa3;
      } else if (cdl_var_type == "inner_aper_ang") {
        return mt::eLVT_inner_aper_ang;
      } else if (cdl_var_type == "outer_aper_ang") {
        return mt::eLVT_outer_aper_ang;
      }
      throw std::runtime_error("Invalid cdl_var_type");
    }

    mt::eTemporal_Spatial_Incoh string_to_temporal_spatial_incoh_enum(const
        std::string &temporal_spatial_incoh) {
      if (temporal_spatial_incoh == "Temporal_Spatial") {
        return mt::eTSI_Temporal_Spatial;
      } else if (temporal_spatial_incoh == "Temporal") {
        return mt::eTSI_Temporal;
      } else if (temporal_spatial_incoh == "Spatial") {
        return mt::eTSI_Spatial;
      } else if (temporal_spatial_incoh == "none") {
        return mt::eTSI_none;
      }
      throw std::runtime_error("Invalid temporal spatial incohenence");
    }

    mt::eZero_Defocus_Type string_to_defocus_type_enum(
        const std::string &defocus_type) {
      if (defocus_type == "First") {
        return mt::eZDT_First;
      } else if (defocus_type == "Middle") {
        return mt::eZDT_Middle;
      } else if (defocus_type == "Last") {
        return mt::eZDT_Last;
      } else if (defocus_type == "User_Define") {
        return mt::eZDT_User_Define;
      }
      throw std::runtime_error("Invalid defocus type");
    }

    mt::eScanning_Type string_to_scanning_type_enum(const std::string &scanning_type) {
      if (scanning_type == "Line") {
        return mt::eST_Line;
      } else if (scanning_type == "Area") {
        return mt::eST_Area;
      }
      throw std::runtime_error("Invalid scanning type");
    }

    mt::eDetector_Type string_to_detector_type_enum(const std::string &detector_type) {
      if (detector_type == "Circular") {
        return mt::eDT_Circular;
      } else if (detector_type == "Radial") {
        return mt::eDT_Radial;
      } else if (detector_type == "Matrix") {
        return mt::eDT_Matrix;
      }
      throw std::runtime_error("Invalid detector type");
    }

    mt::eChannelling_Type string_to_channelling_type_enum(const std::string
        &channelling_type) {
      if (channelling_type == "Single_Channelling") {
        return mt::eCT_Single_Channelling;
      } else if (channelling_type == "Mixed_Channelling") {
        return mt::eCT_Mixed_Channelling;
      } else if (channelling_type == "Double_Channelling") {
        return mt::eCT_Double_Channelling;
      }
      throw std::runtime_error("Invalid channelling type");
    }

    template <typename FloatType, mt::eDevice DeviceType>
    void run_multislice_internal(
      const mt::System_Configuration &system_conf,
      mt::Input_Multislice<FloatType> &input_multislice,
      mt::Output_Multislice<FloatType> &output_multislice) {
  
      // Set the system configration    
      input_multislice.system_conf = system_conf;

      // Open a stream
      mt::Stream<DeviceType> stream(system_conf.nstream);

      // Create the FFT object
      mt::FFT<FloatType, DeviceType> fft_2d;
      fft_2d.create_plan_2d(
        input_multislice.grid_2d.ny, 
        input_multislice.grid_2d.nx, 
        system_conf.nstream);

      // Setup the multislice simulation 
      mt::Multislice<FloatType, DeviceType> multislice;
      multislice.set_input_data(&input_multislice, &stream, &fft_2d);

      // Set the input data
      output_multislice.set_input_data(&input_multislice);

      // Perform the multislice simulation
      multislice(output_multislice);
      stream.synchronize();

      // Get the results
      output_multislice.gather();
      output_multislice.clean_temporal();
      fft_2d.cleanup();

      // If there was an error then throw and exception
      auto err = cudaGetLastError();
      if (err != cudaSuccess) {
        std::stringstream message;
        message << "CUDA error: " << cudaGetErrorString(err) << "\n";
        throw std::runtime_error(message.str());
      }
    }
 
    mt::System_Configuration read_system_configuration(const SystemConfiguration &config) {
      mt::System_Configuration system_conf;
      system_conf.device = detail::string_to_device_enum(config.device);
      system_conf.precision = detail::string_to_precision_enum(config.precision);
      system_conf.cpu_ncores = config.cpu_ncores;
      system_conf.cpu_nthread = config.cpu_nthread;
      system_conf.gpu_device = config.gpu_device;
      system_conf.gpu_nstream = config.gpu_nstream;
      system_conf.active = true;
      system_conf.validate_parameters();
      system_conf.set_device();
      return system_conf;
    } 
    
    template <typename FloatType>
    mt::Input_Multislice<FloatType> read_input_multislice(
        const Input &input,
        bool full = true) {
      mt::Input_Multislice<FloatType> input_multislice;

      // Simulation type
      input_multislice.simulation_type = string_to_tem_sim_type_enum(input.simulation_type);
      input_multislice.interaction_model = string_to_interaction_model_enum(input.interaction_model);
      input_multislice.potential_type = string_to_potential_type_enum(input.potential_type);
      input_multislice.operation_mode = string_to_operation_mode_enum(input.operation_mode);
      input_multislice.reverse_multislice = input.reverse_multislice;

      // Electron-Phonon interaction model
      input_multislice.pn_model = string_to_phonon_model_enum(input.pn_model);
      input_multislice.pn_coh_contrib = input.pn_coh_contrib;
      input_multislice.pn_single_conf = input.pn_single_conf;
      input_multislice.pn_nconf = input.pn_nconf;
      input_multislice.pn_dim.set(input.pn_dim);
      input_multislice.pn_seed = input.pn_seed;

      // Specimen
      bool pbc_xy = true;

      // Set the specimen
      if (input_multislice.is_specimen_required())
      {
        // Set the amorphous layer information
        mt::Vector<mt::Amorp_Lay_Info<FloatType>, mt::e_host> amorp_lay_info;
        for (auto item : input.spec_amorp) {
          mt::Amorp_Lay_Info<FloatType> value;
          value.z_0 = item.z_0;
          value.z_e = item.z_e;
          value.dz = item.dz;
          amorp_lay_info.push_back(value);
        }

        if (full) {
          input_multislice.atoms.set_crystal_parameters(
              input.spec_cryst_na, 
              input.spec_cryst_nb, 
              input.spec_cryst_nc, 
              input.spec_cryst_a, 
              input.spec_cryst_b, 
              input.spec_cryst_c, 
              input.spec_cryst_x0, 
              input.spec_cryst_y0);
          input_multislice.atoms.set_amorphous_parameters(amorp_lay_info);
          input_multislice.atoms.resize(input.spec_atoms.size());
          for(auto i = 0; i < input.spec_atoms.size(); ++i) {
            input_multislice.atoms.Z[i] = input.spec_atoms[i].element;
            input_multislice.atoms.x[i] = input.spec_atoms[i].x;
            input_multislice.atoms.y[i] = input.spec_atoms[i].y;
            input_multislice.atoms.z[i] = input.spec_atoms[i].z;
            input_multislice.atoms.sigma[i] = input.spec_atoms[i].sigma;
            input_multislice.atoms.occ[i] = input.spec_atoms[i].occupancy;
            input_multislice.atoms.region[i] = abs(input.spec_atoms[i].region);
            input_multislice.atoms.charge[i] = input.spec_atoms[i].charge;
          }
          input_multislice.atoms.get_statistic();
        }

        // Specimen rotation
        input_multislice.spec_rot_theta = input.spec_rot_theta*mt::c_deg_2_rad;
        input_multislice.spec_rot_u0 = mt::r3d<FloatType>(
            input.spec_rot_u0[0],
            input.spec_rot_u0[1],
            input.spec_rot_u0[2]);
        input_multislice.spec_rot_u0.normalized();
        input_multislice.spec_rot_center_type = string_to_rot_point_type_enum(input.spec_rot_center_type);
        input_multislice.spec_rot_center_p = mt::r3d<FloatType>(
            input.spec_rot_center_p[0],
            input.spec_rot_center_p[1],
            input.spec_rot_center_p[2]);

        // Specimen thickness
        input_multislice.thick_type = string_to_thick_type_enum(input.thick_type);
        if (!input_multislice.is_whole_spec() && full) {
          input_multislice.thick.assign(input.thick.begin(), input.thick.end());
        }

        // Potential slicing
        input_multislice.potential_slicing = string_to_potential_slicing_enum(input.potential_slicing);
      }

      // XY sampling
      auto nx = input.nx;
      auto ny = input.ny;
      bool bwl = input.bwl;
      input_multislice.grid_2d.set_input_data(
          nx, 
          ny, 
          input.spec_lx, 
          input.spec_ly, 
          input.spec_dz, 
          bwl, 
          pbc_xy);

      // Incident wave
      input_multislice.set_incident_wave_type(string_to_incident_wave_type_enum(input.iw_type));

      if (input_multislice.is_user_define_wave() && full) {
        input_multislice.iw_psi.assign(
            input.iw_psi.begin(),
            input.iw_psi.end());
      }

      // read iw_x and iw_y
      int n_iw_xy = std::min(input.iw_x.size(), input.iw_y.size());
      input_multislice.iw_x.assign(input.iw_x.begin(), input.iw_x.begin() + n_iw_xy);
      input_multislice.iw_y.assign(input.iw_y.begin(), input.iw_y.begin() + n_iw_xy);

      // Microscope parameter
      input_multislice.E_0 = input.E_0;
      input_multislice.theta = input.theta*mt::c_deg_2_rad;
      input_multislice.phi = input.phi*mt::c_deg_2_rad;

      // Illumination model
      input_multislice.illumination_model = string_to_illumination_model_enum(input.illumination_model);
      input_multislice.temporal_spatial_incoh = string_to_temporal_spatial_incoh_enum(input.temporal_spatial_incoh);

      // Condenser lens
      input_multislice.cond_lens.m = input.cond_lens_m;
      input_multislice.cond_lens.c_10 = input.cond_lens_c_10;
      input_multislice.cond_lens.c_12 = input.cond_lens_c_12;
      input_multislice.cond_lens.phi_12 = input.cond_lens_phi_12*mt::c_deg_2_rad;
      input_multislice.cond_lens.c_21 = input.cond_lens_c_21;
      input_multislice.cond_lens.phi_21 = input.cond_lens_phi_21*mt::c_deg_2_rad;
      input_multislice.cond_lens.c_23 = input.cond_lens_c_23;
      input_multislice.cond_lens.phi_23 = input.cond_lens_phi_23*mt::c_deg_2_rad;
      input_multislice.cond_lens.c_30 = input.cond_lens_c_30*mt::c_mm_2_Angs; 
      input_multislice.cond_lens.c_32 = input.cond_lens_c_32; 
      input_multislice.cond_lens.phi_32 = input.cond_lens_phi_32*mt::c_deg_2_rad;
      input_multislice.cond_lens.c_34 = input.cond_lens_c_34;
      input_multislice.cond_lens.phi_34 = input.cond_lens_phi_34*mt::c_deg_2_rad;
      input_multislice.cond_lens.c_41 = input.cond_lens_c_41;
      input_multislice.cond_lens.phi_41 = input.cond_lens_phi_41*mt::c_deg_2_rad;
      input_multislice.cond_lens.c_43 = input.cond_lens_c_43;
      input_multislice.cond_lens.phi_43 = input.cond_lens_phi_43*mt::c_deg_2_rad;
      input_multislice.cond_lens.c_45 = input.cond_lens_c_45;
      input_multislice.cond_lens.phi_45 = input.cond_lens_phi_45*mt::c_deg_2_rad;
      input_multislice.cond_lens.c_50 = input.cond_lens_c_50*mt::c_mm_2_Angs;
      input_multislice.cond_lens.c_52 = input.cond_lens_c_52;
      input_multislice.cond_lens.phi_52 = input.cond_lens_phi_52*mt::c_deg_2_rad;
      input_multislice.cond_lens.c_54 = input.cond_lens_c_54;
      input_multislice.cond_lens.phi_54 = input.cond_lens_phi_54*mt::c_deg_2_rad;
      input_multislice.cond_lens.c_56 = input.cond_lens_c_56;
      input_multislice.cond_lens.phi_56 = input.cond_lens_phi_56*mt::c_deg_2_rad;
      input_multislice.cond_lens.inner_aper_ang = input.cond_lens_inner_aper_ang*mt::c_mrad_2_rad;
      input_multislice.cond_lens.outer_aper_ang = input.cond_lens_outer_aper_ang*mt::c_mrad_2_rad;

      // defocus spread function
      input_multislice.cond_lens.dsf_sigma = input.cond_lens_dsf_sigma;
      input_multislice.cond_lens.dsf_npoints = input.cond_lens_dsf_npoints;

      // source spread function
      input_multislice.cond_lens.ssf_sigma = input.cond_lens_ssf_sigma;
      input_multislice.cond_lens.ssf_npoints = input.cond_lens_ssf_npoints;

      // zero defocus reference
      input_multislice.cond_lens.zero_defocus_type = 
        string_to_defocus_type_enum(input.cond_lens_zero_defocus_type);
      input_multislice.cond_lens.zero_defocus_plane = input.cond_lens_zero_defocus_plane;
      input_multislice.cond_lens.set_input_data(input_multislice.E_0, input_multislice.grid_2d);

      // Objective lens
      input_multislice.obj_lens.m = input.obj_lens_m;
      input_multislice.obj_lens.c_10 = input.obj_lens_c_10;
      input_multislice.obj_lens.c_12 = input.obj_lens_c_12;
      input_multislice.obj_lens.phi_12 = input.obj_lens_phi_12*mt::c_deg_2_rad;
      input_multislice.obj_lens.c_21 = input.obj_lens_c_21;
      input_multislice.obj_lens.phi_21 = input.obj_lens_phi_21*mt::c_deg_2_rad;
      input_multislice.obj_lens.c_23 = input.obj_lens_c_23;
      input_multislice.obj_lens.phi_23 = input.obj_lens_phi_23*mt::c_deg_2_rad;
      input_multislice.obj_lens.c_30 = input.obj_lens_c_30*mt::c_mm_2_Angs;
      input_multislice.obj_lens.c_32 = input.obj_lens_c_32;
      input_multislice.obj_lens.phi_32 = input.obj_lens_phi_32*mt::c_deg_2_rad;
      input_multislice.obj_lens.c_34 = input.obj_lens_c_34;
      input_multislice.obj_lens.phi_34 = input.obj_lens_phi_34*mt::c_deg_2_rad;
      input_multislice.obj_lens.c_41 = input.obj_lens_c_41;
      input_multislice.obj_lens.phi_41 = input.obj_lens_phi_41*mt::c_deg_2_rad;
      input_multislice.obj_lens.c_43 = input.obj_lens_c_43;
      input_multislice.obj_lens.phi_43 = input.obj_lens_phi_43*mt::c_deg_2_rad;
      input_multislice.obj_lens.c_45 = input.obj_lens_c_45;
      input_multislice.obj_lens.phi_45 = input.obj_lens_phi_45*mt::c_deg_2_rad;
      input_multislice.obj_lens.c_50 = input.obj_lens_c_50*mt::c_mm_2_Angs;
      input_multislice.obj_lens.c_52 = input.obj_lens_c_52;
      input_multislice.obj_lens.phi_52 = input.obj_lens_phi_52*mt::c_deg_2_rad;
      input_multislice.obj_lens.c_54 = input.obj_lens_c_54;
      input_multislice.obj_lens.phi_54 = input.obj_lens_phi_54*mt::c_deg_2_rad;
      input_multislice.obj_lens.c_56 = input.obj_lens_c_56;
      input_multislice.obj_lens.phi_56 = input.obj_lens_phi_56*mt::c_deg_2_rad;
      input_multislice.obj_lens.inner_aper_ang = input.obj_lens_inner_aper_ang*mt::c_mrad_2_rad;
      input_multislice.obj_lens.outer_aper_ang = input.obj_lens_outer_aper_ang*mt::c_mrad_2_rad;

      // defocus spread function
      input_multislice.obj_lens.dsf_sigma = input.obj_lens_dsf_sigma;
      input_multislice.obj_lens.dsf_npoints = input.obj_lens_dsf_npoints;

      // source spread function
      input_multislice.obj_lens.ssf_sigma = input_multislice.cond_lens.ssf_sigma;
      input_multislice.obj_lens.ssf_npoints = input_multislice.cond_lens.ssf_npoints;

      // zero defocus reference
      input_multislice.obj_lens.zero_defocus_type = 
        string_to_defocus_type_enum(input.obj_lens_zero_defocus_type);
      input_multislice.obj_lens.zero_defocus_plane = input.obj_lens_zero_defocus_plane;
      input_multislice.obj_lens.set_input_data(input_multislice.E_0, input_multislice.grid_2d);

      // ISTEM/STEM 
      if (input_multislice.is_scanning()) {
        input_multislice.scanning.type = string_to_scanning_type_enum(input.scanning_type);
        input_multislice.scanning.pbc = input.scanning_periodic;
        input_multislice.scanning.ns = input.scanning_ns;
        input_multislice.scanning.x0 = input.scanning_x0;
        input_multislice.scanning.y0 = input.scanning_y0;
        input_multislice.scanning.xe = input.scanning_xe;
        input_multislice.scanning.ye = input.scanning_ye;
        input_multislice.scanning.set_grid();
      }

      if (input_multislice.is_STEM()) {
        FloatType lambda = mt::get_lambda(input_multislice.E_0);
        input_multislice.detector.type = string_to_detector_type_enum(input.detector.type);

        switch (input_multislice.detector.type) {
        case mt::eDT_Circular: 
        {
          int ndetector = input.detector.cir.size();
          if (ndetector > 0) {
            input_multislice.detector.resize(ndetector);
            for (auto i = 0; i < input_multislice.detector.size(); i++) {
              auto inner_ang = input.detector.cir[i].inner_ang*mt::c_mrad_2_rad;
              auto outer_ang = input.detector.cir[i].outer_ang*mt::c_mrad_2_rad;
              input_multislice.detector.g_inner[i] = std::sin(inner_ang) / lambda;
              input_multislice.detector.g_outer[i] = std::sin(outer_ang) / lambda;
            }
          }
        }
        break;
        case mt::eDT_Radial:
        {
          int ndetector = input.detector.radial.size();
          if (ndetector > 0) {
            input_multislice.detector.resize(ndetector);
            for (auto i = 0; i < input_multislice.detector.size(); i++) {
              input_multislice.detector.fx[i].assign(
                  input.detector.radial[i].fx.begin(),
                  input.detector.radial[i].fx.end());
            }
          }
        }
        break;
        case mt::eDT_Matrix:
        {
          int ndetector = input.detector.matrix.size();
          if (ndetector > 0) {
            input_multislice.detector.resize(ndetector);
            for (auto i = 0; i < input_multislice.detector.size(); i++) {
              input_multislice.detector.fR[i].assign(
                  input.detector.matrix[i].fR.begin(),
                  input.detector.matrix[i].fR.end());
            }
          }
        }
        break;
        };
      } else if (input_multislice.is_PED()) {
        input_multislice.theta = input.ped_theta*mt::c_deg_2_rad;
        input_multislice.nrot = input.ped_nrot;
      } else if (input_multislice.is_HCTEM()) {
        input_multislice.theta = input.hci_theta*mt::c_deg_2_rad;
        input_multislice.nrot = input.hci_nrot;
      } else if (input_multislice.is_EELS()) {
        input_multislice.eels_fr.set_input_data(
          mt::eS_Reciprocal, 
          input_multislice.E_0, 
          input.eels_E_loss * mt::c_eV_2_keV, 
          input.eels_m_selection, 
          input.eels_collection_angle * mt::c_mrad_2_rad, 
          string_to_channelling_type_enum(input.eels_channelling_type),
          input.eels_Z);
      } else if (input_multislice.is_EFTEM()) {
        input_multislice.eels_fr.set_input_data(
            mt::eS_Real, 
            input_multislice.E_0, 
            input.eftem_E_loss * mt::c_eV_2_keV, 
            input.eftem_m_selection, 
            input.eftem_collection_angle * mt::c_mrad_2_rad, 
            string_to_channelling_type_enum(input.eftem_channelling_type),
            input.eftem_Z);
      }

      // Select the output region
      input_multislice.output_area.ix_0 = input.output_area_ix_0-1;
      input_multislice.output_area.iy_0 = input.output_area_iy_0-1;
      input_multislice.output_area.ix_e = input.output_area_ix_e-1;
      input_multislice.output_area.iy_e = input.output_area_iy_e-1;

      // Validate the input parameters
      input_multislice.validate_parameters();
      return input_multislice;
    }

    template <typename FloatType>
    Output write_output_multislice(const mt::Output_Multislice<FloatType> &output_multislice) {
      
      // Set some general properties
      Output result;
      result.dx = output_multislice.dx;
      result.dy = output_multislice.dy;
      result.x.assign(output_multislice.x.begin(), output_multislice.x.end());
      result.y.assign(output_multislice.y.begin(), output_multislice.y.end());
      result.thick.assign(output_multislice.thick.begin(), output_multislice.thick.end());

      // Write the output data
      if (output_multislice.is_STEM() || output_multislice.is_EELS()) {
        std::size_t nx = (output_multislice.scanning.is_line()) ? 1 : output_multislice.nx;
        std::size_t ny = output_multislice.ny;
        for (auto i = 0; i < output_multislice.thick.size(); ++i) {
          result.data[i].image_tot.resize(output_multislice.ndetector);
          if (output_multislice.pn_coh_contrib) {
            result.data[i].image_coh.resize(output_multislice.ndetector);
          }
          for (auto j = 0; j < output_multislice.ndetector; ++j) {
            result.data[i].image_tot[j] = Image<double>(
                output_multislice.image_tot[i].image[j].data(), 
                  Image<double>::shape_type({ ny, nx }));
            if (output_multislice.pn_coh_contrib) {
              result.data[i].image_coh[j] = Image<double>(
                  output_multislice.image_coh[i].image[j].data(), 
                    Image<double>::shape_type({ ny, nx }));
            }
          }
        }
      } else if (output_multislice.is_EWFS_EWRS()) {
        for (auto i = 0; i < output_multislice.thick.size(); ++i) {
          if (!output_multislice.is_EWFS_EWRS_SC()) {
            result.data[i].m2psi_tot = Image<double>(
                output_multislice.m2psi_tot[i].data(), 
                  Image<double>::shape_type({
                    (std::size_t) output_multislice.ny,
                    (std::size_t) output_multislice.nx}));
          }
          result.data[i].psi_coh = Image< std::complex<double> >(
              output_multislice.psi_coh[i].data(), 
              Image< std::complex<double> >::shape_type({
                (std::size_t) output_multislice.ny,
                (std::size_t) output_multislice.nx}));
        }
      } else {
        for (auto i = 0; i < output_multislice.thick.size(); ++i) {
          result.data[i].m2psi_tot = Image<double>(
              output_multislice.m2psi_tot[i].data(), 
                Image<double>::shape_type({
                  (std::size_t) output_multislice.ny,
                  (std::size_t) output_multislice.nx}));
          if (output_multislice.pn_coh_contrib) {
            result.data[i].m2psi_coh = Image<double>(
                output_multislice.m2psi_coh[i].data(), 
                Image<double>::shape_type({
                  (std::size_t) output_multislice.ny,
                  (std::size_t) output_multislice.nx}));
          }
        }
      }


      // Return the result
      return result;
    }
  }

  template <typename FloatType, mt::eDevice DeviceType>
  Output run_multislice(SystemConfiguration config, Input input) {

    // Initialise the system configuration and input structures 
    auto system_conf = detail::read_system_configuration(config);
    auto input_multislice = detail::read_input_multislice<FloatType>(input);
    input_multislice.system_conf = system_conf;

    // Create the output structure
    mt::Output_Multislice<FloatType> output_multislice;
   
    // Run the simulation 
    detail::run_multislice_internal<FloatType, DeviceType>(
      system_conf, input_multislice, output_multislice);

    // Return the output struct
    return detail::write_output_multislice(output_multislice);
  }

  Output simulate(SystemConfiguration config, Input input) {
    Output result;
    if (config.device == "host" && config.precision == "float") {
      result = run_multislice<float, mt::e_host>(config, input);
    } else if (config.device == "host" && config.precision == "double") {
      result = run_multislice<double, mt::e_host>(config, input);
    } else if (config.device == "device" && config.precision == "float") {
      result = run_multislice<float, mt::e_device>(config, input);
    } else if (config.device == "device" && config.precision == "double") {
      result = run_multislice<double, mt::e_device>(config, input);
    } else {
      if (config.device != "host" && config.device != "device") {
        throw std::runtime_error("Unknown device");
      }
      if (config.precision != "float" && config.precision != "double") {
        throw std::runtime_error("Unknown precision");
      }
    } 
    return result;
  }

  bool is_gpu_available() {
    return mt::is_gpu_available();
  }

  int number_of_gpu_available() {
    return mt::number_of_gpu_available();
  }

}

