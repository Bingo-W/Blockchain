App = {
  web3Provider: null,
  contracts: {},
  account: '0x0',

  init: function() {
    return App.initWeb3();
  },

  initWeb3: function() {
    if (typeof web3 !== 'undefined') {
      App.web3Provider = web3.currentProvider;
      //console.warn("Meata");
    }else{
      App.web3Provider = new Web3.providers.HttpProvider('Http://127.0.0.1:7545');
    }
    web3 = new Web3(App.web3Provider);
    return App.initContract();
  },

  initContract: function() {

    

    $.getJSON("Fund.json",function(election){

      App.contracts.Election = TruffleContract(election);
      App.contracts.Election.setProvider(App.web3Provider);

      App.listenForEvents();

      return App.reander();
    })

  },

  reander: function(){

    var electionInstance;
    var $loader = $("#loader");
    var $content = $("#content");

    $loader.show();
    $content.hide();

    //获得账号信息
    web3.eth.getCoinbase(function(err,account){
      if(err === null){
        App.account = account;
        $("#accountAddress").html("您当前的账号: " + account);
      }
    });

    //加载数据
    //var address = "0x5af356392A7c551C9a624d1E165F04a9BBAb9693";
    App.contracts.Election.deployed().then(function(instance){
      console.log("test");
      electionInstance = instance;
      return electionInstance.userNum();
    }).then(function(userNum){
      var $candidatesResults = $("#candidatesResults");
      $candidatesResults.empty();

      var $cadidatesSelect = $("#cadidatesSelect");
      $cadidatesSelect.empty();

      for (var i=1;i<=userNum;i++){
        var id;
        var name;
        electionInstance.Users(i).then(function(candidate){
          id = i;
          name = candidate;
          //var voteCount = candidate[2];

          //var candidateTemplate = "<tr><th>"+id+"</th><td>"+name+"</td><td>"+voteCount+"</td></tr>";
          //$candidatesResults.append(candidateTemplate);

          return electionInstance.Users(i);
        }).then(function(candidate){
          
          var voteCount = candidate[2];

          var candidateTemplate = "<tr><th>"+id+"</th><td>"+name+"</td><td>"+voteCount+"</td></tr>";
          $candidatesResults.append(candidateTemplate);

        });


      }

      for(var i = 1; i <= 3; i++) {
          if(i == 1) var cadidateOption = "<option value='"+i+"'>"+ i +" ether" +"</option>";
          else var cadidateOption = "<option value='"+i+"'>"+(i*5) + " ether"+ "</option>";
          $cadidatesSelect.append(cadidateOption);
          console.log(cadidateOption);
        }
      return false;

    }).then(function(hasVoted){

      if(hasVoted){
        $('form').hide();
      }
      $loader.hide();
      $content.show();

    }).catch(function(err){
      console.warn(err);
      console.log("test");
    });
  },

  //投票
  castVote: function(){

    var $loader = $("#loader");
    var $content = $("#content");
    console.log("233");
    var candidateId = $('#cadidatesSelect').val();
    console.log(candidateId);
    candidateId *= 1000000000000000000;

    App.contracts.Election.deployed().then(function(instance){
      return instance.changeFund({from: App.account, value: candidateId});
    }).then(function(result){
      console.log("666");
      $content.hide();
      $loader.show();
    }).catch(function(err){
      console.warn(err);
      console.log("failed");
    });

  },

  //监听事件
  listenForEvents: function(){
    App.contracts.Election.deployed().then(function(instance){
      instance.fundEvent({},{
       formBlock:0,
       toBlock: 'latest'
      }).watch(function(error,event){
        console.log("event triggered",event);
        App.reander();
      });
    })
  }

};

$(function() {
  $(window).load(function() {
    App.init();
  });
});