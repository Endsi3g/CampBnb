# Copyright 2024 Campbnb Québec. All rights reserved.
# Configuration du projet Windows pour Campbnb

# Configuration au niveau du projet
cmake_minimum_required(VERSION 3.14)
project(campbnb_quebec LANGUAGES CXX)

# Le nom de l'exécutable créé pour l'application
set(BINARY_NAME "campbnb_quebec")

# Opt-in explicite aux comportements modernes de CMake
cmake_policy(VERSION 3.14...3.25)

# Définir l'option de configuration de build
get_property(IS_MULTICONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(IS_MULTICONFIG)
  set(CMAKE_CONFIGURATION_TYPES "Debug;Profile;Release"
    CACHE STRING "" FORCE)
else()
  if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE "Debug" CACHE
      STRING "Flutter build mode" FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
      "Debug" "Profile" "Release")
  endif()
endif()

# Définir les paramètres pour le mode Profile
set(CMAKE_EXE_LINKER_FLAGS_PROFILE "${CMAKE_EXE_LINKER_FLAGS_RELEASE}")
set(CMAKE_SHARED_LINKER_FLAGS_PROFILE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE}")
set(CMAKE_C_FLAGS_PROFILE "${CMAKE_C_FLAGS_RELEASE}")
set(CMAKE_CXX_FLAGS_PROFILE "${CMAKE_CXX_FLAGS_RELEASE}")

# Utiliser Unicode pour tous les projets
add_definitions(-DUNICODE -D_UNICODE)

# Paramètres de compilation qui devraient être appliqués à la plupart des cibles
function(APPLY_STANDARD_SETTINGS TARGET)
  target_compile_features(${TARGET} PUBLIC cxx_std_17)
  target_compile_options(${TARGET} PRIVATE /W4 /WX /wd"4100")
  target_compile_options(${TARGET} PRIVATE /EHsc)
  target_compile_definitions(${TARGET} PRIVATE "_HAS_EXCEPTIONS=0")
  target_compile_definitions(${TARGET} PRIVATE "$<$<CONFIG:Debug>:_DEBUG>")
endfunction()

# Règles de build de la bibliothèque et des outils Flutter
set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")
add_subdirectory(${FLUTTER_MANAGED_DIR})

# Build de l'application; voir runner/CMakeLists.txt
add_subdirectory("runner")

# Règles de build des plugins générés, qui gèrent la construction des plugins
# et leur ajout à l'application
include(flutter/generated_plugins.cmake)

target_include_directories(${BINARY_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/flutter")
target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_plugin)

# === Installation ===
# Les fichiers de support sont copiés à côté de l'exécutable, afin qu'il puisse
# s'exécuter en place. Cela est fait au lieu de créer un bundle séparé (comme sur Linux)
# pour que la construction et l'exécution depuis Visual Studio fonctionnent.
set(BUILD_BUNDLE_DIR "$<TARGET_FILE_DIR:${BINARY_NAME}>")
# Rendre l'étape "install" par défaut, car elle est requise pour l'exécution
set(CMAKE_VS_INCLUDE_INSTALL_TO_DEFAULT_BUILD 1)
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX "${BUILD_BUNDLE_DIR}" CACHE PATH "..." FORCE)
endif()

set(INSTALL_BUNDLE_DATA_DIR "${CMAKE_INSTALL_PREFIX}/data")
set(INSTALL_BUNDLE_LIB_DIR "${CMAKE_INSTALL_PREFIX}")

install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION "${CMAKE_INSTALL_PREFIX}"
  COMPONENT Runtime)

install(FILES "${FLUTTER_ICU_DATA_FILE}" DESTINATION "${INSTALL_BUNDLE_DATA_DIR}"
  COMPONENT Runtime)

install(FILES "${FLUTTER_LIBRARY}" DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
  COMPONENT Runtime)

set(PLUGIN_BUNDLED_LIBRARIES)
if(PLUGIN_BUNDLED_LIBRARIES)
  install(FILES "${PLUGIN_BUNDLED_LIBRARIES}"
    DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
    COMPONENT Runtime)
endif()

# Recopier complètement le répertoire assets à chaque build pour éviter d'avoir
# des fichiers obsolètes d'une installation précédente
set(FLUTTER_ASSET_DIR_NAME "flutter_assets")
install(CODE "
  file(REMOVE_RECURSE \"${INSTALL_BUNDLE_DATA_DIR}/${FLUTTER_ASSET_DIR_NAME}\")
  " COMPONENT Runtime)
install(DIRECTORY "${PROJECT_BUILD_DIR}/${FLUTTER_ASSET_DIR_NAME}"
  DESTINATION "${INSTALL_BUNDLE_DATA_DIR}" COMPONENT Runtime)

# Installer la bibliothèque AOT uniquement sur les builds non-Debug
install(FILES "${AOT_LIBRARY}" DESTINATION "${INSTALL_BUNDLE_DATA_DIR}"
  CONFIGURATIONS Profile;Release
  COMPONENT Runtime)

