Feature: Playing sudoku
  In order to play Sudoku
  And guess a move
  I need a playing board

  Scenario: 
    Given I make a move
    When I put a number into a blank cell
    Then I should be informed if it is the correct digit