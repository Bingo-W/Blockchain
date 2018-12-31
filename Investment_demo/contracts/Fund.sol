pragma solidity >=0.4.21 <0.6.0;

contract Fund {
    
    //the table of the user
    uint public userNum;
    mapping(uint=>address payable) public Users;
    
    
    //the table of the fund
    mapping(uint=>uint) public rights;
    uint rightSum;
    uint rightSumAll;
    uint proportion = 1 ether;
    
    //test
    address payable owner;
    
    uint public endtime;
    uint public checkBegin;//begin to check whether it is benefit or not
    uint public checkEnd;//end checking whether it is benefit or not
    modifier onlyBefore(uint _time) { require(now < _time); _; }
    modifier onlyAfter(uint _time) { require(now > _time); _; }
    modifier onlyCheck() {require((now%24 hours)>checkBegin || (now%24 hours)<checkEnd); _;}
    /*test*/
    uint _endtime = 30 days;
    uint _begincheckTime = 0 hours;
    uint _endcheckTime = 24 hours;
    

    //事件
    event fundEvent(
        uint indexed _candidateId
    );

    constructor() public payable{
        
        checkBegin = _begincheckTime;
        checkEnd = _endcheckTime;
        endtime = now + _endtime;
        owner = msg.sender;
        init();
    }
    
    
    //initial function
    function init() public{
        rightSum = 10;
        rightSumAll = 10;
        userNum = 0;
    }
    
    //get the fund
    function changeFund() onlyBefore(endtime) external payable{
        
        require(msg.value >= proportion);
        require(rightSum > 0);
        
        uint right = msg.value/proportion;
        
        //check the user is new or not
        uint UserID = userNum;
        for(uint i = 0; i < userNum; i++) {
            if(Users[i] == msg.sender) UserID = i;
        }
        
        Users[UserID] = msg.sender;
        
        //the rightSum is left or not
        if(rightSum >= right) {
            if(UserID == userNum) rights[UserID] = right;
            else rights[UserID] += right;
            
            rightSum -= right;
            right = 0;
        }
        else{
            if(UserID == userNum) rights[UserID] = rightSum;
            else rights[UserID] += rightSum;
            right -= rightSum;
            rightSum = 0;
        }
        
        userNum++;
        
        //return the left fund
        if(msg.value % proportion != 0 ether) {
            uint256 refundFee = msg.value % proportion + right*proportion;
            msg.sender.transfer(refundFee);
        }
        
        emit fundEvent(UserID);
    }
    
    //check the fund is enough or not
    function checkFund() onlyAfter(endtime) public {
        require(rightSum > 0);
        
        uint userID;
        for(uint i = 0;  i < userNum; i++) {
            if(Users[i] == msg.sender) userID = i;
        }
        
        if(rights[userID] != 0) {
            uint refundFee = rights[userID]*10 ether;
            rights[userID] = 0;
            Users[userID].transfer(refundFee);
        }
    }
    
    //check it is benefit or not
    //if get more than 20% of fund or get less 20% of the fund , then it is ended
    function checkBenefit() onlyCheck() public {
        
        uint max = proportion*12/10;
        uint min = proportion*8/10;
        
        if(address(this).balance >= max || address(this).balance <= min) {
            refundFund();
        }
    }
    
    //return the money
    function refundFund() private{
        uint profit = address(this).balance/10000;
        uint refundFee = 0 ether;
        address payable temp;
        
        for(uint i=0; i<userNum; i++) {
            refundFee = profit*rights[i];
            rights[i] = 0;
            temp = Users[i];
            temp.transfer(refundFee*1 ether);
        }    
    }
    
    
}