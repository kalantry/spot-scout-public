import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
//yea

//=========================================================
// REWARD MODEL
//=========================================================

class RewardItem {
  // custom class that makes it easy to create various items
  final IconData icon;
  final String title;
  final int points;
  bool redeemed; // tracks if the reward has been claimed by the user or not

  RewardItem({
    required this.icon,
    required this.title,
    required this.points,
    this.redeemed =
        false, // Every reward starts as unredeemed because of this.redeemed = false
  });
}


//=========================================================
// MY REWARDS WIDGET
//=========================================================

class MyRewardsWidget extends StatefulWidget { // used to attach to main dart
  const MyRewardsWidget({super.key});

  @override
  State<MyRewardsWidget> createState() => _MyRewardsWidgetState();
}

class _MyRewardsWidgetState extends State<MyRewardsWidget> {
  //=========================================================
  // CONTROLLERS
  //=========================================================

  final TextEditingController searchController = TextEditingController();
  String searchText = "";
// TextEditingController is a state that holds and keeps track of text inside a textfield. Allows code to access and modify

  //=========================================================
  // USER DATA
  //=========================================================

  int points = 3192; // var used for points summary
  int streak = 3;// var used for streak

  //=========================================================
  // REWARDS LIST
  //=========================================================

  final List<RewardItem> rewards = [
    RewardItem(
      icon: Icons.confirmation_number,
      title: "Event Ticket",
      points: 500,
    ),

    RewardItem(
      icon: Icons.local_parking,
      title: "Premium Parking",
      points: 250,
    ),

    RewardItem(
      icon: Icons.local_cafe,
      title: "Coffee Voucher",
      points: 150,
    ),

    RewardItem(
      icon: Icons.fastfood,
      title: "Meal Voucher",
      points: 300,
    ),

    RewardItem(
      icon: Icons.movie,
      title: "Movie Ticket",
      points: 750,
    ),

    RewardItem(
      icon: Icons.shopping_bag,
      title: "Shopping Coupon",
      points: 600,
    ),

    // Gift Cards

    RewardItem(
      icon: Icons.card_giftcard,
      title: "Amazon Gift Card",
      points: 1000,
    ),

    RewardItem(
      icon: Icons.card_giftcard,
      title: "Apple Gift Card",
      points: 1500,
    ),

    RewardItem(
      icon: Icons.card_giftcard,
      title: "Google Play Gift Card",
      points: 800,
    ),

    RewardItem(
      icon: Icons.card_giftcard,
      title: "Steam Gift Card",
      points: 1200,
    ),

    RewardItem(
      icon: Icons.card_giftcard,
      title: "Netflix Gift Card",
      points: 1300,
    ),

    RewardItem(
      icon: Icons.card_giftcard,
      title: "Xbox Gift Card",
      points: 1400,
    ),

    RewardItem(
      icon: Icons.card_giftcard,
      title: "PlayStation Gift Card",
      points: 1400,
    ),

    RewardItem(
      icon: Icons.card_giftcard,
      title: "Target Gift Card",
      points: 900,
    ),

    RewardItem(
      icon: Icons.card_giftcard,
      title: "Walmart Gift Card",
      points: 900,
    ),

    RewardItem(
      icon: Icons.card_giftcard,
      title: "Starbucks Gift Card",
      points: 500,
    ),
  ];

  //=========================================================
  // FILTERED REWARDS
  //=========================================================

  List<RewardItem> get filteredRewards {
    if (searchText.isEmpty) {
      return rewards;
    }

    return rewards.where((reward) {
      return reward.title.toLowerCase().contains(searchText.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // It is the method that creates and returns the user interface (UI) for that widget.

    return Scaffold(
      //=========================================================
      // PAGE BACKGROUND
      //=========================================================

      backgroundColor: Colors.grey.shade100,

      //=========================================================
      // APP BAR
      //=========================================================

      appBar: AppBar(
        elevation: 0, // do not have a shadow under the appbar
        backgroundColor: Colors.white,
        centerTitle: false, // dont center the title

        title: const Text(
          "My Rewards",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Bell Icon built with IconButton

        actions: [
          // This section adds the bell icon

          IconButton(
            onPressed: () {}, // currently stateless

            icon: const Icon(
              Icons.notifications_none, // from built in material icons library

              color: Colors.black,
            ),
          ),
        ],
      ),

      //=========================================================
      // PAGE BODY
      //=========================================================

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          //=========================================================
          // POINTS SUMMARY CARD
          //=========================================================

// Made with a Container, styled with a blue gradient,
// rounded corners, and padding.
// A Row puts the points section on the left and the icon on the right.
// A Column stacks the "Your Points" text and point value vertically.
// CircleAvatar creates the circular background for the star icon.
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xff2196F3),
                  Color(0xff1565C0),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Your Points",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "$points P",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white24,
                  child: Icon(
                    Icons.stars,
                    color: Colors.amber,
                    size: 35,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          //=========================================================
          // SEARCH BAR
          //=========================================================
// TextEditingController manages the text entered into the search bar.
// The TextField connects to the controller to keep track of user input.
// When the user types, onChanged updates searchText using setState.
// The updated searchText is used to filter the rewards list.
          TextField( // constructs the search box user can type 
            controller: searchController, // connects text box to state TextEditingController

            //=========================================================
            // SEARCH FUNCTIONALITY
            //=========================================================

            onChanged: (value) { // Updates search value every time the user types
              setState(() {
                searchText = value; //updates the searchText value and rebuilds the widget so the UI can show the updated results.
              });
            },

            decoration: InputDecoration( // controls visual appeal of search bar
              hintText: "Search rewards...", // placeholder
              prefixIcon: const Icon(Icons.search),
              suffixIcon: const Icon(Icons.tune),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 25),

          //=========================================================
          // DAILY STREAK CARD
          //=========================================================
// main card, orange container
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(20),


            ),

            //organizes everything vertically

            child: Column( 
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row( // this is fire icon+ daily streak, made in a row 
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: Colors.orange,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Daily Streak",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // controls how hildren are spaced along main axis
                  children: List.generate(7, (index) { // index variable was made from list.generate
                    final days = [
                      "M",
                      "T",
                      "W",
                      "T",
                      "F",
                      "S",
                      "S",
                    ];

                    bool completed = index < streak; // checks if day in streak has been completed, when Index < streak
// bool completed turns the circles orange depending on 
                    return Column(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor:
                              completed ? Colors.orange : Colors.grey.shade300,
                          child: completed
                              ? const Icon(
                                  Icons.check,
                                  size: 18,
                                  color: Colors.white,
                                )
                              : Text(
                                  days[index],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 8),
                        Text(days[index]),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 15),
                Text(
                  "Current Streak: $streak Days 🔥",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          //=========================================================
          // AVAILABLE REWARDS TITLE
          //=========================================================

          const Text(
            "Available Rewards",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          //=========================================================
          // REWARDS LIST
          //=========================================================

          ...filteredRewards.map(
            (reward) => Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: rewardCard(
                reward: reward, // function that creates ui for each individual card
              ),
            ),
          ),
//filteredRewards filters your rewards list so only rewards matching the search appear on the screen.
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  //=========================================================
  // REWARD CARD
  //=========================================================

  Widget rewardCard({ // function that creates ui for each individual card
    required RewardItem reward,
  }) {
    final bool canRedeem = points >= reward.points && !reward.redeemed;

    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            //=========================================================
            // REWARD ICON
            //=========================================================

            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.blue.shade50,
              child: Icon(
                reward.icon,
                size: 30,
                color: Colors.blue,
              ),
            ),

            const SizedBox(width: 16),
//After searchText changes, the UI rebuilds and updates the reward list based on the new search.
            //=========================================================
            // REWARD DETAILS
            //=========================================================

            Expanded( // responsible for showing the interfacr for eventicket 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reward.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${reward.points} Points",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            //=========================================================
            // REDEEM BUTTON
            //=========================================================

            ElevatedButton(
              onPressed: canRedeem
                  ? () {
                      setState(() {
                        points -= reward.points;  //subtract from user points

                        reward.redeemed = true;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.green,
                          content: Text(
                            "${reward.title} redeemed successfully!",
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  : () {
                      if (reward.redeemed) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.orange,
                            content: Text(
                              "You have already redeemed this reward.",
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(
                              "Not enough points to redeem this reward.",
                            ),
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: reward.redeemed ? Colors.green : Colors.blue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                reward.redeemed ? "Claimed" : "Redeem",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  //=========================================================
  // DISPOSE
  //=========================================================

  @override // cleans up resources when a widget is removed from the screen.


  void dispose() {
    searchController.dispose();

    super.dispose();
  }
}
//=========================================================
// WIDGET PREVIEW
//=========================================================

@Preview()
Widget myRewardsWidgetPreview() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyRewardsWidget(),
  );
}

// RewardItem is a custom class I made to create different rewards.
// It keeps the icon, reward name, points needed, and if the reward was redeemed.

// StatefulWidget is used because this page has things that change.
// For example, points, search results, and redeemed rewards.

// points stores how many points the user currently has.
// streak stores how many days the user completed.

// This list stores all the rewards that will appear on the page.
// Each reward has its own icon, title, and point amount.

// build() is where I create the UI for the page.
// It returns all the widgets that appear on the screen.

// Scaffold creates the main layout of the page.
// It holds things like the appbar, background, and body.

// AppBar creates the top bar of the page.
// It shows the title and the notification icon.

// IconButton makes the notification icon clickable.
// It currently does not do anything because no function was added.

// Container creates the points card.
// I used gradient, padding, and rounded corners to style the card.

// Row puts widgets next to each other horizontally.
// It places the points information on the left and the icon on the right.

// Column stacks widgets on top of each other.
// It places the "Your Points" text above the points value.

// Expanded lets the points section take the space it needs.
// It helps keep the icon from pushing the text away.

// CircleAvatar creates the circle behind the star icon.

// TextField creates the search bar where the user can type.

// TextEditingController keeps track of what the user types in the search bar.
// It connects the textfield to the code so the app can read the input.

// onChanged runs every time the user types something.
// It updates searchText so the app knows what the user searched.

// setState updates the page after searchText changes.
// This makes the new filtered results appear.

// InputDecoration controls how the search bar looks.
// It adds the hint text, icons, color, and rounded shape.

// The streak Container creates the daily streak card.
// It uses orange colors, padding, and rounded corners.

// The Column organizes the streak information vertically.

// The first Row puts the fire icon and Daily Streak text beside each other.

// List.generate creates 7 circles for the days of the week.
// Index keeps track of which day it is.

// bool completed checks if the day was completed.
// If the index is smaller than the streak number, it becomes true.

// completed changes the circle color.
// Completed days turn orange and show a check mark.

// filteredRewards checks what the user types in the search bar.
// If nothing is typed, it shows all rewards.
// If something is typed, it only shows matching rewards.

// filteredRewards.map goes through each reward and creates a card.

// rewardCard() is a function I made to create each reward card.
// It takes a reward and builds the UI for it.

// Card creates the white box that holds each reward.

// The reward Row puts the icon, information, and button in one line.

// Expanded gives the reward information more space in the card.

// The Column inside Expanded stacks the reward name and points.

// ElevatedButton creates the redeem button.
// It allows the user to claim rewards.

// canRedeem checks if the user has enough points and has not claimed it before.

// setState updates the page after redeeming a reward.

// points -= reward.points subtracts the reward cost from the user's points.

// reward.redeemed changes the reward status to claimed.

// SnackBar shows a small message after the user redeems or gets an error.

// dispose removes the search controller when the page closes.
// This helps clean up unused data.

// Preview lets me see the widget while designing it.

// ye
