FranchiseManager/
├── App/
│   ├── FranchiseManagerApp.swift
│   └── ContentView.swift
├── Core/
│   ├── Models/
│   │   ├── League/
│   │   │   ├── League.swift
│   │   │   ├── Team.swift
│   │   │   └── Season.swift
│   │   ├── Player/
│   │   │   ├── Player.swift
│   │   │   ├── SkaterAttributes.swift
│   │   │   ├── GoalieAttributes.swift
│   │   │   └── Contract.swift
│   │   ├── Game/
│   │   │   ├── Game.swift
│   │   │   ├── GameResult.swift
│   │   │   └── PlayerStats.swift
│   │   └── SaveGame/
│   │       └── SavedGame.swift
│   ├── Managers/
│   │   ├── GameSimulation/
│   │   │   ├── AdvanceDayManager.swift
│   │   │   ├── GameSimulator.swift
│   │   │   └── LineupManager.swift
│   │   ├── SaveLoad/
│   │   │   ├── SaveGameManager.swift
│   │   │   └── FileManager+Extensions.swift
│   │   └── Calendar/
│   │       ├── CalendarManager.swift
│   │       └── ScheduleManager.swift
│   └── Utils/
│       ├── Extensions/
│       │   ├── Color+Extensions.swift
│       │   └── Date+Extensions.swift
│       ├── Constants/
│       │   ├── GameConstants.swift
│       │   └── UIConstants.swift
│       └── Helpers/
│           ├── StatisticsHelper.swift
│           └── ValidationHelper.swift
├── Features/
│   ├── Home/
│   │   └── HomeView.swift
│   ├── Game/
│   │   ├── MainGameView.swift
│   │   ├── RosterView.swift
│   │   ├── LinesView.swift
│   │   └── CalendarView.swift
│   ├── Trades/
│   │   └── TradesView.swift
│   └── LoadGame/
│       └── LoadAGameView.swift
├── Resources/
│   ├── Documentation/
│   │   ├── cli_advance_day.md
│   │   ├── claude_cli_instructions.md
│   │   └── PlayerAttributes.rtf
│   └── TestScripts/
│       ├── test_complete_workflow.swift
│       ├── test_loadview.swift
│       └── test_documents_save_load.swift
└── Supporting Files/
    ├── Info.plist
    └── .claude/
        └── settings.local.json
