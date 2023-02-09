// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {Game, Boss, Character} from "../src/Game.sol";

contract GameTest is Test {
    Game public game;

    address public gameOwner = address(0x1234);
    address public character1 = address(0x5678);
    address public character2 = address(0x9abc);
    address public character3 = address(0xdef0);

    function setUp() public {
        vm.prank(gameOwner, gameOwner);
        game = new Game();
    }

    function testNewBoss() public {
        Boss memory boss = Boss({
            creator: gameOwner,
            name: "test",
            healthPoints: 100,
            reward: 100,
            defeated: false
        });

        vm.prank(gameOwner, gameOwner);
        game.newBoss(boss);

        assertEq(game.getCurrentBoss().creator, boss.creator);
        assertEq(game.getCurrentBoss().name, boss.name);
    }

    function testFailNewBoss() public {
        Boss memory boss = Boss({
            creator: gameOwner,
            name: "test",
            healthPoints: 100,
            reward: 100,
            defeated: false
        });

        vm.prank(address(0));
        game.newBoss(boss);

        vm.expectRevert(bytes("Ownable: caller is not the owner"));
    }

    function testNewCharacter() public {
        vm.prank(character1);
        Character memory character = game.newCharacter("testCharacter");

        assertEq(game.getCharacter(character.creator).name, character.name);
    }

    function testFailNewCharacter() public {
        vm.expectRevert(bytes("Game: Only one character allowed per address"));
        vm.startPrank(character1);

        game.newCharacter("testCharacter");
        game.newCharacter("testBadCharacter");

        vm.stopPrank();
    }

    function testAttackBoss() public {
        vm.prank(character1, character1);
        Character memory character = game.newCharacter("testCharacter");

        Boss memory boss = Boss({
            creator: gameOwner,
            name: "test",
            healthPoints: 100,
            reward: 100,
            defeated: false
        });

        vm.prank(gameOwner, gameOwner);
        game.newBoss(boss);

        vm.prank(character1, character1);
        game.attackBoss();

        assertEq(game.getCurrentBoss().healthPoints, 90);
        assertEq(game.getCharacter(character.creator).healthPoints, 80);
    }

    function testDefeatBoss() public {
        vm.prank(character1);
        Character memory character = game.newCharacter("testCharacter");

        Boss memory boss = Boss({
            creator: gameOwner,
            name: "test",
            healthPoints: 10,
            reward: 100,
            defeated: false
        });

        vm.prank(gameOwner, gameOwner);
        game.newBoss(boss);

        vm.prank(character1);
        game.attackBoss();

        assertEq(game.getCurrentBoss().healthPoints, 0);
        assertEq(game.getCurrentBoss().defeated, true);
    }

    function testFailDefeatBoss() public {
        vm.prank(character1);
        Character memory character = game.newCharacter("testCharacter");

        Boss memory boss = Boss({
            creator: gameOwner,
            name: "test",
            healthPoints: 10,
            reward: 100,
            defeated: false
        });

        vm.prank(gameOwner, gameOwner);
        game.newBoss(boss);

        vm.prank(character1);
        game.attackBoss();

        vm.prank(character1);
        game.attackBoss();

        vm.expectRevert(bytes("Game: Boss is already defeated"));
    }

    function testKillCharacterWithCounterattack() public {
        vm.prank(character1);
        Character memory character = game.newCharacter("testCharacter");

        Boss memory boss = Boss({
            creator: gameOwner,
            name: "test",
            healthPoints: 100,
            reward: 100,
            defeated: false
        });

        vm.prank(gameOwner, gameOwner);
        game.newBoss(boss);

        vm.startPrank(character1);
        while (game.getCharacter(character.creator).healthPoints > 0) {
            game.attackBoss();
        }
        vm.stopPrank();

        assertEq(game.getCharacter(character.creator).healthPoints, 0);
        assertEq(game.deadCharacters(character.creator), true);
    }

    function testHealCharacter() public {
        vm.prank(character1);
        Character memory character = game.newCharacter("testCharacter");

        vm.prank(character2);
        Character memory characterTwo = game.newCharacter("testCharacter2");

        Boss memory boss = Boss({
            creator: gameOwner,
            name: "test",
            healthPoints: 300,
            reward: 100,
            defeated: false
        });

        vm.prank(gameOwner, gameOwner);
        game.newBoss(boss);

        vm.startPrank(character1);
        while (game.getCharacter(character.creator).healthPoints > 0) {
            game.attackBoss();
        }
        vm.stopPrank();

        vm.startPrank(character2);
        game.attackBoss();
        game.claimRewards();
        game.healCharacter(character2, character1);
        vm.stopPrank();
    }

    function testClaimRewards() public {
        vm.prank(character1);
        Character memory character = game.newCharacter("testCharacter");

        Boss memory boss = Boss({
            creator: gameOwner,
            name: "test",
            healthPoints: 100,
            reward: 100,
            defeated: false
        });

        vm.prank(gameOwner, gameOwner);
        game.newBoss(boss);

        vm.startPrank(character1);
        game.attackBoss();
        game.claimRewards();
        vm.stopPrank();

        assertEq(game.getCharacter(character.creator).xp, 10);
    }

    function testFailClaimRewards() public {
        vm.prank(character1);
        Character memory character = game.newCharacter("testCharacter");

        Boss memory boss = Boss({
            creator: gameOwner,
            name: "test",
            healthPoints: 100,
            reward: 100,
            defeated: false
        });

        vm.prank(gameOwner, gameOwner);
        game.newBoss(boss);

        vm.prank(character1);
        game.attackBoss();

        game.claimRewards();

        vm.expectRevert(bytes("Game: No rewards to claim"));
    }
}

