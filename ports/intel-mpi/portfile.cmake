set(INTELMPI_VERSION "2021.8.0")
set(SOURCE_PATH "${CURRENT_BUILDTREES_DIR}/src/intel-mpi-${INTELMPI_VERSION}")

file(TO_NATIVE_PATH "${SDK_ARCHIVE}" SDK_ARCHIVE)
file(TO_NATIVE_PATH "${SOURCE_PATH}/sdk" SDK_SOURCE_DIR)

# Download and install Intel MPI.
# TODO: The installation will failed if Intel MPI is already installed because
# the installer sets some information in Windows registry. We need to
# find a way to detect current installation and use it or it may be possible to use
# some options of the installer (--product-id).
if (NOT EXISTS "${SDK_SOURCE_DIR}")

  vcpkg_download_distfile(REDIST_ARCHIVE
    URLS "https://registrationcenter-download.intel.com/akdlm/irc_nas/19160/w_mpi_oneapi_p_2021.8.0.25543_offline.exe"
    FILENAME "intel-mpi-setup-${INTELMPI_VERSION}.exe"
    SHA512 2471ce4b2c986fd29a2b7927553bdbf87be1d98f8f9580fe9a4068a61b552d4d68095104008886f4b76f50742a08566f8edbcd01b9b31e4460802a5ec11f0b33
    )

  set(SCRIPT_FILE "${CURRENT_BUILDTREES_DIR}/intel-mpi-install.bat")
  # Write the command out to a script file and run that to avoid weird escaping behavior when spaces are present
  file(WRITE ${SCRIPT_FILE} "${REDIST_ARCHIVE} -s -a --silent --eula=accept --install-dir \"${SDK_SOURCE_DIR}\" --log-dir ${CURRENT_BUILDTREES_DIR}")

  vcpkg_execute_required_process(
    COMMAND ${SCRIPT_FILE}
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
    LOGNAME install-sdk
    )
endif()

set(SOURCE_INCLUDE_PATH "${SDK_SOURCE_DIR}/mpi/${INTELMPI_VERSION}/include")
set(SOURCE_LIB_PATH "${SDK_SOURCE_DIR}/mpi/${INTELMPI_VERSION}/lib/release")
set(SOURCE_DEBUG_LIB_PATH "${SDK_SOURCE_DIR}/mpi/${INTELMPI_VERSION}/lib/debug")
set(SOURCE_BIN_PATH "${SDK_SOURCE_DIR}/mpi/${INTELMPI_VERSION}/bin/release")
set(SOURCE_DEBUG_BIN_PATH "${SDK_SOURCE_DIR}/mpi/${INTELMPI_VERSION}/bin/debug")
set(SOURCE_TOOLS_PATH "${SDK_SOURCE_DIR}/mpi/${INTELMPI_VERSION}/bin")
set(SOURCE_INCLUDE_FILES
  "${SOURCE_INCLUDE_PATH}/mpi.h"
  "${SOURCE_INCLUDE_PATH}/mpicxx.h"
  "${SOURCE_INCLUDE_PATH}/mpif.h"
  "${SOURCE_INCLUDE_PATH}/mpio.h"
  "${SOURCE_INCLUDE_PATH}/mpiof.h"
  )

# Get files in bin directory
file(GLOB
  TOOLS_FILES
  "${SOURCE_TOOLS_PATH}/*.exe"
  "${SOURCE_TOOLS_PATH}/*.dll"
  "${SOURCE_TOOLS_PATH}/*.bat"
  )

# Install tools files
file(INSTALL
  ${TOOLS_FILES}
  DESTINATION
  "${CURRENT_PACKAGES_DIR}/tools/${PORT}"
  )

# Also install include files in the tools directory
# because the compiler wrappers (mpicc.bat for example) needs them
file(INSTALL
  ${SOURCE_INCLUDE_FILES}
  DESTINATION
  "${CURRENT_PACKAGES_DIR}/tools/${PORT}/include"
  )

# Install include files
file(INSTALL
  ${SOURCE_INCLUDE_FILES}
  DESTINATION
  "${CURRENT_PACKAGES_DIR}/include"
  )

# Install release library files
file(INSTALL
  "${SOURCE_LIB_PATH}/impi.lib"
  "${SOURCE_LIB_PATH}/impicxx.lib"
  DESTINATION "${CURRENT_PACKAGES_DIR}/lib"
  )

# Install debug library files
file(INSTALL
  "${SOURCE_DEBUG_LIB_PATH}/impi.lib"
  "${SOURCE_DEBUG_LIB_PATH}/impicxx.lib"
  DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib"
  )

file(INSTALL
  "${SOURCE_BIN_PATH}/impi.dll"
  "${SOURCE_BIN_PATH}/impi.pdb"
  DESTINATION "${CURRENT_PACKAGES_DIR}/bin"
  )

file(INSTALL
  "${SOURCE_DEBUG_BIN_PATH}/impi.dll"
  "${SOURCE_DEBUG_BIN_PATH}/impi.pdb"
  DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin"
  )

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/mpi-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# Handle copyright
file(COPY "${SOURCE_PATH}/sdk/licensing/2023.0.0/license.htm" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "See the accompanying 'licence.htm'")
