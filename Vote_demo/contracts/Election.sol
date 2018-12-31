pragma solidity >=0.4.21 <0.6.0;

contract Election {

    //结构体
    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    //事件
    event votedEvent(
        uint indexed _candidateId
    );

    //存储结构体
    mapping (uint => Candidate) public candidates;
    //是否已经投票了
    mapping (address=>uint) public voters;

    //总数量
    uint public candidateCount;

    //构造函数
    constructor() public {
        candidateCount = 0;
        addCandidate("孟美岐");
        addCandidate("吴宣仪");
        addCandidate("杨超越");
    }

    //添加候选人
    function addCandidate(string memory _name) private {
        candidateCount ++;
        candidates[candidateCount] = Candidate(candidateCount, _name, 0);
    }

    //投票
    function vote(uint _candidateId) public payable{

        //过滤
        require(_candidateId > 0 && _candidateId <= candidateCount);

        //记录用户已经投票了
        voters[msg.sender]++;
        candidates[_candidateId].voteCount ++;

        emit votedEvent(_candidateId);
    }

}