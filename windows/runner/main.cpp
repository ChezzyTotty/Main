#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

class CustomFlutterWindow : public FlutterWindow {
 public:
  CustomFlutterWindow(const flutter::DartProject& project)
      : FlutterWindow(project) {}

 protected:
  LRESULT MessageHandler(HWND hwnd, UINT const message, WPARAM const wparam,
                         LPARAM const lparam) noexcept override {
    switch (message) {
      case WM_GETMINMAXINFO: {
        // Pencere boyutunu sabit tutun
        MINMAXINFO* minMaxInfo = reinterpret_cast<MINMAXINFO*>(lparam);
        minMaxInfo->ptMinTrackSize.x = 1280;  // Genişlik
        minMaxInfo->ptMinTrackSize.y = 720;   // Yükseklik
        minMaxInfo->ptMaxTrackSize.x = 1280;  // Genişlik
        minMaxInfo->ptMaxTrackSize.y = 720;   // Yükseklik
        return 0;
      }
      default:
        return FlutterWindow::MessageHandler(hwnd, message, wparam, lparam);
    }
  }
};

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Konsolu ekleyin veya oluşturun.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // COM'u başlatın.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments = GetCommandLineArguments();
  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  CustomFlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  
  // Türkçe karakter desteği için başlığı UTF-16 olarak tanımlayın.
  if (!window.Create(L"", origin, size)) {
    return EXIT_FAILURE;
  }
  
  // Büyütme/küçültme düğmesini devre dışı bırakın
  LONG style = GetWindowLong(window.GetHandle(), GWL_STYLE);
  style &= ~WS_MAXIMIZEBOX;
  SetWindowLong(window.GetHandle(), GWL_STYLE, style);
  
  window.SetQuitOnClose(true);
  window.Show();

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}