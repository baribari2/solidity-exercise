//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Levels} from "./Levels.sol";

struct Boss {
    address creator;
    string name;
    uint256 healthPoints;
    uint256 reward;
    bool defeated;
}

struct Character {
    address creator;
    string name;
    uint256 healthPoints;
    uint256 xp;
    uint256 level;
    uint256 lastFireball;
}

contract Game is Ownable, Levels {
    error CharacterDead(address character);

    Boss public currentBoss;
    
    mapping(address => Character) public characters;
    mapping(address => bool) public deadCharacters;
    mapping(address => uint256) public rewards;
    mapping(address => bool) public attackers;
    address[] public attackersList;
    address[] public deadCharactersList;

    modifier onlyCharacterOwners() {
        require(characters[msg.sender].creator == msg.sender, "Game: Not the owner of this character");
        _;
    }

    constructor() {
        currentBoss.defeated = true;
    }

    /// @notice Returns the current boss
    function getCurrentBoss() external view returns (Boss memory) {
        return currentBoss;
    }

    /// @notice Returns the character of the given address
    /// @param character The address of the character
    function getCharacter(address character) external view returns (Character memory) {
        return characters[character];
    }

    /// @notice Returns the rewards of the given character
    /// @param character The address of the character
    function getCharacterRewards(address character) external view returns (uint256) {
        return rewards[character];
    }

    /// @notice Returns the list of attackers
    function getCurrentAttackers() external view returns (address[] memory) {
        return attackersList;
    }

    /// @notice Returns the list of dead characters
    function getDeadCharacters() external view returns (address[] memory) {
        return deadCharactersList;
    }

    /// @notice Allows an admin to create a boss
    /// @dev Only one boss can fight at a time, so if the current boss is not defeated, this function will fail
    /// @param boss The Boss to create
    function newBoss(Boss memory boss) public onlyOwner returns (Boss memory) {
        require(currentBoss.defeated == true, "Game: Current boss is not defeated");
        require(bytes(boss.name).length > 0, "Game: Boss name cannot be empty");
        require(boss.healthPoints > 0, "Game: Boss health points must be greater than 0");
        require(boss.reward > 0, "Game: Boss reward must be greater than 0");

        
        boss.defeated = false;
        boss.creator = msg.sender;

        currentBoss = boss;

        return(currentBoss);
    }

    /// @notice Allows a user to create a character
    /// @dev Only one character per address is allowed
    /// @param name The name of the character
    function newCharacter(string memory name) public returns(Character memory) {
        require(characters[msg.sender].creator == address(0), "Game: Only one character allowed per address");
        require(bytes(name).length > 0, "Game: Character name cannot be empty");

        characters[msg.sender] = Character({
            creator: msg.sender,
            name: name,
            healthPoints: 100,
            xp: 0,
            level: 1,
            lastFireball: 0
        });

        return(characters[msg.sender]);
    }

    /// @notice Allows a user to attack the boss
    /// @dev The user must be the owner of the character, the character must be alive, and the boss must not be defeated
    function attackBoss() public onlyCharacterOwners {
        require(msg.sender == characters[msg.sender].creator, "Game: Not the owner of this character");
        require(deadCharacters[msg.sender] == false, "Game: Character is dead");
        require(currentBoss.defeated == false, "Game: Boss is already defeated");

        Character storage char = characters[msg.sender];

        if (attackers[msg.sender] == false) {
            attackers[msg.sender] = true;
            attackersList.push(msg.sender);
        }

        uint256 damage = getLevelDamage(char.level);

        // Attack the boss
        currentBoss.healthPoints -= damage;

        // Boss conunterattack
        counterattackCharacter(char.creator, damage);

        // Credit XP to character for the attack
        rewards[msg.sender] += 10;

        // If the user can level up, change the level
        uint256 lev = checkLevelUp(char.xp);
        if (lev != char.level) {
            char.level = lev;
        }

        // Check if boss is defeated
        if (currentBoss.healthPoints <= 0) {
            uint256 i = 0;

            currentBoss.defeated = true;
            rewards[msg.sender] += currentBoss.reward;

            for (i; i < attackersList.length; i++) {
                delete attackers[attackersList[i]];
            }

            delete attackersList;

            for (i = 0; i < deadCharactersList.length; i++) {
                delete deadCharacters[deadCharactersList[i]];
            }

            delete deadCharactersList;
        }

        // Check if character is dead
        if (char.healthPoints <= 0) {
            deadCharacters[msg.sender] = true;
            deadCharactersList.push(msg.sender);
            if (char.xp > 20) {
                char.xp -= 20;

                uint256 lev = checkLevelDown(char.xp);
                if (lev != char.level) {
                    char.level = lev;
                }
            } else {
                char.xp = 0;
            }
        }

        // Update character
        characters[msg.sender] = char;
    }

    /// @notice Allows a user to attack the boss with a fireball
    /// @dev The user must be at or above level 2 to use a fireball
    function attackBossWithFireball() public {
        require(msg.sender == characters[msg.sender].creator, "Game: Not the owner of this character");
        require(deadCharacters[msg.sender] == true, "Character is dead");
        require(currentBoss.defeated == false, "Boss is already defeated");
        
        Character storage char = characters[msg.sender];

        require(char.lastFireball + FIREBALL_COOLDOWN > block.timestamp, "Game: Fireball is on cooldown");
        require(char.level >= 2, "Game: Character is not high enough level to use this attack");

        if (attackers[msg.sender] == false) {
            attackers[msg.sender] = true;
            attackersList.push(msg.sender);
        }

        // Attack the boss
        currentBoss.healthPoints -= FIREBALL_DAMAGE;

        // Boss conunterattack
        counterattackCharacter(char.creator, FIREBALL_DAMAGE);

        // Credit XP to character for the attack
        rewards[msg.sender] += 10;

        // If the user can level up, change the level
        uint256 lev = checkLevelUp(char.xp);
        if (lev != char.level) {
            char.level = lev;
        }

        // Check if boss is defeated
        if (currentBoss.healthPoints <= 0) {
            uint256 i = 0;

            currentBoss.defeated = true;
            rewards[msg.sender] += currentBoss.reward;

            for (i; i < attackersList.length; i++) {
                delete attackers[attackersList[i]];
            }

            delete attackersList;

            for (i = 0; i < deadCharactersList.length; i++) {
                delete deadCharacters[deadCharactersList[i]];
            }

            delete deadCharactersList;
        }

        // Check if character is dead
        if (char.healthPoints <= 0) {
            deadCharacters[msg.sender] = true;
            deadCharactersList.push(msg.sender);
            if (char.xp > 20) {
                char.xp -= 20;
            } else {
                char.xp = 0;
            }
        }

        // Update character
        characters[msg.sender] = char;
    }

    /// @notice Allows a user to attack the boss with an ice spell
    /// @dev The user must be at or above level 5 to use an ice spell
    function attackBossWithIceSpell() public {
        require(msg.sender == characters[msg.sender].creator, "Game: Not the owner of this character");
        require(deadCharacters[msg.sender] == true, "Game: Character is dead");
        require(currentBoss.defeated == false, "Game: Boss is already defeated");
        
        Character storage char = characters[msg.sender];

        require(char.lastFireball + ICE_SPELL_COOLDOWN > block.timestamp, "Game: Fireball is on cooldown");
        require(char.level >= 5, "Game: Character is not high enough level to use this attack");

        if (attackers[msg.sender] == false) {
            attackers[msg.sender] = true;
            attackersList.push(msg.sender);
        }

        // Attack the boss
        currentBoss.healthPoints -= ICE_SPELL_DAMAGE;

        // Boss conunterattack
        counterattackCharacter(char.creator, ICE_SPELL_DAMAGE);

        // Credit XP to character for the attack
        rewards[msg.sender] += 10;

        // If the user can level up, change the level
        uint256 lev = checkLevelUp(char.xp);
        if (lev != char.level) {
            char.level = lev;
        }

        // Check if boss is defeated
        if (currentBoss.healthPoints <= 0) {
            uint256 i = 0;

            currentBoss.defeated = true;
            rewards[msg.sender] += currentBoss.reward;

            for (i; i < attackersList.length; i++) {
                delete attackers[attackersList[i]];
            }

            delete attackersList;

            for (i = 0; i < deadCharactersList.length; i++) {
                delete deadCharacters[deadCharactersList[i]];
            }

            delete deadCharactersList;
        }

        // Check if character is dead
        if (char.healthPoints <= 0) {
            deadCharacters[msg.sender] = true;
            deadCharactersList.push(msg.sender);
            if (char.xp > 20) {
                char.xp -= 20;
            } else {
                char.xp = 0;
            }
        }

        // Update character
        characters[msg.sender] = char;
    }

    /// @notice Allows a user to attack the boss with ricin
    /// @dev The user must be at or above level 8 to use ricin
    function attackBossWithRicin() public {
        require(msg.sender == characters[msg.sender].creator, "Game: Not the owner of this character");
        require(deadCharacters[msg.sender] == true, "Game: Character is dead");
        require(currentBoss.defeated == false, "Game: Boss is already defeated");
        
        Character storage char = characters[msg.sender];

        require(char.lastFireball + RICIN_COOLDOWN > block.timestamp, "Game: Fireball is on cooldown");
        require(char.level >= 8, "Game: Character is not high enough level to use this attack");

        if (attackers[msg.sender] == false) {
            attackers[msg.sender] = true;
            attackersList.push(msg.sender);
        }

        // Attack the boss
        currentBoss.healthPoints -= RICIN_DAMAGE;

        // Boss conunterattack
        counterattackCharacter(char.creator, RICIN_DAMAGE);

        // Credit XP to character for the attack
        rewards[msg.sender] += 10;

        // If the user can level up, change the level
        uint256 lev = checkLevelUp(char.xp);
        if (lev != char.level) {
            char.level = lev;
        }

        // Check if boss is defeated
        if (currentBoss.healthPoints <= 0) {
            uint256 i = 0;

            currentBoss.defeated = true;
            rewards[msg.sender] += currentBoss.reward;

            for (i; i < attackersList.length; i++) {
                delete attackers[attackersList[i]];
            }

            delete attackersList;

            for (i = 0; i < deadCharactersList.length; i++) {
                delete deadCharacters[deadCharactersList[i]];
            }

            delete deadCharactersList;
        }

        // Check if character is dead
        if (char.healthPoints <= 0) {
            deadCharacters[msg.sender] = true;
            deadCharactersList.push(msg.sender);
            if (char.xp > 20) {
                char.xp -= 20;
            } else {
                char.xp = 0;
            }
        }

        // Update character
        characters[msg.sender] = char;
    }

    ///@notice An attack executed by the boss everytime it is attacked
    /// @param character The address of the character that attacked the boss
    /// @param damageDone The amount of damage the boss took
    function counterattackCharacter(address character, uint256 damageDone) internal {
        if (damageDone * 2 >= characters[character].healthPoints) {
            characters[character].healthPoints = 0;

            return;
        }

        characters[character].healthPoints -= damageDone * 2;
    }

    /// @notice Allows a user to heal another character
    /// @param doctor The address of the person healing
    /// @param patient The address of the person being healed
    function healCharacter(address doctor, address patient) public {
        require(characters[doctor].xp > 0, "Game: Doctor has no XP");
        require(doctor != patient, "Game: Doctor cannot heal themselves");
        require(deadCharacters[patient] == true, "Game: Patient is not dead");
        require(doctor == address(msg.sender), "Game: Caller is not the doctor");

        deadCharacters[patient] = false;
        characters[patient].healthPoints = 100;
    }

    ///@notice Allows a character to claim XP rewards for defeating the boss
    /// @dev XP should probably be directly updated after each attack, but per the rules XP is added on claim
    function claimRewards() public {
        require(rewards[msg.sender] > 0, "Game: No rewards to claim");

        uint256 reward = rewards[msg.sender];
        rewards[msg.sender] = 0;

        Character storage char = characters[msg.sender];
        char.xp += reward;

        uint256 lev = checkLevelUp(char.xp);
        if (lev != char.level) {
            char.level = lev;
        }

        characters[msg.sender] = char;
    }
}
