# Product Requirements Document (PRD)
# GoCars: Code Your Way Through Traffic

---

**Document Version:** 1.0  
**Date:** January 2026  
**Team Name:** [Team Name]  
**Event:** TrackTech: CSS Hackathon 2026  

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Product Overview](#2-product-overview)
3. [Target Users and Personas](#3-target-users-and-personas)
4. [Feature Requirements](#4-feature-requirements)
5. [Technical Requirements](#5-technical-requirements)
6. [User Interface Specifications](#6-user-interface-specifications)
7. [Content Requirements](#7-content-requirements)
8. [Non-Functional Requirements](#8-non-functional-requirements)
9. [User Stories](#9-user-stories)
10. [Development Roadmap](#10-development-roadmap)
11. [Risk Assessment](#11-risk-assessment)
12. [Success Metrics](#12-success-metrics)
13. [Appendices](#13-appendices)

---

## 1. Executive Summary

### Product Vision

GoCars is an innovative educational coding-puzzle game that transforms the intimidating world of programming into an engaging traffic management adventure. By combining the strategic depth of Mini Motorways with the programming-based gameplay of The Farmer Was Replaced, GoCars creates a unique learning environment where players write simplified code to control vehicles, traffic lights, and other traffic elements.

### Problem Statement

Traditional programming education often fails to engage beginners, presenting coding concepts in abstract, text-heavy formats that feel disconnected from real-world applications. Many students abandon their coding journey before grasping fundamental concepts like functions, conditionals, and loops. There exists a significant gap between "learn to code" games that oversimplify concepts and actual programming environments that overwhelm newcomers.

### Solution Overview

GoCars bridges this gap by providing a VS Code-inspired interface where players write intuitive Python-like commands to solve traffic puzzles. The game progressively introduces programming concepts through carefully designed levels, allowing players to see immediate visual feedback as their code controls vehicles navigating through realistic traffic scenarios inspired by Iloilo City, Philippines.

### Key Differentiators

- **Authentic Coding Experience:** VS Code-inspired interface familiarizes players with real development environments
- **Local Cultural Integration:** Features actual Iloilo landmarks, creating cultural relevance and pride
- **Dual Learning Paths:** Campaign mode for structured learning; Infinite mode for skill mastery
- **Immediate Visual Feedback:** Code execution visualized in real-time traffic simulation

### Success Metrics for Hackathon

- All core features functional and demonstrable on Demo Day
- Zero game-breaking bugs during 10-15 minute presentation
- Positive judge feedback across all six judging criteria
- Complete 15-level campaign with progressive difficulty

---

## 2. Product Overview

### 2.1 Basic Information

| Attribute | Details |
|-----------|---------|
| **Game Name** | GoCars |
| **Tagline** | "Code Your Way Through Traffic" |
| **Game Engine** | Godot 4.5.1 |
| **Genre** | Educational Coding-Puzzle / Traffic Simulation |
| **Platform** | PC (Windows executable) |
| **Target Audience** | Students (high school to undergraduate), beginner programmers, puzzle game enthusiasts |

### 2.2 Core Concept

GoCars teaches fundamental programming concepts through intuitive traffic control mechanics. Players interact with a simplified coding interface to control vehicles, manage traffic lights, and coordinate multi-vehicle scenarios across increasingly complex urban environments.

### 2.3 Primary Goals

1. **Educational Excellence:** Teach fundamental programming concepts (functions, conditionals, loops) through engaging gameplay
2. **Traffic Management Awareness:** Demonstrate real-world traffic management and urban planning principles
3. **Accessibility:** Create an approachable entry point to coding for non-programmers
4. **Cultural Showcase:** Feature Iloilo's landmarks and celebrate local heritage

### 2.4 SMART Objectives

| Objective | Measurement |
|-----------|-------------|
| Players complete tutorial understanding 5+ basic coding functions | Post-tutorial assessment or level completion rate |
| Campaign mode teaches progressive difficulty across 15 levels | Level completion analytics |
| Infinite mode provides replayability with score-based challenges | Session replay rate and high score distribution |
| All core features functional and bug-free by Demo Day | QA testing pass rate of 100% for critical paths |

---

## 3. Target Users and Personas

### Persona 1: The Curious Student

| Attribute | Details |
|-----------|---------|
| **Name** | Maria Santos |
| **Age** | 14-18 |
| **Background** | High school student with no coding experience |
| **Goals** | Learn programming basics in a fun, non-intimidating way |
| **Pain Points** | Traditional coding tutorials feel boring and overwhelming |
| **Motivations** | Enjoys puzzle games; curious about technology careers |
| **Success Criteria** | Completes tutorial levels; understands basic function syntax |

### Persona 2: The Aspiring Developer

| Attribute | Details |
|-----------|---------|
| **Name** | Juan Dela Cruz |
| **Age** | 18-22 |
| **Background** | College student learning to code in formal education |
| **Goals** | Practice algorithmic thinking in creative contexts |
| **Pain Points** | Wants to apply coding skills beyond homework assignments |
| **Motivations** | Seeks engaging ways to reinforce classroom learning |
| **Success Criteria** | Achieves 3-star ratings; optimizes solutions for efficiency |

### Persona 3: The Puzzle Enthusiast

| Attribute | Details |
|-----------|---------|
| **Name** | Alex Reyes |
| **Age** | 16-25 |
| **Background** | Avid strategy and puzzle game player |
| **Goals** | Find challenging gameplay with satisfying "eureka" moments |
| **Pain Points** | Many puzzle games lack depth or become repetitive |
| **Motivations** | Enjoys optimization challenges and competing with self |
| **Success Criteria** | Masters Infinite mode; achieves top leaderboard scores |

### Persona 4: The Educator

| Attribute | Details |
|-----------|---------|
| **Name** | Prof. Elena Villanueva |
| **Age** | 25-45 |
| **Background** | Teacher or instructor seeking educational tools |
| **Goals** | Find engaging, age-appropriate ways to introduce programming |
| **Pain Points** | Existing tools are either too simple or too complex |
| **Motivations** | Wants students to develop computational thinking skills |
| **Success Criteria** | Can use game as supplementary teaching material |

---

## 4. Feature Requirements

### 4.1 Core Gameplay Mechanics

#### CORE-001: Code Editor System

| Attribute | Details |
|-----------|---------|
| **Priority** | P0 (Critical) |
| **Description** | VS Code-inspired interface for writing vehicle control code |

**Components:**

**Left Panel (File Explorer):**
- Display controllable entities as .py files (car.py, stoplight.py, boat.py)
- Click to select/edit specific entity's code
- Visual indicators for active/inactive files
- Hierarchical display for multiple entities of same type

**Bottom Panel (Code Editor):**
- Text input area for writing commands
- Collapsible/expandable panel (toggle with keyboard shortcut)
- Syntax highlighting for recognized functions
- Real-time error feedback for invalid commands
- Line numbers for reference

**Main View (Game World):**
- 2D cartoon-style map visualization
- Real-time code execution visualization
- Hover highlighting for interactive elements
- Entity labels showing associated file names

**Acceptance Criteria:**
- [ ] File explorer displays all controllable entities for current level
- [ ] Code editor accepts and parses player input
- [ ] Code execution reflects immediately in game world
- [ ] Panel can be toggled open/closed via UI button or keyboard
- [ ] Syntax errors display clear, actionable error messages

---

#### CORE-002: Vehicle Control Functions

| Attribute | Details |
|-----------|---------|
| **Priority** | P0 (Critical) |
| **Description** | Complete API reference for player-accessible functions |

**Basic Movement Functions:**

```python
car.go()          # Moves car forward continuously until stopped or destination
car.stop()        # Stops car movement immediately
car.turn_left()   # Turns car 90° left at next intersection
car.turn_right()  # Turns car 90° right at next intersection
car.wait(seconds) # Pauses car for specified duration (integer seconds)
```

**Traffic Light Functions:**

```python
stoplight.set_red()    # Sets traffic light to red
stoplight.set_green()  # Sets traffic light to green
stoplight.set_yellow() # Sets traffic light to yellow (optional)
stoplight.get_state()  # Returns current light state as string
```

**Advanced Functions (Later Levels):**

```python
car.speed(value)        # Adjusts car speed (0.5 to 2.0 multiplier)
car.follow(target_car)  # Follow another car maintaining safe distance
boat.depart()           # Force boat departure regardless of capacity
boat.get_capacity()     # Returns current passenger count (integer)
```

**Conditional Helper Functions:**

```python
car.at_intersection()      # Returns True if car is at intersection
car.distance_to(dest)      # Returns distance to destination (float)
car.is_blocked()           # Returns True if path is obstructed
stoplight.is_red()         # Returns True if light is red
stoplight.is_green()       # Returns True if light is green
```

**Acceptance Criteria:**
- [ ] All basic functions execute correctly when called
- [ ] Functions return appropriate values/types
- [ ] Invalid function calls produce clear error messages
- [ ] Function parameters are validated before execution

---

#### CORE-003: Simulation Controls

| Attribute | Details |
|-----------|---------|
| **Priority** | P0 (Critical) |
| **Description** | Playback controls for code execution and simulation |

**Control Set:**

| Control | Function | Keyboard Shortcut |
|---------|----------|-------------------|
| Play | Execute code and run simulation | Space |
| Pause | Freeze simulation state | Space (toggle) |
| Fast-Forward (2x) | Double speed execution | + or = |
| Fast-Forward (4x) | Quadruple speed execution | ++ (hold) |
| Slow-Motion (0.5x) | Half speed for debugging | - |
| Fast Retry | Instant level restart | R |
| Step-by-Step | Execute one command at a time (optional) | S |

**UI Placement:** Top-center toolbar with icon buttons

**Acceptance Criteria:**
- [ ] All playback controls function as specified
- [ ] Speed changes apply smoothly without stuttering
- [ ] Fast Retry resets all entities to starting positions
- [ ] Keyboard shortcuts work when code editor is not focused

---

### 4.2 Game Modes

#### MODE-001: Campaign/Puzzle Mode

| Attribute | Details |
|-----------|---------|
| **Priority** | P0 (Critical) |
| **Description** | Story-driven progression through structured puzzle levels |

**Objectives:**
- Navigate car(s) to designated destination(s)
- Avoid collisions between vehicles
- Complete within time limit (if applicable)

**Win Condition:** All cars reach their designated destinations without crashes

**Fail Conditions:**
- Any car crashes into another vehicle or obstacle
- Timer expires before all cars reach destinations
- Car exits map boundaries

**Level Structure:**

| Set | Levels | Focus |
|-----|--------|-------|
| Tutorial | T1-T5 (5 levels) | Core mechanics introduction |
| Iloilo City | C1-C5 (5 levels) | Increasing complexity with landmarks |
| Water/Port | W1-W5 (5 levels) | Boat mechanics and timing |

**Progression System:**
- Levels unlock sequentially upon completion
- Star rating system (1-3 stars) based on performance:
  - 1 Star: Level completed
  - 2 Stars: Completed without crashes
  - 3 Stars: Completed with optimal solution/time

**Acceptance Criteria:**
- [ ] All 15 levels are playable from start to finish
- [ ] Star ratings calculate correctly based on criteria
- [ ] Level progression saves between sessions
- [ ] Win/fail states trigger appropriate UI feedback

---

#### MODE-002: Infinite/Survival Mode

| Attribute | Details |
|-----------|---------|
| **Priority** | P1 (High) |
| **Description** | Endless challenge mode with escalating difficulty |

**Objective:** Survive escalating traffic challenges as long as possible

**Lives System:**
- Starting lives: 3
- Life loss conditions:
  - Car crash: -1 life
  - Car fails to reach destination before timer: -1 life
- Game Over: All 3 lives lost

**Scoring System:**

| Action | Points |
|--------|--------|
| Successful delivery | +100 base |
| Consecutive success bonus | +10 per streak |
| Speed bonus (fast completion) | +50 max |
| No-code-edit bonus | +25 |

**Difficulty Scaling (per wave):**
- Wave 1-3: 1-2 vehicles, generous timers
- Wave 4-6: 2-3 vehicles, moderate timers
- Wave 7-10: 3-4 vehicles, tight timers
- Wave 11+: 4+ vehicles, multiple intersections, shortest timers

**Acceptance Criteria:**
- [ ] Lives system functions correctly
- [ ] Score accumulates and displays in real-time
- [ ] Difficulty scales progressively
- [ ] High scores persist locally between sessions
- [ ] Game Over screen displays final score and statistics

---

### 4.3 Level Design Specifications

#### LVL-001: Tutorial Map Set

| Attribute | Details |
|-----------|---------|
| **Priority** | P0 (Critical) |
| **Purpose** | Teach core mechanics progressively |

**Level T1: "First Drive"**
- Teaches: `car.go()`
- Layout: Straight road, single car, one destination marker
- Obstacles: None
- Solution: Single function call

**Level T2: "Stop Sign"**
- Teaches: `car.stop()`
- Layout: Road with marked stop point before destination
- Challenge: Must stop at specific location before proceeding
- Solution: Sequenced go() and stop() calls

**Level T3: "Turn Ahead"**
- Teaches: `car.turn_left()`, `car.turn_right()`
- Layout: L-shaped or T-intersection road
- Challenge: Navigate corner to reach destination
- Solution: Movement + turn combination

**Level T4: "Red Light, Green Light"**
- Teaches: `stoplight.set_red()`, `stoplight.set_green()`
- Layout: Intersection with controllable traffic light
- Challenge: Coordinate car timing with light changes
- Solution: Light control + car movement sequencing

**Level T5: "Traffic Jam" (Tutorial Finale)**
- Combines: All previous concepts
- Layout: Multiple cars, intersection with stoplight
- Challenge: Sequence multiple vehicles without collision
- Solution: Multi-entity code coordination

---

#### LVL-002: Iloilo City Map Set

| Attribute | Details |
|-----------|---------|
| **Priority** | P0 (Critical) |
| **Featured Locations** | Real Iloilo, Philippines landmarks |

**Level C1: "Jaro Cathedral Run"**
- Location: Jaro Cathedral & Plaza
- Complexity: Single car, simple intersection
- New Mechanic: None (reinforcement)

**Level C2: "Esplanade Evening"**
- Location: Iloilo Esplanade
- Complexity: Two cars requiring timing coordination
- New Mechanic: Multiple entity management

**Level C3: "SM Roundabout"**
- Location: SM City Iloilo Area
- Complexity: Roundabout navigation
- New Mechanic: Circular intersection logic

**Level C4: "Calle Real Rush Hour"**
- Location: Calle Real Heritage District
- Complexity: Multiple traffic lights, 3+ cars
- New Mechanic: Multi-stoplight coordination

**Level C5: "Molo Church Challenge"**
- Location: Molo Church & Plaza
- Complexity: Complex intersection network
- New Mechanic: All mechanics combined at scale

**Traffic Elements Available:**
- Roads (straight, curved, one-way)
- Intersections (T, 4-way, 5-way)
- Roundabouts
- Traffic lights (2-way and 4-way)
- Crosswalks (pedestrian timing considerations)
- Visual landmarks (non-interactive scenery)

---

#### LVL-003: Water/Port Map Set

| Attribute | Details |
|-----------|---------|
| **Priority** | P1 (High) |
| **Description** | Boat mechanics and water crossing challenges |

**Unique Mechanics:**

| Mechanic | Details |
|----------|---------|
| Boat Capacity | 2-3 cars per boat |
| Auto-Departure | Boat departs when full OR after 5 seconds with any passengers |
| Boat Respawn | New boat arrives 15 seconds after departure |
| Queue System | Cars wait in line for boats (FIFO) |

**Level W1: "River Crossing 101"**
- Location: Iloilo River Wharf
- Challenge: Single boat crossing, timing introduction
- Complexity: 1 car, 1 boat

**Level W2: "Ferry Queue"**
- Location: Fort San Pedro Area
- Challenge: Multiple cars, queue management
- Complexity: 3 cars, 1 boat

**Level W3: "Two-Way Traffic"**
- Location: Iloilo Fishing Port
- Challenge: Boats traveling in both directions
- Complexity: 2 boats, 4 cars

**Level W4: "Land and Sea"**
- Location: Parola Lighthouse Area
- Challenge: Mixed land routes and water crossings
- Complexity: Roads + boat integration

**Level W5: "Port Master"**
- Location: Combined River & Port
- Challenge: Full port simulation
- Complexity: Multiple boats, land intersections, 6+ cars

---

### 4.4 Vehicle System

#### VEH-001: Vehicle Collection System

| Attribute | Details |
|-----------|---------|
| **Priority** | P1 (High) |
| **Description** | Variety of controllable vehicles with unique attributes |

**Vehicle Types:**

| Vehicle | Speed | Size | Special Ability |
|---------|-------|------|-----------------|
| Sedan (Standard) | 1.0x | 1.0 unit | None |
| SUV | 0.9x | 1.2 units | None |
| Motorcycle | 1.3x | 0.5 units | Can lane split (optional) |
| Jeepney | 0.7x | 1.5 units | Carries multiple passengers |
| Truck/Van | 0.6x | 2.0 units | Longer stopping distance |
| Tricycle | 0.7x | 0.7 units | Tight turn radius |

**Random Generation Rules:**
- Vehicle type randomly assigned per level/spawn point
- Visual appearance randomized within type (color variations)
- Passenger names generated from Filipino name database

**Collections Menu Features:**
- Gallery view of all vehicle types (unlocked/locked states)
- Statistics display (speed, size, special abilities)
- Unlock progress tracking
- Vehicle lore/description text

---

#### VEH-002: Vehicle Information Display

| Attribute | Details |
|-----------|---------|
| **Priority** | P2 (Medium) |
| **Description** | Interactive vehicle information cards |

**Trigger:** Click/hover on any vehicle in game world

**Display Information:**
- Vehicle model name and thumbnail image
- Current speed/status indicator
- Passenger name (randomly generated Filipino name)
- Assigned destination (if any)
- Associated code file reference

**Visual Design:**
- Pop-up card with rounded corners
- Semi-transparent background
- Dismissible on click outside or ESC key

---

## 5. Technical Requirements

### 5.1 Technology Stack

#### TECH-001: Development Stack

| Attribute | Details |
|-----------|---------|
| **Priority** | P0 (Critical) |

| Component | Technology |
|-----------|------------|
| Game Engine | Godot 4.5.1 |
| Programming Language | GDScript |
| Target Platform | Windows PC (.exe) |
| Version Control | GitHub/GitLab (public repository) |
| Documentation | In-repo README + inline code comments |
| Build Output | Standalone .exe + .zip archive |

**Minimum System Requirements:**

| Requirement | Specification |
|-------------|---------------|
| OS | Windows 10 or later |
| RAM | 4GB minimum |
| Storage | 500MB available space |
| Graphics | Integrated graphics (Intel HD 4000+) |
| Display | 1280x720 minimum resolution |

---

### 5.2 Architecture Overview

#### TECH-002: System Architecture

| Attribute | Details |
|-----------|---------|
| **Priority** | P0 (Critical) |

**Core Systems:**

**1. Code Parser**
- Accepts simplified Python-like syntax
- Tokenizes input by line, parentheses, dots
- Validates commands against available function library
- Returns structured errors for invalid input
- Queues valid commands for sequential execution

**2. Simulation Engine**
- Executes queued commands in order
- Manages vehicle physics (position, velocity, rotation)
- Handles collision detection (vehicle-vehicle, vehicle-boundary)
- Controls traffic light state machines
- Manages timing and synchronization

**3. Level Manager**
- Loads level configurations from data files
- Spawns vehicles and traffic elements at designated positions
- Tracks win/lose condition states
- Manages scoring and star rating calculations
- Handles level transitions

**4. UI Controller**
- Renders VS Code-style interface panels
- Handles user input (keyboard, mouse)
- Updates HUD elements (score, lives, timer)
- Manages panel states (expanded/collapsed)
- Displays notifications and feedback

**5. Save System**
- Stores level completion status and star ratings
- Saves high scores for Infinite mode
- Tracks vehicle collection unlocks
- Persists user preferences/settings

---

### 5.3 Code Parser Specifications

#### TECH-003: Command Parser System

| Attribute | Details |
|-----------|---------|
| **Priority** | P0 (Critical) |

**Input Format:**
- Simplified Python-like syntax
- Line-by-line execution model
- Case-sensitive function names
- Whitespace tolerant (leading/trailing spaces ignored)

**Parsing Pipeline:**

```
Input Line → Tokenize → Identify Object → Identify Function → 
Extract Parameters → Validate → Queue/Error
```

**Parsing Steps:**
1. Read input line, trim whitespace
2. Split by dot (.) to separate object from method
3. Extract function name and parameters from parentheses
4. Validate object exists in current level context
5. Validate function exists for object type
6. Validate parameter types and ranges
7. Queue valid command OR return specific error

**Error Types and Messages:**

| Error Type | Example Message |
|------------|-----------------|
| Unknown Command | "Unknown function: car.fly() is not available" |
| Invalid Object | "Object 'truck' not found in this level" |
| Missing Parameter | "car.wait() requires a number of seconds" |
| Invalid Parameter | "car.speed(5) - value must be between 0.5 and 2.0" |
| Syntax Error | "Syntax error: missing closing parenthesis" |

**Example Valid Inputs:**

```python
car.go()
car.stop()
car.turn_left()
car.turn_right()
car.wait(3)
stoplight.set_green()
stoplight.set_red()
boat.depart()
```

---

## 6. User Interface Specifications

### 6.1 Main Menu Screen

#### UI-001: Main Menu

| Attribute | Details |
|-----------|---------|
| **Priority** | P0 (Critical) |

**Layout Description:**

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│                      [GOCARS LOGO]                          │
│                 "Code Your Way Through Traffic"             │
│                                                             │
│                      ┌──────────────┐                       │
│                      │   Campaign   │                       │
│                      └──────────────┘                       │
│                      ┌──────────────┐                       │
│                      │ Infinite Mode│                       │
│                      └──────────────┘                       │
│                      ┌──────────────┐                       │
│                      │ Collections  │                       │
│                      └──────────────┘                       │
│                      ┌──────────────┐                       │
│                      │   Settings   │                       │
│                      └──────────────┘                       │
│                      ┌──────────────┐                       │
│                      │   Credits    │                       │
│                      └──────────────┘                       │
│                      ┌──────────────┐                       │
│                      │     Exit     │                       │
│                      └──────────────┘                       │
│                                                             │
│  [Animated background: Traffic flowing through Iloilo]      │
└─────────────────────────────────────────────────────────────┘
```

**Visual Elements:**
- Game logo centered at top with subtle animation
- Menu buttons stacked vertically, centered
- Animated background showing traffic scene or Iloilo landmark
- Ambient audio: city sounds, light background music

**Sub-Menu Navigation:**
- Campaign → Level Select Grid
- Infinite Mode → Mode Start Screen with High Scores
- Collections → Vehicle Gallery Browser
- Settings → Audio, Controls, Accessibility Options
- Credits → Team and Attribution Information

---

### 6.2 Gameplay Interface

#### UI-002: In-Game HUD

| Attribute | Details |
|-----------|---------|
| **Priority** | P0 (Critical) |

**Layout Description (VS Code-Inspired):**

```
┌─────────────────────────────────────────────────────────────────────┐
│ [☰ Menu]  Level: T1 - First Drive         [♥♥♥ Lives] [⏱ 0:45]    │
├───────────┬─────────────────────────────────────────────────────────┤
│           │                                                         │
│  FILES    │                                                         │
│           │              G A M E   W O R L D                        │
│ 📄 car.py │                                                         │
│           │         [2D Map with vehicles, roads,                   │
│ 📄 stop.. │          destinations, and traffic elements]            │
│           │                                                         │
│ 📄 boat.. │                                                         │
│           │                                                         │
│           ├─────────────────────────────────────────────────────────┤
│           │  CODE EDITOR                              [▼ Collapse]  │
│           │  ┌─────────────────────────────────────────────────┐    │
│           │  │ 1 │ car.go()                                    │    │
│           │  │ 2 │ car.turn_left()                             │    │
│           │  │ 3 │ _                                           │    │
│           │  └─────────────────────────────────────────────────┘    │
│           │                                                         │
│           │  [▶ Run]  [⏸ Pause]  [⏩ 2x]  [⏩⏩ 4x]  [🔄 Retry]     │
└───────────┴─────────────────────────────────────────────────────────┘
```

**Panel Specifications:**

| Panel | Width | Function |
|-------|-------|----------|
| File Explorer | 120px fixed | Entity selection |
| Game World | Flexible (remaining) | Main gameplay view |
| Code Editor | 200px height (collapsible) | Code input area |

**Color Scheme:**
- Background: Dark gray (#1E1E1E) - VS Code dark theme
- Panel borders: Subtle gray (#3C3C3C)
- Text: Light gray (#D4D4D4)
- Syntax highlighting: Function names in blue (#569CD6), strings in orange (#CE9178)
- Interactive elements: Accent blue (#007ACC)

---

### 6.3 Level Select Screen

#### UI-003: Level Select

| Attribute | Details |
|-----------|---------|
| **Priority** | P0 (Critical) |

**Layout Description:**

```
┌─────────────────────────────────────────────────────────────┐
│  [← Back]              SELECT LEVEL                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  TUTORIAL                                                   │
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐                   │
│  │ T1  │ │ T2  │ │ T3  │ │ T4  │ │ T5  │                   │
│  │ ★★★ │ │ ★★☆ │ │ ★☆☆ │ │ 🔒  │ │ 🔒  │                   │
│  └─────┘ └─────┘ └─────┘ └─────┘ └─────┘                   │
│                                                             │
│  ILOILO CITY                                                │
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐                   │
│  │ C1  │ │ C2  │ │ C3  │ │ C4  │ │ C5  │                   │
│  │ 🔒  │ │ 🔒  │ │ 🔒  │ │ 🔒  │ │ 🔒  │                   │
│  └─────┘ └─────┘ └─────┘ └─────┘ └─────┘                   │
│                                                             │
│  WATER & PORT                                               │
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐                   │
│  │ W1  │ │ W2  │ │ W3  │ │ W4  │ │ W5  │                   │
│  │ 🔒  │ │ 🔒  │ │ 🔒  │ │ 🔒  │ │ 🔒  │                   │
│  └─────┘ └─────┘ └─────┘ └─────┘ └─────┘                   │
│                                                             │
│  Total Stars: 6/45                                          │
└─────────────────────────────────────────────────────────────┘
```

**Level Tile States:**
- Unlocked (completed): Shows star rating (★★★, ★★☆, ★☆☆)
- Unlocked (not completed): Shows level number, no stars
- Locked: Shows lock icon (🔒), grayed out

---

### 6.4 Victory/Defeat Screens

#### UI-004: Result Screens

| Attribute | Details |
|-----------|---------|
| **Priority** | P0 (Critical) |

**Victory Screen:**

```
┌─────────────────────────────────────────┐
│                                         │
│           ✓ LEVEL COMPLETE!             │
│                                         │
│              ★ ★ ★                      │
│           (3/3 Stars)                   │
│                                         │
│     Time: 0:32    Lines of Code: 4      │
│                                         │
│    ┌────────────┐  ┌────────────┐       │
│    │   Retry    │  │    Next    │       │
│    └────────────┘  └────────────┘       │
│                                         │
│         [🏠 Level Select]               │
└─────────────────────────────────────────┘
```

**Defeat Screen:**

```
┌─────────────────────────────────────────┐
│                                         │
│            ✗ LEVEL FAILED               │
│                                         │
│         [Reason: Car crashed]           │
│                                         │
│    ┌────────────┐  ┌────────────┐       │
│    │   Retry    │  │    Skip    │       │
│    └────────────┘  └────────────┘       │
│                                         │
│         [🏠 Level Select]               │
└─────────────────────────────────────────┘
```

---

## 7. Content Requirements

### 7.1 Level Summary

| Set | Count | Levels | Status |
|-----|-------|--------|--------|
| Tutorial | 5 | T1-T5 | P0 (Critical) |
| Iloilo City | 5 | C1-C5 | P0 (Critical) |
| Water/Port | 5 | W1-W5 | P1 (High) |
| **Total** | **15** | — | — |

### 7.2 Vehicle Assets

| Vehicle | Priority | Variations Needed |
|---------|----------|-------------------|
| Sedan | P0 | 4 colors |
| SUV | P1 | 3 colors |
| Motorcycle | P1 | 3 colors |
| Jeepney | P0 | 3 designs (cultural) |
| Truck/Van | P2 | 2 colors |
| Tricycle | P1 | 2 colors |

### 7.3 Environment Assets

| Category | Assets Needed |
|----------|---------------|
| Roads | Straight, curved, intersection tiles |
| Traffic Lights | 2-way, 4-way variants |
| Landmarks | 5 Iloilo locations (stylized) |
| Water Elements | River, dock, boat |
| UI Elements | Icons, buttons, panels |

### 7.4 Audio Assets

| Category | Assets |
|----------|--------|
| Music | Main menu theme, gameplay ambient |
| SFX - Vehicles | Engine sounds, horn, crash |
| SFX - UI | Button click, success, failure |
| SFX - Environment | Traffic ambient, water sounds |

---

## 8. Non-Functional Requirements

### NFR-001: Performance Requirements

| Metric | Target |
|--------|--------|
| Level Load Time | < 5 seconds |
| Frame Rate | Stable 60 FPS on minimum spec |
| Memory Usage | < 500MB RAM |
| Executable Size | < 200MB |
| Input Latency | < 100ms response |

### NFR-002: Usability Requirements

| Metric | Target |
|--------|--------|
| Tutorial Completion Time | < 15 minutes for new players |
| Average Level Playtime | 3-10 minutes |
| Text Readability | Clear at 1080p resolution |
| Color Accessibility | All information distinguishable without color alone |
| Error Messages | Clear, actionable, non-technical language |

### NFR-003: Reliability Requirements

| Requirement | Description |
|-------------|-------------|
| Stability | No game-breaking bugs or crashes |
| Save System | Auto-save on level completion |
| Error Handling | Graceful recovery from invalid states |
| Exit | Clean exit functionality (no orphan processes) |

### NFR-004: Maintainability Requirements

| Requirement | Description |
|-------------|-------------|
| Code Documentation | Inline comments for complex logic |
| Project Structure | Organized folder hierarchy |
| Version Control | Regular commits with descriptive messages |
| README | Setup and build instructions included |

---

## 9. User Stories

### US-001: Basic Movement

**As a** player  
**I want to** write `car.go()` and see the car move forward  
**So that** I can learn the basic coding mechanic

**Acceptance Criteria:**
- [ ] Typing `car.go()` in editor is recognized as valid
- [ ] Pressing Run executes the command
- [ ] Car moves forward continuously in game world
- [ ] Movement is visually smooth and clear

---

### US-002: Level Completion

**As a** player  
**I want to** see a success screen when my car reaches the destination  
**So that** I know I solved the puzzle correctly

**Acceptance Criteria:**
- [ ] Victory UI appears upon reaching destination
- [ ] Star rating displays based on performance
- [ ] Next level button unlocks and functions
- [ ] Progress saves automatically

---

### US-003: Code Editing and Retry

**As a** player  
**I want to** edit my code and retry the level quickly  
**So that** I can iterate on my solution without frustration

**Acceptance Criteria:**
- [ ] Code persists in editor after failure
- [ ] Fast Retry (R key) resets level instantly
- [ ] Previous code remains editable
- [ ] No loading screen between retries

---

### US-004: Error Feedback

**As a** beginner  
**I want to** see clear error messages when my code is wrong  
**So that** I can understand and fix my mistakes

**Acceptance Criteria:**
- [ ] Invalid syntax shows specific error message
- [ ] Error indicates line number or location
- [ ] Message uses non-technical, helpful language
- [ ] Error clears when code is corrected

---

### US-005: Infinite Mode Challenge

**As a** player  
**I want to** see my score increase as I successfully route cars  
**So that** I feel rewarded for my traffic management skills

**Acceptance Criteria:**
- [ ] Score displays prominently during gameplay
- [ ] Points awarded for successful deliveries
- [ ] Combo/streak bonuses function correctly
- [ ] High score persists between sessions

---

### US-006: Vehicle Collection

**As a** player  
**I want to** view all the vehicles I've encountered in a gallery  
**So that** I can appreciate the variety and track my progress

**Acceptance Criteria:**
- [ ] Collections menu accessible from main menu
- [ ] Vehicles display with stats and descriptions
- [ ] Locked/unlocked states clearly indicated
- [ ] New unlock notifications appear in-game

---

### US-007: Traffic Light Coordination

**As a** student  
**I want to** understand how traffic lights coordinate intersection flow  
**So that** I learn real-world traffic management concepts

**Acceptance Criteria:**
- [ ] Tutorial explains traffic light timing concepts
- [ ] Levels require proper light coordination to solve
- [ ] Visual feedback shows light state changes
- [ ] Connection between code and real-world traffic is clear

---

### US-008: Pause and Resume

**As a** player  
**I want to** pause the simulation at any time  
**So that** I can think through my next steps without pressure

**Acceptance Criteria:**
- [ ] Space bar pauses/resumes simulation
- [ ] Pause state is clearly indicated visually
- [ ] Code can be edited while paused
- [ ] Game state preserved during pause

---

## 10. Development Roadmap

### Timeline Overview

**Total Duration:** 40 days (December 15, 2025 – January 24, 2026)

```
Dec 15 ──────────────────────────────────────────────────── Jan 24
   │ Phase 1 │ Phase 2 │   Phase 3   │ Phase 4 │ Phase 5 │ Demo
   │ (7 days)│ (9 days)│  (10 days)  │ (8 days)│ (5 days)│ Day
   └─────────┴─────────┴─────────────┴─────────┴─────────┴──────
```

---

### Phase 1: Foundation (December 15-22) — 7 Days

**Objectives:**
- Establish project infrastructure
- Implement core architecture
- Create basic prototype

**Deliverables:**

| Task | Owner | Duration |
|------|-------|----------|
| Project setup and repository creation | — | Day 1 |
| Core scene structure in Godot | — | Days 1-2 |
| Basic code parser prototype | — | Days 2-4 |
| Simple vehicle movement system | — | Days 4-6 |
| Basic collision detection | — | Days 6-7 |

**Milestone:** Car moves forward based on `car.go()` code input

---

### Phase 2: Core Mechanics (December 23-31) — 9 Days

**Objectives:**
- Complete function library
- Implement traffic systems
- Build playback controls

**Deliverables:**

| Task | Owner | Duration |
|------|-------|----------|
| Complete basic function set | — | Days 1-3 |
| Traffic light system | — | Days 3-5 |
| Turn mechanics at intersections | — | Days 4-6 |
| Playback controls (play/pause/speed) | — | Days 6-7 |
| Win/lose condition detection | — | Days 7-9 |

**Milestone:** Full gameplay loop functional with all basic mechanics

---

### Phase 3: Content Creation (January 1-10) — 10 Days

**Objectives:**
- Build all 15 campaign levels
- Implement boat/water mechanics
- Create vehicle variety

**Deliverables:**

| Task | Owner | Duration |
|------|-------|----------|
| Tutorial levels (T1-T5) | — | Days 1-3 |
| Iloilo City levels (C1-C5) | — | Days 3-6 |
| Boat mechanics implementation | — | Days 5-7 |
| Water levels (W1-W5) | — | Days 7-9 |
| Vehicle types and generation | — | Days 8-10 |

**Milestone:** All 15 campaign levels playable

---

### Phase 4: Polish & UI (January 11-18) — 8 Days

**Objectives:**
- Implement VS Code-style interface
- Build all menu systems
- Add Infinite mode

**Deliverables:**

| Task | Owner | Duration |
|------|-------|----------|
| VS Code-style interface implementation | — | Days 1-3 |
| Main menu and navigation | — | Days 3-4 |
| Level select and progression UI | — | Days 4-5 |
| Collections system | — | Days 5-6 |
| Infinite mode implementation | — | Days 6-8 |

**Milestone:** Complete game with all modes and polished UI

---

### Phase 5: Testing & Submission (January 19-23) — 5 Days

**Objectives:**
- Fix all critical bugs
- Optimize performance
- Prepare submission

**Deliverables:**

| Task | Owner | Duration |
|------|-------|----------|
| Comprehensive bug testing | — | Days 1-2 |
| Performance optimization | — | Days 2-3 |
| Final polish and balance | — | Days 3-4 |
| Build generation (.exe) | — | Day 4 |
| Documentation and submission | — | Day 5 |

**Milestone:** Submission-ready build uploaded

---

### Demo Day: January 24, 2026

| Activity | Duration |
|----------|----------|
| Presentation | 10-15 minutes |
| Live demonstration | (within presentation) |
| Q&A | 2 minutes |

---

## 11. Risk Assessment

### Risk Matrix

| Risk | Probability | Impact | Risk Score |
|------|-------------|--------|------------|
| Code parser complexity | High | High | Critical |
| Scope creep | Medium | High | High |
| Art asset delays | Medium | Medium | Medium |
| Integration issues | Medium | High | High |
| Performance problems | Low | Medium | Low |
| Team coordination | Medium | Medium | Medium |

---

### Risk Details and Mitigation

#### Risk 1: Code Parser Complexity

| Attribute | Details |
|-----------|---------|
| **Description** | Building a robust code parser may be more complex than estimated |
| **Probability** | High |
| **Impact** | High |
| **Mitigation** | Start with minimal function set (go, stop, turn); expand only after core works; use established parsing patterns |
| **Contingency** | Simplify syntax further if needed; reduce function variety |

#### Risk 2: Scope Creep

| Attribute | Details |
|-----------|---------|
| **Description** | Adding features beyond original specification |
| **Probability** | Medium |
| **Impact** | High |
| **Mitigation** | Strict adherence to MVP definition; feature freeze after Phase 3 |
| **Contingency** | Cut non-essential features (see MVP Definition below) |

#### Risk 3: Art Asset Delays

| Attribute | Details |
|-----------|---------|
| **Description** | Visual assets not ready when needed for integration |
| **Probability** | Medium |
| **Impact** | Medium |
| **Mitigation** | Use placeholder assets early; parallelize art and code work |
| **Contingency** | Use simple geometric shapes; reduce visual complexity |

#### Risk 4: Integration Issues

| Attribute | Details |
|-----------|---------|
| **Description** | Systems don't work together as expected |
| **Probability** | Medium |
| **Impact** | High |
| **Mitigation** | Daily builds; continuous integration testing; clear interfaces |
| **Contingency** | Simplify system interactions; reduce feature interdependence |

#### Risk 5: Performance Problems

| Attribute | Details |
|-----------|---------|
| **Description** | Game runs poorly on target hardware |
| **Probability** | Low |
| **Impact** | Medium |
| **Mitigation** | Test on minimum spec hardware early; profile regularly |
| **Contingency** | Reduce visual effects; optimize critical paths |

#### Risk 6: Team Coordination

| Attribute | Details |
|-----------|---------|
| **Description** | Miscommunication or conflicting work |
| **Probability** | Medium |
| **Impact** | Medium |
| **Mitigation** | Daily standups; clear task assignments; shared documentation |
| **Contingency** | Pair programming for critical features; more frequent check-ins |

---

### MVP Definition (Contingency Scope)

**If time runs short, PRIORITIZE:**

| Priority | Feature | Minimum Viable |
|----------|---------|----------------|
| 1 | Tutorial Levels | 3 levels minimum |
| 2 | Campaign Mode | 5 total levels minimum |
| 3 | Core Functions | go, stop, turn, stoplight basics only |
| 4 | Vehicle Types | 3 types minimum |
| 5 | Basic UI | Functional, not polished |

**CUT if necessary:**

| Feature | Reason |
|---------|--------|
| Infinite Mode | Can mention as "coming soon" |
| Collections Gallery | Nice-to-have, not core |
| Water Levels/Boat Mechanics | Complex, can be future content |
| Advanced Functions | Not needed for core gameplay |
| Sound Effects | Can use minimal audio |

---

## 12. Success Metrics

### 12.1 Hackathon Success Criteria

| Criterion | Target | Measurement |
|-----------|--------|-------------|
| Core Features Functional | 100% of P0 features working | Demo Day checklist |
| Bug-Free Presentation | Zero crashes during demo | Live demonstration |
| Positive Judge Feedback | Above-average scores in all criteria | Judge scoring |
| Complete Demonstration | Full 10-minute demo without issues | Presentation completion |

---

### 12.2 Judging Criteria Alignment

| Criterion (Weight) | How GoCars Addresses It |
|--------------------|-------------------------|
| **Originality & Creativity (20%)** | Unique blend of coding education + traffic simulation; VS Code-inspired interface; local cultural integration |
| **Functionality & Mechanics (20%)** | Intuitive code → action feedback loop; progressive difficulty; dual game modes |
| **Technical Implementation (20%)** | Custom code parser; efficient simulation engine; clean architecture |
| **Design & Presentation (20%)** | Professional VS Code aesthetic; consistent visual language; polished UI |
| **Completeness & Polish (10%)** | 15 complete levels; full gameplay loop; minimal bugs |
| **Educational/Practical Impact (10%)** | Teaches real programming concepts; demonstrates traffic management principles; accessible to beginners |

---

### 12.3 Educational Effectiveness Indicators

| Indicator | Target | How Measured |
|-----------|--------|--------------|
| Function Comprehension | Players understand 5+ functions after tutorial | Tutorial completion rate |
| Concept Application | Players can solve puzzles without hints | Level completion without skip |
| Code-to-Action Connection | Players see immediate visual feedback | User observation/feedback |
| Progressive Mastery | Players improve over time | Star rating progression |

---

### 12.4 Technical Quality Indicators

| Indicator | Target |
|-----------|--------|
| Code Documentation | All complex functions documented |
| Repository Cleanliness | Organized structure, no dead code |
| Build Stability | Consistent builds across machines |
| Performance | Stable 60 FPS on demo hardware |

---

## 13. Appendices

### Appendix A: Complete Function Reference

#### Basic Movement Functions

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `car.go()` | None | None | Starts continuous forward movement |
| `car.stop()` | None | None | Stops all movement immediately |
| `car.turn_left()` | None | None | Queues 90° left turn at next intersection |
| `car.turn_right()` | None | None | Queues 90° right turn at next intersection |
| `car.wait(n)` | n: integer seconds | None | Pauses movement for n seconds |

#### Traffic Light Functions

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `stoplight.set_red()` | None | None | Changes light to red |
| `stoplight.set_green()` | None | None | Changes light to green |
| `stoplight.set_yellow()` | None | None | Changes light to yellow |
| `stoplight.get_state()` | None | string | Returns "red", "green", or "yellow" |

#### Advanced Functions

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `car.speed(v)` | v: float (0.5-2.0) | None | Sets speed multiplier |
| `car.follow(target)` | target: car reference | None | Follows specified car |
| `boat.depart()` | None | None | Forces immediate departure |
| `boat.get_capacity()` | None | integer | Returns current passenger count |

#### Conditional Helpers

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `car.at_intersection()` | None | boolean | True if at intersection |
| `car.distance_to(dest)` | dest: destination | float | Distance in units |
| `car.is_blocked()` | None | boolean | True if path obstructed |

---

### Appendix B: Level Design Template

```
Level ID: [SET]-[NUMBER] (e.g., T1, C3, W5)
Level Name: "[Descriptive Name]"
Location: [Real-world location or "Generic"]

OBJECTIVES:
- Primary: [Main goal]
- Secondary: [Optional challenges]

LAYOUT:
- Map Size: [Width x Height in tiles]
- Road Configuration: [Description]
- Intersections: [Count and types]

ENTITIES:
- Cars: [Count] - Spawn points: [Coordinates]
- Stoplights: [Count] - Positions: [Coordinates]
- Destinations: [Count] - Positions: [Coordinates]

AVAILABLE FUNCTIONS:
- [List of unlocked functions for this level]

WIN CONDITIONS:
- [Specific requirements]

FAIL CONDITIONS:
- [Specific failure triggers]

STAR CRITERIA:
- 1 Star: [Requirement]
- 2 Stars: [Requirement]
- 3 Stars: [Requirement]

HINTS:
- Hint 1: [First hint text]
- Hint 2: [Second hint text]

OPTIMAL SOLUTION:
[Code example - for internal reference only]
```

---

### Appendix C: Asset Checklist

#### Vehicles (Sprites)

- [ ] Sedan (4 color variants)
- [ ] SUV (3 color variants)
- [ ] Motorcycle (3 color variants)
- [ ] Jeepney (3 design variants)
- [ ] Truck (2 color variants)
- [ ] Tricycle (2 color variants)
- [ ] Boat (2 variants)

#### Environment (Tiles)

- [ ] Road - Straight (horizontal/vertical)
- [ ] Road - Curved (4 directions)
- [ ] Road - T-Intersection (4 orientations)
- [ ] Road - 4-Way Intersection
- [ ] Road - Roundabout
- [ ] Grass/Ground tile
- [ ] Water tile
- [ ] Dock/Pier tile

#### Traffic Elements

- [ ] Traffic Light - 2-way
- [ ] Traffic Light - 4-way
- [ ] Destination marker
- [ ] Spawn point marker
- [ ] Stop line

#### Landmarks (Decorative)

- [ ] Jaro Cathedral
- [ ] Iloilo Esplanade
- [ ] SM City Iloilo
- [ ] Calle Real Buildings
- [ ] Molo Church

#### UI Elements

- [ ] Game logo
- [ ] Menu buttons (normal/hover/pressed)
- [ ] Panel backgrounds
- [ ] File icons (.py files)
- [ ] Playback control icons
- [ ] Star icons (filled/empty)
- [ ] Lock icon
- [ ] Life/heart icon

#### Audio

- [ ] Main menu music
- [ ] Gameplay ambient music
- [ ] Engine sound (loop)
- [ ] Crash sound effect
- [ ] Success sound effect
- [ ] Failure sound effect
- [ ] Button click sound
- [ ] Level complete fanfare

---

### Appendix D: Team Roles Template

| Role | Responsibilities | Team Member |
|------|------------------|-------------|
| **Project Lead** | Overall coordination, scope management, presentations | [Name] |
| **Lead Programmer** | Core systems, code parser, simulation engine | [Name] |
| **Gameplay Programmer** | Level logic, UI systems, save system | [Name] |
| **Artist/Designer** | Visual assets, UI design, animations | [Name] |
| **Level Designer/QA** | Level creation, testing, balance | [Name] |

---

### Appendix E: Repository Structure

```
GoCars/
├── README.md
├── LICENSE
├── project.godot
├── assets/
│   ├── sprites/
│   │   ├── vehicles/
│   │   ├── environment/
│   │   └── ui/
│   ├── audio/
│   │   ├── music/
│   │   └── sfx/
│   └── fonts/
├── scenes/
│   ├── main_menu.tscn
│   ├── gameplay.tscn
│   ├── level_select.tscn
│   └── levels/
│       ├── tutorial/
│       ├── iloilo/
│       └── water/
├── scripts/
│   ├── core/
│   │   ├── code_parser.gd
│   │   ├── simulation_engine.gd
│   │   └── level_manager.gd
│   ├── entities/
│   │   ├── vehicle.gd
│   │   ├── stoplight.gd
│   │   └── boat.gd
│   ├── ui/
│   │   ├── code_editor.gd
│   │   ├── file_explorer.gd
│   │   └── hud.gd
│   └── systems/
│       ├── save_manager.gd
│       └── score_manager.gd
├── data/
│   ├── levels/
│   └── vehicles.json
└── docs/
	├── PRD.md
	└── CONTRIBUTING.md
```

---

## Document Control

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | January 2026 | [Team Name] | Initial release |

---

**End of Document**
