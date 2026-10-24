# 🎭 Heads-Up

A customizable **Heads-Up guessing game** built with [Godot Engine](https://godotengine.org/). Play with your friends, guess the person or character displayed on the screen, and have fun!

## 🎮 Play the Game

There are several ways to play:

- **Run it in Godot:** Clone or download this repository, open the project in Godot, and launch the game directly from the editor.
- **Export to your preferred platform:** Use Godot's export tools to build the game for your platform of choice, such as Windows, macOS, Linux, Android, or the Web, depending on your project's configuration and available export templates.
- **Customize and experiment:** Modify the project, add new content, or change the rules to create your own version of the game.

## ✨ Features

- **Guessing gameplay:** Test your knowledge by guessing the people or characters displayed in the game.
- **LAN multiplayer:** Play with friends on multiple devices connected to the same local network.
- **Customizable categories:** Organize the game around your favorite topics.
- **Editable JSON data:** Easily modify the game's content without having to rewrite the gameplay code.
- **Open and modifiable project:** Explore the source code, experiment with new features, and adapt the game to your preferences.
- **Godot-powered:** Run the project in the Godot editor or export it to a supported platform.

## 🌐 Multiplayer (LAN)

Heads-Up supports multiplayer over a **Local Area Network (LAN)**, allowing multiple players to join the same game using different devices.

### How to Play with Friends

1. **Connect to the same network:** Make sure all devices are connected to the same Wi-Fi network or local network.
2. **Start the game:** Launch Heads-Up on each device.
3. **Host a game:** One player creates the game and acts as the host.
4. **Find the host's IP address:** The host can find the IP address displayed directly in the game.
5. **Join the game:** Other players enter the host's IP address in the game to connect.
6. **Start playing:** Once everyone has joined, enjoy the game together!

**Important:** All devices should be able to communicate over the local network. Firewall settings may need to be adjusted if other players cannot connect.

## 🗂️ Customizing the Game

One of the main features of this project is that its content can be customized by editing its JSON files.

You can modify the existing data to personalize your game:

- **Add or remove categories** to create new guessing themes.
- **Add, remove, or replace people and characters** to suit your interests.
- **Create your own custom decks** around movies, anime, video games, celebrities, historical figures, or any other topic you like.

### Editing the JSON files

1. Open the project directory.
2. Locate the JSON file or files containing the game's categories and persons.
3. Open the relevant file in a text editor.
4. Modify the data while preserving the existing JSON structure.
5. Save the file and launch the game to test your changes.

**Important:** Make sure your JSON remains valid. Keep the expected keys, data types, and structure intact so the game can load your custom content correctly.

For example, a JSON file might look like this:

```json
{
  "categories": [
    {
      "name": "Anime",
      "persons": [
        "Light Yagami",
        "Conan Edogawa",
        "Kaito Kuroba"
      ]
    },
    {
      "name": "Video Games",
      "persons": [
        "Mario",
        "Link",
        "Lara Croft"
      ]
    }
  ]
}
```

*This is an illustrative example. Adapt the structure to match the JSON format actually used by the project.*

## 🛠️ Getting Started

### Requirements

- [Godot Engine](https://godotengine.org/) — version 4.6.1 was used to create this project.
- Git (optional, if you want to clone the repository).

### Run Locally

Clone the repository:

```bash
git clone https://github.com/Haydara1/Heads-Up/
```

Then:

1. Open Godot.
2. Import the project by selecting its `project.godot` file.
3. Open the project in the editor.
4. Press **F6** to run the current scene or **F5** to run the main project.

### Export the Game

To create a standalone build:

1. Open the project in Godot.
2. Navigate to **Project → Export**.
3. Configure an export preset for your target platform.
4. Install the required export templates if prompted.
5. Click **Export Project** and choose your output location.

Refer to the [official Godot export documentation](https://docs.godotengine.org/en/stable/tutorials/export/index.html) for additional information.

## 🤝 Contributing

Feel free to explore the code, customize the content, and build upon the project. You can add new categories, introduce new mechanics, improve the interface, or adapt the game for different platforms.

If you make improvements that could benefit others, consider sharing your changes with the community.

## 📄 License

See the `LICENSE` file in this repository for the terms under which this project can be used, modified, and distributed.

---

**Have fun playing, customizing, and creating your own Heads-Up experience!** 🎉
