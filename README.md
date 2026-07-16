# SatellaOS Devuan Edition (Testing)

The experimental Devuan edition of SatellaOS, focused on delivering a lightweight, modern desktop powered exclusively by **OpenRC** while preserving the project's philosophy of simplicity and user freedom.

---

> [!CAUTION]
> ## Use at Your Own Risk
>
> This is the **official experimental testing repository** for **SatellaOS Devuan Edition**.
>
> Everything in this repository is considered **highly unstable**.
>
> - Packages may be added, removed, or replaced at any time.
> - Features may be incomplete or broken.
> - Updates may introduce regressions.
> - Compatibility with third-party software is not guaranteed.
> - There is **no guarantee** of stability, compatibility, or data safety.
>
> If you are looking for a stable experience, please use the standard Debian edition of SatellaOS instead.

---

# 🚀 Why This Repository Exists

SatellaOS Devuan Edition exists to provide a **fully OpenRC-powered** alternative to the standard Debian edition without relying on systemd.

Instead of experimenting with multiple init systems, this project officially supports **OpenRC only**, allowing development to focus on stability, simplicity, and a consistent user experience.

The long-term goal is to deliver the same modern SatellaOS experience while remaining completely independent of systemd.

---

# 🧪 Project Goals

Current objectives include:

- Maintain a fully systemd-free operating system.
- Use **OpenRC** as the official init system.
- Maintain compatibility with SatellaOS tools.
- Preserve the modern XFCE desktop experience.
- Keep the operating system lightweight.
- Improve modularity and maintainability.
- Build a stable foundation for future releases.

---

# 🏗️ Foundation

Like the standard edition, **SatellaOS Devuan Edition** follows the **Tree Installer System**.

Instead of distributing custom ISO images, SatellaOS transforms an existing minimal Devuan installation into a complete desktop operating system.

Benefits include:

- Always installing the latest available packages.
- Smaller maintenance workload.
- Faster development.
- No custom ISO images to rebuild after every update.

---

# 🌳 Tree Installer System

SatellaOS uses a **setup.sh** installation system.

The installer:

- Uses an existing minimal Devuan installation.
- Downloads the latest packages directly from the internet.
- Builds the operating system during installation.
- Allows development to focus on features instead of maintaining ISO images.

---

# ☁️ Cloud Release Model

SatellaOS follows a **Cloud Release** model.

Instead of shipping outdated installation scripts, the latest installer components are downloaded whenever they are needed.

Benefits include:

- Faster bug fixes.
- Faster feature deployment.
- Always up-to-date installer components.
- Easier maintenance.

---

# 🎯 Development Target

SatellaOS Devuan Edition (Testing) is officially developed for **Devuan Excalibur**.

All development, testing, and compatibility efforts are focused on **Devuan Excalibur** to provide the most stable OpenRC-based experience possible.

Support for other Devuan releases is not guaranteed.

---

# ⚠️ Experimental Notice

Although OpenRC is now the official init system, this repository remains **experimental**.

Because of this:

- Some services may still require additional work.
- Unexpected bugs should be expected.
- Configuration changes may occur between updates.
- Performance and compatibility may improve over time.

This repository is intended primarily for development, testing, and community feedback.

---

# 🎨 User Interface

SatellaOS Devuan Edition aims to provide the same modern XFCE experience as the standard edition.

Users can expect:

- Low memory usage.
- Low CPU usage.
- Clean desktop layout.
- Minimal preinstalled applications.

---

# 🧹 Minimal Software Philosophy

SatellaOS does not force users to use specific applications.

Users are free to choose their preferred:

- Web browser
- Office suite
- Media player
- Image viewer
- Text editor

---

# 📦 SatellaOS Ecosystem

The Devuan edition shares the same ecosystem as the standard edition.

This includes:

- SatellaOS Deb Creator
- SatellaOS Packages
- Installer utilities
- Future SatellaOS applications

Whenever possible, SatellaOS tools are designed to remain compatible with both Debian and Devuan.

---

# 📥 Installation

> ⚠️ Before starting, make sure you have a working **minimal Devuan installation using OpenRC**.

This project is intended exclusively for **Devuan + OpenRC** and is **not supported** on Debian systems running systemd.

---

# ❤️ Philosophy

SatellaOS is built around four core principles:

- Lightweight Design
- User Freedom
- Simplicity
- Modern Appearance

SatellaOS Devuan Edition extends these principles by delivering a modern Linux experience without relying on systemd.

The purpose of this project is **not** to criticize any particular software or distribution.

Its goal is simply to provide another choice for users who prefer a lightweight, OpenRC-based operating system.

---

# 🔬 Current Status

This repository is currently considered **experimental**.

Expect:

- Frequent commits.
- Force pushes.
- Breaking changes.
- Incomplete features.
- Configuration changes without notice.

Feedback, bug reports, and testing are always welcome.

---

# 📜 License

This project is licensed under the **MIT License**.

You are free to use, modify, distribute, and redistribute the software, provided that the original copyright notice and license text are included.

See the `LICENSE` file for more information.