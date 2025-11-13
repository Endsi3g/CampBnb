# Copyright 2024 Campbnb Québec. All rights reserved.
# Configuration du runner Windows

cmake_minimum_required(VERSION 3.14)
project(runner LANGUAGES CXX)

# Définir la cible de l'application. Pour changer son nom, changez BINARY_NAME dans le
# CMakeLists.txt de niveau supérieur, pas la valeur ici, sinon `flutter run` ne fonctionnera plus.
#
# Tous les nouveaux fichiers sources que vous ajoutez à l'application doivent être ajoutés ici.
add_executable(${BINARY_NAME} WIN32
  "flutter_window.cpp"
  "main.cpp"
  "utils.cpp"
  "win32_window.cpp"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
  "Runner.rc"
  "runner.exe.manifest"
)

# Appliquer l'ensemble standard de paramètres de build. Cela peut être supprimé pour les applications
# qui ont besoin de paramètres de build différents.
apply_standard_settings(${BINARY_NAME})

# Ajouter les définitions de préprocesseur pour la version de build
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION=\"${FLUTTER_VERSION}\"")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MAJOR=${FLUTTER_VERSION_MAJOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MINOR=${FLUTTER_VERSION_MINOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_PATCH=${FLUTTER_VERSION_PATCH}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_BUILD=${FLUTTER_VERSION_BUILD}")

# Désactiver les macros Windows qui entrent en conflit avec les fonctions de la bibliothèque standard C++
target_compile_definitions(${BINARY_NAME} PRIVATE "NOMINMAX")

# Ajouter les bibliothèques de dépendances et les répertoires include. Ajoutez ici toutes les dépendances
# spécifiques à l'application.
target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app)
target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")

# Exécuter les parties de l'outil Flutter du build. Cela ne doit pas être supprimé.
add_dependencies(${BINARY_NAME} flutter_assemble)

