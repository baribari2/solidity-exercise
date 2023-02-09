//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Levels {
    ////////////////////////////////////////////////////////
    ////                 COOLDOWNS                      ////
    ////////////////////////////////////////////////////////
    uint256 constant FIREBALL_COOLDOWN = 1 days;
    uint256 constant ICE_SPELL_COOLDOWN = 2 days;
    uint256 constant RICIN_COOLDOWN = 5 days;

    ////////////////////////////////////////////////////////
    ////                  DAMAGE                        ////
    ////////////////////////////////////////////////////////
    uint256 constant LEVEL_1_DAMAGE = 10;
    uint256 constant LEVEL_2_DAMAGE = 20;
    uint256 constant LEVEL_3_DAMAGE = 30;
    uint256 constant LEVEL_4_DAMAGE = 40;
    uint256 constant LEVEL_5_DAMAGE = 50;
    uint256 constant LEVEL_6_DAMAGE = 60;
    uint256 constant LEVEL_7_DAMAGE = 70;
    uint256 constant LEVEL_8_DAMAGE = 80;
    uint256 constant LEVEL_9_DAMAGE = 90;
    uint256 constant MAX_DAMAGE = 100;
    uint256 constant FIREBALL_DAMAGE = 35;
    uint256 constant ICE_SPELL_DAMAGE = 65;
    /// @notice please don't use ricin in real life lmao
    uint256 constant RICIN_DAMAGE = 130;

    ////////////////////////////////////////////////////////
    ////              LEVEL THRESHOLDS                  ////
    ////////////////////////////////////////////////////////
    uint256 constant LEVEL_1_XP = 0;
    uint256 constant LEVEL_2_XP = 200;
    uint256 constant LEVEL_3_XP = 300;
    uint256 constant LEVEL_4_XP = 400;
    uint256 constant LEVEL_5_XP = 500;
    uint256 constant LEVEL_6_XP = 600;
    uint256 constant LEVEL_7_XP = 700;
    uint256 constant LEVEL_8_XP = 800;
    uint256 constant LEVEL_9_XP = 900;

    /// @notice Checks whether or not a user can level up
    /// @param xp The xp of the user
    function checkLevelUp(uint256 xp) internal pure returns(uint256) {
        if (xp >= LEVEL_1_XP) {
            return(1);
        } else if (xp >= LEVEL_2_XP) {
            return(2);
        } else if (xp >= LEVEL_3_XP) {
            return(3);
        } else if (xp >= LEVEL_4_XP) {
            return(4);
        } else if (xp >= LEVEL_5_XP) {
            return(5);
        } else if (xp >= LEVEL_6_XP) {
            return(6);
        } else if (xp >= LEVEL_7_XP) {
            return(7);
        } else if (xp >= LEVEL_8_XP) {
            return(8);
        } else if (xp >= LEVEL_9_XP) {
            return(9);
        } else if (xp >= MAX_DAMAGE) {
            return(10);
        } else {
            revert("Levels: Invalid XP");
        }

    }

    /// @notice Checks whether or not a user can level down
    /// @param xp The xp of the user
    function checkLevelDown(uint256 xp) internal pure returns(uint256) {
        if (xp < LEVEL_1_XP) {
            return(0);
        } else if (xp < LEVEL_2_XP) {
            return(1);
        } else if (xp < LEVEL_3_XP) {
            return(2);
        } else if (xp < LEVEL_4_XP) {
            return(3);
        } else if (xp < LEVEL_5_XP) {
            return(4);
        } else if (xp < LEVEL_6_XP) {
            return(5);
        } else if (xp < LEVEL_7_XP) {
            return(6);
        } else if (xp < LEVEL_8_XP) {
            return(7);
        } else if (xp < LEVEL_9_XP) {
            return(8);
        } else if (xp < MAX_DAMAGE) {
            return(9);
        } else {
            revert("Levels: Invalid XP");
        }
    }

    /// @notice Returns the amount of damage a character can do
    /// @param level The level of the characher
    function getLevelDamage(uint256 level) internal view returns(uint256) {
        if (level == 1) {
            return LEVEL_1_DAMAGE;
        } else if (level == 2) {
            return LEVEL_2_DAMAGE;
        } else if (level == 3) {
            return LEVEL_3_DAMAGE;
        } else if (level == 4) {
            return LEVEL_4_DAMAGE;
        } else if (level == 5) {
            return LEVEL_5_DAMAGE;
        } else if (level == 6) {
            return LEVEL_6_DAMAGE;
        } else if (level == 7) {
            return LEVEL_7_DAMAGE;
        } else if (level == 8) {
            return LEVEL_8_DAMAGE;
        } else if (level == 9) {
            return LEVEL_9_DAMAGE;
        } else {
            return MAX_DAMAGE;
        }
    }
}