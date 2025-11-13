// Copyright 2024 Campbnb Québec. All rights reserved.

#ifndef RUNNER_UTILS_H_
#define RUNNER_UTILS_H_

#include <string>
#include <vector>

// Crée une console pour le processus et redirige stdout et stderr vers
// elle pour le runner et la bibliothèque Flutter
void CreateAndAttachConsole();

// Prend un wchar_t* terminé par null encodé en UTF-16 et retourne un std::string
// encodé en UTF-8. Retourne un std::string vide en cas d'échec
std::string Utf8FromUtf16(const wchar_t* utf16_string);

// Obtient les arguments de ligne de commande passés comme std::vector<std::string>,
// encodé en UTF-8. Retourne un std::vector<std::string> vide en cas d'échec
std::vector<std::string> GetCommandLineArguments();

#endif  // RUNNER_UTILS_H_

