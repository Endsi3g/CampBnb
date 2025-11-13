// Copyright 2024 Campbnb Québec. All rights reserved.

#ifndef RUNNER_FLUTTER_WINDOW_H_
#define RUNNER_FLUTTER_WINDOW_H_

#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>

#include <memory>

#include "win32_window.h"

// Une fenêtre qui ne fait rien d'autre qu'héberger une vue Flutter
class FlutterWindow : public Win32Window {
 public:
  // Crée une nouvelle FlutterWindow hébergeant une vue Flutter exécutant |project|
  explicit FlutterWindow(const flutter::DartProject& project);
  virtual ~FlutterWindow();

 protected:
  // Win32Window:
  bool OnCreate() override;
  void OnDestroy() override;
  LRESULT MessageHandler(HWND window, UINT const message, WPARAM const wparam,
                         LPARAM const lparam) noexcept override;

 private:
  // Le projet à exécuter
  flutter::DartProject project_;

  // L'instance Flutter hébergée par cette fenêtre
  std::unique_ptr<flutter::FlutterViewController> flutter_controller_;
};

#endif  // RUNNER_FLUTTER_WINDOW_H_

