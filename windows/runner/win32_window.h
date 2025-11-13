// Copyright 2024 Campbnb Québec. All rights reserved.

#ifndef RUNNER_WIN32_WINDOW_H_
#define RUNNER_WIN32_WINDOW_H_

#include <windows.h>

#include <functional>
#include <memory>
#include <string>

// Une abstraction de classe pour une fenêtre Win32 compatible haute DPI
// Destinée à être héritée par des classes qui souhaitent se spécialiser avec
// un rendu et une gestion d'entrée personnalisés
class Win32Window {
 public:
  struct Point {
    unsigned int x;
    unsigned int y;
    Point(unsigned int x, unsigned int y) : x(x), y(y) {}
  };

  struct Size {
    unsigned int width;
    unsigned int height;
    Size(unsigned int width, unsigned int height)
        : width(width), height(height) {}
  };

  Win32Window();
  virtual ~Win32Window();

  // Crée et affiche une fenêtre win32 avec |title| et position et taille en utilisant
  // |origin| et |size|. Les nouvelles fenêtres sont créées sur le moniteur par défaut.
  // Les tailles de fenêtre sont spécifiées au système d'exploitation en pixels physiques,
  // donc pour garantir une taille cohérente, cette fonction traitera la largeur/hauteur
  // passée comme pixels logiques et les mettra à l'échelle appropriée pour le moniteur par défaut.
  // Retourne true si la fenêtre a été créée avec succès.
  bool CreateAndShow(const std::wstring& title,
                     const Point& origin,
                     const Size& size);

  // Libérer les ressources OS associées à la fenêtre
  void Destroy();

  // Insère |content| dans l'arbre de fenêtres
  void SetChildContent(HWND content);

  // Retourne le handle de fenêtre de support pour permettre aux clients de définir l'icône
  // et d'autres propriétés de fenêtre. Retourne nullptr si la fenêtre a été détruite.
  HWND GetHandle();

  // Si true, fermer cette fenêtre quittera l'application
  void SetQuitOnClose(bool quit_on_close);

  // Retourne un RECT représentant les limites de la zone cliente actuelle
  RECT GetClientArea();

 protected:
  // Traite et route les messages de fenêtre importants pour la gestion de la souris,
  // le changement de taille et le DPI. Délègue la gestion de ceux-ci aux surcharges
  // de membres que les classes héritantes peuvent gérer.
  virtual LRESULT MessageHandler(HWND window,
                                 UINT const message,
                                 WPARAM const wparam,
                                 LPARAM const lparam) noexcept;

  // Appelé lorsque CreateAndShow est appelé, permettant la configuration liée aux fenêtres
  // de la sous-classe. Les sous-classes doivent retourner false si la configuration échoue.
  virtual bool OnCreate();

  // Appelé lorsque Destroy est appelé
  virtual void OnDestroy();

 private:
  friend class WindowClassRegistrar;

  // Callback OS appelé par la pompe de messages. Gère le message WM_NCCREATE qui
  // est passé lorsque la zone non cliente est en cours de création et active
  // la mise à l'échelle DPI non cliente automatique afin que la zone non cliente
  // réponde automatiquement aux changements de DPI. Tous les autres messages sont
  // gérés par MessageHandler.
  static LRESULT CALLBACK WndProc(HWND const window,
                                  UINT const message,
                                  WPARAM const wparam,
                                  LPARAM const lparam) noexcept;

  // Récupère un pointeur d'instance de classe pour |window|
  static Win32Window* GetThisFromHandle(HWND const window) noexcept;

  bool quit_on_close_ = false;

  // handle de fenêtre pour la fenêtre de niveau supérieur
  HWND window_handle_ = nullptr;

  // handle de fenêtre pour le contenu hébergé
  HWND child_content_ = nullptr;
};

#endif  // RUNNER_WIN32_WINDOW_H_

