// Hashelot Delphi - v.1.0 beta
// MIT License
// Copyright (c) 2020 Maurizio Ponti

pragma solidity ^0.6.4;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";

contract Delphi { // Son of a lockdown

  // _delphi defined at deployment
  address payable public _delphi;
  uint private fin;
  mapping (address => uint) _oracleID;

  constructor()
    public
  { // Once and for all
    _delphi = msg.sender;
    fin = 10**15;
  }

  Oracle [] public oracles;
  address payable [] public oraclesAddresses;

  // In case you were wondering how many oracles are out there
  function howManyOracles()
    public
    view
    returns (uint)
  {
    return oracles.length;
  }

  // The user wants to become an oracle
  // by doing so a minimumReward (uint) needs to be set
  function makeMeAnOracle(uint _minimumReward)
    public
    payable
    returns (address newOracle)
  {
    // You need to make a 1 finney offering to Delphi to become an oracle
    require (msg.value >= 1 finney, "Error [makeMeAnOracle]: Missing 1 finney offering.");
    uint oracleChange = SafeMath.sub(msg.value, fin);

    // Make a new oracle out of the user who invoked the function
    Oracle _oracle = new Oracle();
    oracles.push(_oracle);

    oraclesAddresses.push(msg.sender);
    _oracleID[address(_oracle)] = SafeMath.sub(oracles.length, 1);

    // Only Delphi's contract can operate the following functions
    // Set the oracle's address to the one of the caller
    Oracle(_oracle).setTheOracleAddress(msg.sender);

    // Set a minimum reward for the new Oracle
    Oracle(_oracle).setMinimumReward(_minimumReward);

    // Set things right, financially-wise
    if (oracleChange > 0) {
      _delphi.transfer(fin); // 1 finney to Delphi
      msg.sender.transfer(oracleChange); // Keep the change
    }else{
      _delphi.transfer(fin);
    }

    return address(_oracle);
  }

  // When consulting the Oracle one needs to
  // set a _question, a _reward (msg.value, higher than the Oracle's minimumReward)
  // and a flag that tells if the given answer can be further modified (again and again and ...)
  // _open: 1 means true, any other number false
  function askTheOracle(Oracle _oracle, bytes32 _question, uint _openNum)
    public
    payable
    returns (uint _index)
  {
    require (msg.value >= Oracle(_oracle).minimumReward(), "Error [askTheOracle]: The Oracle demands more Ether for answering your question.");

    // 0.1% of the reward goes to Delphi
    uint _delphiShare = SafeMath.div(msg.value,1000);
    // The rest goes to the oracle (once an answer is given)
    uint _oracleShare = SafeMath.sub(msg.value, _delphiShare);

    _delphi.transfer(_delphiShare); // Send to Delphi's constructor its share
    bool _open = false;
    if(_openNum == 1){
      _open = true;
    }
    // The rest is for the Oracle's contract when an answer is given
    _index = Oracle(_oracle).addQuestion(msg.sender, _oracleShare, _question, _open);

    return _index;
  }

  // What did you ask?
  function checkQuestionByIndex(Oracle _oracle, uint _index)
    public
    view
    returns (bytes32) // Question according to _index
  {
    require (Oracle(_oracle).howManyQuestions() > 0, "Error [checkQuestionByIndex]: There are no questions at all.");
    require (Oracle(_oracle).howManyQuestions() > _index, "Error [checkQuestionByIndex]: Not enough questions, choose a lower index.");

    return Oracle(_oracle).gimmeQuestion(_index);
  }

  // What's in it for me?
  function checkRewardByIndex(Oracle _oracle, uint _index)
    public
    view
    returns (uint) // Reward according to _index
  {
    require (Oracle(_oracle).howManyQuestions() > 0, "Error [checkRewardByIndex]: There are no questions at all.");
    require (Oracle(_oracle).howManyQuestions() > _index, "Error [checkRewardByIndex]: Not enough questions to search for a reward, choose a lower index.");

    return Oracle(_oracle).gimmeReward(_index);
  }

  // How much will it cost (the least)?
  function checkOracleMinimumReward(Oracle _oracle)
    public
    view
    returns (uint) // Minimum reward
  {
    return Oracle(_oracle).minimumReward();
  }

  // What did the Oracle say?
  function checkAnswerByIndex(Oracle _oracle, uint _index)
    public
    view
    returns (bytes32) // Answer according to _index
  {
    require (Oracle(_oracle).howManyQuestions() > 0, "Error [checkAnswerByIndex]: There are no questions at all.");
    require (Oracle(_oracle).howManyQuestions() > _index, "Error [checkAnswerByIndex]: Not enough questions to search for an answer, choose a lower index.");

    return Oracle(_oracle).gimmeAnswer(_index);
    // Even if the answer has not been given yet, it'll return something.
  }

  // Is there an answer yet?
  function isThereAnAnswerYet(Oracle _oracle, uint _index)
    public
    view
    returns (bool)
  {
    require (Oracle(_oracle).howManyQuestions() > 0, "Error [isThereAnAnswerYet]: There are no questions at all.");
    require (Oracle(_oracle).howManyQuestions() > _index, "Error [isThereAnAnswerYet]: Not enough questions to search for an answer, choose a lower index.");
    if (Oracle(_oracle).gimmeQuestionTime(_index) > Oracle(_oracle).gimmeAnswerTime(_index)){
      return false;
    }else{
      return true;
    }
  }

  // Set the answer to a question
  function setAnswer(Oracle _oracle, uint _index, bytes32 _answer)
    public
    payable
  {
    require (Oracle(_oracle).whosTheOracle() == msg.sender, "Error [setAnswer]: Only the Oracle can perform this action.");

    if (isThereAnAnswerYet(_oracle, _index)){
      // The reward for questions[_index] has already been granted
      // and only open answers can be modified at will
      require (Oracle(_oracle).gimmeOpen(_index), "Error [setAnswer]: The answer cannot be modified.");
      // The answer can be changed, but there won't be any reward for that
      Oracle(_oracle).provideAnswer(_index, _answer);
    }else{
      // First time answering? You get a reward!
      if(Oracle(_oracle).provideAnswer(_index, _answer)){
          uint _reward = Oracle(_oracle).gimmeReward(_index);
          Oracle(_oracle).whosTheOracle().transfer(_reward);
      }
    }
  }

  // Update the minimum reward
  function updateMinimumReward(Oracle _oracle, uint _minimumReward)
    public
  {
    require (Oracle(_oracle).whosTheOracle() == msg.sender, "Error [updateMinimumReward]: Only the Oracle can perform this action.");

    // Update the minimum reward for Oracle(_oracle)
    Oracle(_oracle).setMinimumReward(_minimumReward);
  }

  // Has any question been asked to the Oracle?
  function oracleStats(Oracle _oracle)
    public
    view
    returns (uint _numberQuestions, uint _numberAnswers)
  {
    if (Oracle(_oracle).howManyQuestions() == 0){
      return (0, 0);
    }else{
      return (Oracle(_oracle).howManyQuestions(), Oracle(_oracle).howManyAnswers());
    }
  }

  // What's the id?
  function getOracleID(Oracle _oracle)
    public
    view
    returns (uint _index)
  {
    require (howManyOracles() > 0, "Error [getOracleID]: There are no Oracles.");
    return _oracleID[address(_oracle)];
  }

  // What's the oracle's address?
  function checkOracleAddress(Oracle _oracle)
    public
    view
    returns (address payable) // Oracle's address
  {
    return Oracle(_oracle).whosTheOracle();
  }

  // Get the most useful Delphi's data in a convenient fashion (a single yuge bytes)
  // Oracle's identifier (contract) (20 bytes)
  // + Oracle's address (20 bytes)
  // + minimum reward (32 bytes)
  function showcaseAllOracles()
    public
    view
    returns (bytes memory)
  {
    uint _oraclesNum = howManyOracles();
    bytes memory _output;
    // Expected length of _output: 72*_oraclesNum

    if (_oraclesNum > 0) { // There actually is data to fetch

      // 20
      bytes memory oracle_Contract;
      // 20
      bytes memory oracle_Address;
      // 32
      bytes memory oracle_minimumReward;

      for (uint k = 0; k < _oraclesNum; k++){
        oracle_Contract = abi.encodePacked(oracles[k]);
        oracle_Address = abi.encodePacked(checkOracleAddress(oracles[k]));
        oracle_minimumReward = abi.encodePacked(checkOracleMinimumReward(oracles[k]));

        _output = abi.encodePacked(_output, oracle_Contract, oracle_Address, oracle_minimumReward);

      }
    }else{ // No oracles? No need to fetch data!
      _output = "";
    }
    return _output;
  }

  // List questions, answers, rewards, time, and inquirers of a specific oracle
  function thatSingleOracle(Oracle _oracle)
    public
    view
    returns (bytes memory)
  {
    uint _howManyQuestions = Oracle(_oracle).howManyQuestions();
    bytes memory _output;

    // Expected length of _output: 182 * _howManyQuestions

    if (_howManyQuestions > 0){

      bytes memory _question; // 32
      bytes memory _answer; // 32
      bytes memory _reward; // 32
      bytes memory _questionTime; // 32
      bytes memory _answerTime; // 32
      bytes memory _inquirer; // 20
      bytes memory _open; // 2

      for (uint k = 0; k < _howManyQuestions; k++){

        _question = abi.encodePacked(Oracle(_oracle).gimmeQuestion(k));
        _answer = abi.encodePacked(Oracle(_oracle).gimmeAnswer(k));
        _reward = abi.encodePacked(Oracle(_oracle).gimmeReward(k));
        _questionTime = abi.encodePacked(Oracle(_oracle).gimmeQuestionTime(k));
        _answerTime = abi.encodePacked(Oracle(_oracle).gimmeAnswerTime(k));
        _inquirer = abi.encodePacked(Oracle(_oracle).gimmeInquirer(k));
        _open = abi.encodePacked(Oracle(_oracle).gimmeOpen(k));

        _output = abi.encodePacked(_output, _question, _answer, _reward, _questionTime, _answerTime, _inquirer, _open);

      }
    }else{// No questions? No need to fetch data!
      _output = "";
    }
    return _output;
  }

  // List data from a single question according to index:
  // question, answer, reward, questionTime, answerTime, openness, and inquirer
  function thatSingleQuestion(Oracle _oracle, uint _index)
    public
    view
    returns (bytes memory)
  {
    uint _limit = Oracle(_oracle).howManyQuestions();
    bytes memory _output;
    if (_index < _limit){ // Does the question exist?

      // Expected length of _output: 182

      // 32
      bytes memory _question = abi.encodePacked(Oracle(_oracle).gimmeQuestion(_index));
      // 32
      bytes memory _answer = abi.encodePacked(Oracle(_oracle).gimmeAnswer(_index));
      // 32
      bytes memory _reward = abi.encodePacked(Oracle(_oracle).gimmeReward(_index));
      // 32
      bytes memory _questionTime = abi.encodePacked(Oracle(_oracle).gimmeQuestionTime(_index));
      // 32
      bytes memory _answerTime = abi.encodePacked(Oracle(_oracle).gimmeAnswerTime(_index));
      // 20
      bytes memory _inquirer = abi.encodePacked(Oracle(_oracle).gimmeInquirer(_index));
      // 2
      bytes memory _open = abi.encodePacked(Oracle(_oracle).gimmeOpen(_index));

      _output = abi.encodePacked(_question, _answer, _reward, _questionTime, _answerTime, _inquirer, _open);

    }else{ // This is not the question you're looking for
      _output = "";
    }
    return _output;
  }

}

contract Oracle {

  // Delphi's contract address defined at deployment
  address payable public whosDelphi;

  // "Not answered yet!"
  bytes32 private notAnsweredYet;

  constructor()
    public
  { // Once and for all
    whosDelphi = msg.sender;
    notAnsweredYet = 0x0000000000000000000000000000000000000000000000000000000000000000;
  }

  // Only if Delphi asks
  modifier DelphiOnly{
      if(msg.sender == whosDelphi){
          _;
      }
  }

  // Array of questions
  bytes32 [] public questions;

  // Array of answers
  bytes32 [] public answers;

  // Array of blockNumbers at which questions had been asked
  // and answers had been given
  uint [] public questionTime;
  uint [] public answerTime;

  // Array of inquirers
  address [] public inquirers;

  // Array of rewards
  uint [] public rewards;

  // Minimum reward
  uint public minimumReward;

  // Recurring answers
  bool [] public openAnswer;

  // Oracle's address
  address payable public whosTheOracle;

  // Set whosTheOracle
  function setTheOracleAddress(address payable _oracleAddress)
    DelphiOnly
    public
  {
    whosTheOracle = _oracleAddress;
  }

  // Set minimumReward
  function setMinimumReward(uint _minimumReward)
    DelphiOnly
    public
  {
    minimumReward = _minimumReward;
  }

  // How many questions have been asked?
  function howManyQuestions()
    DelphiOnly
    public
    view
    returns (uint)
  {
    return questions.length;
  }

  // How many answers have been given?
  function howManyAnswers()
    DelphiOnly
    public
    view
    returns (uint)
  {
    uint _times = 0;
    for (uint k=0; k<questions.length; k++){
      if (questionTime[k] <= answerTime[k]){
        _times++;
      }
    }
    return _times;
  }

  // Get questions
  function gimmeQuestion(uint _element)
    DelphiOnly
    public
    view
    returns (bytes32)
  {
    return questions[_element];
  }

  // Get answers
  function gimmeAnswer(uint _element)
    DelphiOnly
    public
    view
    returns (bytes32)
  {
    return answers[_element];
  }

  // Get questionTime
  function gimmeQuestionTime(uint _element)
    DelphiOnly
    public
    view
    returns (uint)
  {
    return questionTime[_element];
  }

  // Get answerTime
  function gimmeAnswerTime(uint _element)
    DelphiOnly
    public
    view
    returns (uint)
  {
    return answerTime[_element];
  }

  // Get inquirers
  function gimmeInquirer(uint _element)
    DelphiOnly
    public
    view
    returns (address)
  {
    return inquirers[_element];
  }

  // Get rewards
  function gimmeReward(uint _element)
    DelphiOnly
    public
    view
    returns (uint)
  {
    return rewards[_element];
  }

  // Get answer's openness
  function gimmeOpen(uint _element)
    DelphiOnly
    public
    view
    returns (bool)
  {
    return openAnswer[_element];
  }

  // There's a new question
  function addQuestion(address _inquirer, uint _oracleShare, bytes32 _question, bool _open)
    DelphiOnly
    public
    returns (uint _index)
  {
    uint _when = block.number;
    _index = questions.length; // Arrays start at 0
    inquirers.push(_inquirer);
    rewards.push(_oracleShare);
    questions.push(_question);
    questionTime.push(_when);
    answerTime.push(1); // Default time for answer
    answers.push(notAnsweredYet);
    openAnswer.push(_open);

    return _index;
  }

  // Answer a question - Only the Oracle will be able to perform this action
  // through Delphi's contract
  function provideAnswer(uint _index, bytes32 _answer)
    DelphiOnly
    public
    returns (bool)
  {
    uint _when = block.number;
    answers[_index] = _answer;
    answerTime[_index] = _when;
    return true;
  }

}
