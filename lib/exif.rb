#!/usr/bin/env ruby
# Copyright (c) 2006 - R.W. van 't Veer

module EXIFR  
  # = EXIF decoder
  #
  # The EXIF class contains the EXIF properties.
  #
  #
  # == Date properties
  #
  # The properties <tt>:date_time</tt>, <tt>:date_time_original</tt>,
  # <tt>:date_time_digitized</tt> are stored in a EXIF tags as an ASCII
  # string.  This class stores them as Time objects.
  #
  #
  # == Orientation
  #
  # The property <tt>:orientation</tt> describes the subject rotated and/or
  # mirrored in relation to the camera.  The value is stored in an EXIF tags
  # as an integer.  This class stores this value as a module;
  #
  # * TopLeftOrientation
  # * TopRightOrientation
  # * BottomRightOrientation
  # * BottomLeftOrientation
  # * LeftTopOrientation
  # * RightTopOrientation
  # * RightBottomOrientation
  # * LeftBottomOrientation
  #
  # These modules have two methods:
  # * <tt>to_i</tt>; return the original EXIF tag integer
  # * <tt>transform_rmagick(image)</tt>; transforms the given RMagick::Image
  #   to a viewable version
  #
  class EXIF < Hash
    TAGS = {} # :nodoc:
    TAGS.merge!({
      :image => {
        0x00FE => :new_subfile_type,
        0x00FF => :subfile_type,
        0x0100 => :image_width,
        0x0101 => :image_length,
        0x0102 => :bits_per_sample,
        0x0103 => :compression,
        0x0106 => :photometric_interpretation,
        0x0107 => :threshholding,
        0x0108 => :cell_width,
        0x0109 => :cell_length,
        0x010a => :fill_order,
        0x010d => :document_name,
        0x010e => :image_description,
        0x010f => :make,
        0x0110 => :model,
        0x0111 => :strip_offsets,
        0x0112 => :orientation,
        0x0115 => :samples_per_pixel,
        0x0116 => :rows_per_strip,
        0x0117 => :strip_byte_counts,
        0x0118 => :min_sample_value,
        0x0119 => :max_sample_value,
        0x011a => :x_resolution,
        0x011b => :y_resolution,
        0x011c => :planar_configuration,
        0x011d => :page_name,
        0x011e => :x_position,
        0x011f => :y_position,
        0x0120 => :free_offsets,
        0x0121 => :free_byte_counts,
        0x0122 => :gray_response_unit,
        0x0123 => :gray_response_curve,
        0x0124 => :t4_options,
        0x0125 => :t6_options,
        0x0128 => :resolution_unit,
        0x012d => :transfer_function,
        0x0131 => :software,
        0x0132 => :date_time,
        0x013b => :artist,
        0x013c => :host_computer,
        0x013a => :predictor,
        0x013e => :white_point,
        0x013f => :primary_chromaticities,
        0x0140 => :color_map,
        0x0141 => :halftone_hints,
        0x0142 => :tile_width,
        0x0143 => :tile_length,
        0x0144 => :tile_offsets,
        0x0145 => :tile_byte_counts,
        0x0146 => :bad_fax_lines,
        0x0147 => :clean_fax_data,
        0x0148 => :consecutive_bad_fax_lines,
        0x014a => :sub_ifds,
        0x014c => :ink_set,
        0x014d => :ink_names,
        0x014e => :number_of_inks,
        0x0150 => :dot_range,
        0x0151 => :target_printer,
        0x0152 => :extra_samples,
        0x0156 => :transfer_range,
        0x0157 => :clip_path,
        0x0158 => :x_clip_path_units,
        0x0159 => :y_clip_path_units,
        0x015a => :indexed,
        0x015b => :jpeg_tables,
        0x015f => :opi_proxy,
        0x0190 => :global_parameters_ifd,
        0x0191 => :profile_type,
        0x0192 => :fax_profile,
        0x0193 => :coding_methods,
        0x0194 => :version_year,
        0x0195 => :mode_number,
        0x01B1 => :decode,
        0x01B2 => :default_image_color,
        0x0200 => :jpegproc,
        0x0201 => :jpeg_interchange_format,
        0x0202 => :jpeg_interchange_format_length,
        0x0203 => :jpeg_restart_interval,
        0x0205 => :jpeg_lossless_predictors,
        0x0206 => :jpeg_point_transforms,
        0x0207 => :jpeg_q_tables,
        0x0208 => :jpeg_dc_tables,
        0x0209 => :jpeg_ac_tables,
        0x0211 => :ycb_cr_coefficients,
        0x0212 => :ycb_cr_sub_sampling,
        0x0213 => :ycb_cr_positioning,
        0x0214 => :reference_black_white,
        0x022F => :strip_row_counts,
        0x02BC => :xmp,
        0x800D => :image_id,
        0x87AC => :image_layer,
        0x8298 => :copyright,
        0x83bb => :iptc,

        0x8769 => :exif,
        0x8825 => :gps,
      },
      
      :exif => {
        0x829a => :exposure_time,
        0x829d => :fnumber,
        0x8822 => :exposure_program,
        0x8824 => :spectral_sensitivity,
        0x8827 => :iso_speed_ratings,
        0x8828 => :oecf,
        0x9000 => :exif_version,
        0x9003 => :date_time_original,
        0x9004 => :date_time_digitized,
        0x9101 => :components_configuration,
        0x9102 => :compressed_bits_per_pixel,
        0x9201 => :shutter_speed_value,
        0x9202 => :aperture_value,
        0x9203 => :brightness_value,
        0x9204 => :exposure_bias_value,
        0x9205 => :max_aperture_value,
        0x9206 => :subject_distance,
        0x9207 => :metering_mode,
        0x9208 => :light_source,
        0x9209 => :flash,
        0x920a => :focal_length,
        0x9214 => :subject_area,
        0x927c => :maker_note,
        0x9286 => :user_comment,
        0x9290 => :subsec_time,
        0x9291 => :subsec_time_orginal,
        0x9292 => :subsec_time_digitized,
        0xa000 => :flashpix_version,
        0xa001 => :color_space,
        0xa002 => :pixel_x_dimension,
        0xa003 => :pixel_y_dimension,
        0xa004 => :related_sound_file,
        0xa005 => :interoperability,
        0xa20b => :flash_energy,
        0xa20c => :spatial_frequency_response,
        0xa20e => :focal_plane_x_resolution,
        0xa20f => :focal_plane_y_resolution,
        0xa210 => :focal_plane_resolution_unit,
        0xa214 => :subject_location,
        0xa215 => :exposure_index,
        0xa217 => :sensing_method,
        0xa300 => :file_source,
        0xa301 => :scene_type,
        0xa302 => :cfa_pattern,
        0xa401 => :custom_rendered,
        0xa402 => :exposure_mode,
        0xa403 => :white_balance,
        0xa404 => :digital_zoom_ratio,
        0xa405 => :focal_length_in_35mm_film,
        0xa406 => :scene_capture_type,
        0xa407 => :gain_control,
        0xa408 => :contrast,
        0xa409 => :saturation,
        0xa40a => :sharpness,
        0xa40b => :device_setting_description,
        0xa40c => :subject_distance_range,
        0xa420 => :image_unique_id
      },
      
      :gps => {
        0x0000 => :gps_version_id,
        0x0001 => :gps_latitude_ref,
        0x0002 => :gps_latitude,
        0x0003 => :gps_longitude_ref,
        0x0004 => :gps_longitude,
        0x0005 => :gps_altitude_ref,
        0x0006 => :gps_altitude  ,
        0x0007 => :gps_time_stamp,
        0x0008 => :gps_satellites,
        0x0009 => :gps_status,
        0x000a => :gps_measure_mode,
        0x000b => :gps_dop,
        0x000c => :gps_speed_ref,
        0x000d => :gps_speed,
        0x000e => :gps_track_ref,
        0x000f => :gps_track,
        0x0010 => :gps_img_direction_ref,
        0x0011 => :gps_img_direction,
        0x0012 => :gps_map_datum,
        0x0013 => :gps_dest_latitude_ref,
        0x0014 => :gps_dest_latitude,
        0x0015 => :gps_dest_longitude_ref,
        0x0016 => :gps_dest_longitude,
        0x0017 => :gps_dest_bearing_ref,
        0x0018 => :gps_dest_bearing,
        0x0019 => :gps_dest_distance_ref,
        0x001a => :gps_dest_distance,
        0x001b => :gps_processing_method,
        0x001c => :gps_area_information,
        0x001d => :gps_date_stamp,
        0x001e => :gps_differential,
      },
      
      :interoperability => {
        0x0001 => :interoperability_index
      }
    })
    EXIF_HEADERS = [:exif, :gps, :interoperability] # :nodoc:

    time_proc = proc do |value|
      if value =~ /^(\d{4}):(\d\d):(\d\d) (\d\d):(\d\d):(\d\d)$/
        Time.mktime($1, $2, $3, $4, $5, $6) rescue nil
      else
        value
      end
    end

    ORIENTATIONS = [] # :nodoc:
    [
      nil,
      [:TopLeft, 'img'],
      [:TopRight, 'img.flop'],
      [:BottomRight, 'img.rotate(180)'],
      [:BottomLeft, 'img.flip'],
      [:LeftTop, 'img.rotate(90).flop'],
      [:RightTop, 'img.rotate(90)'],
      [:RightBottom, 'img.rotate(270).flop'],
      [:LeftBottom, 'img.rotate(270)'],
    ].each_with_index do |tuple,index|
      next unless tuple
      name, rmagic_code = *tuple
      
      eval <<-EOS
        module #{name}Orientation
          def self.to_i; #{index}; end
          def self.transform_rmagick(img); #{rmagic_code}; end
        end
        ORIENTATIONS[#{index}] = #{name}Orientation
      EOS
    end
    
    ADAPTERS = Hash.new { proc { |v| v } } # :nodoc:
    ADAPTERS.merge!({
      :date_time_original => time_proc,
      :date_time_digitized => time_proc,
      :date_time => time_proc,
      :orientation => proc { |v| ORIENTATIONS[v] }
    })

    # +data+ the content of the JPEG APP1 frame without the EXIF marker
    def initialize(data)
      traverse(data)
      pull_thumbnail(data)
      freeze
    end

    # thumbnail, if included
    attr_reader :thumbnail

    # convience; <tt>self[method]</tt>
    def method_missing(method, *args)
      self[method]
    end

  private
    def traverse(data, offset = nil, ifd = :image)
      TiffHeader.new(data, offset).fields.each do |f|
        tag = TAGS[ifd][f.tag]
        value = f.value.map { |v| ADAPTERS[tag][v] } if f.value
        value = (value.kind_of?(Array) && value.size == 1) ? value.first : value
        if EXIF_HEADERS.include?(tag)
          traverse(data, f.offset, tag)
        elsif tag
          self[tag] = value
        end
      end
    end
    
    def pull_thumbnail(data)
      start, length = self[:jpeg_interchange_format], self[:jpeg_interchange_format_length]
      @thumbnail = data[start..(start + length)] if start && length
    end
  end
end
