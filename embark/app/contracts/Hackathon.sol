pragma solidity ^0.4.7;
contract SimpleStorage {
  uint public storedData;

  function SimpleStorage(uint initialValue) {
    storedData = initialValue;
  }

  function set(uint x) {
    storedData = x;
  }

  function get() constant returns (uint retVal) {
    return storedData;
  }

}



contract HackathonPrime{
  struct HackEntry{
    bool initialized;
    bool approved;
    uint timeCreated;
    uint timeStart;
    uint timeEnd;
    address hackathon;
  }
  mapping (address => uint256) public hackathonMap;
  mapping (address => bool) public administrator;
  HackEntry [] hackathons;

  function HackathonPrime(){
    administrator[msg.sender]=true;

  }

  function addEntry(address newHackathon,uint256 start,uint256 end){
    hackathons.push(HackEntry(true,false,now,start,end,newHackathon));
  }

  function approveEntry(uint256 index, bool approve){
    if (administrator[msg.sender]){
      hackathons[index].approved = approve;
    }
  }

  function changeTimeStart(uint256 index, uint256 start){
    if (administrator[msg.sender]){
      hackathons[index].timeStart = start;
    }
  }

  function changeTimeEnd(uint256 index, uint256 end){
    if (administrator[msg.sender]){
      hackathons[index].timeEnd = end;
    }
  }

  function getHackathon(uint256 index) constant returns (bool initialized,bool approved,uint timeCreated,uint timeStart,uint timeEnd,address hackathon){
    if (index==hackathons.length){
      initialized=false;
      return;
    }

    if (index>hackathons.length){
      initialized=false;
      return;
    }
    HackEntry theEntry = hackathons[index];

    if (theEntry.initialized){
        initialized=theEntry.initialized;
        approved=theEntry.approved;
        timeCreated=theEntry.timeCreated;
        timeStart=theEntry.timeStart;
        timeEnd=theEntry.timeEnd;
        hackathon=theEntry.hackathon;
        timeEnd = 6;
      } else {
        initialized=false;
        approved = false;
        timeEnd = 7;

      }


  }


  function getHackathonApproved(uint256 index) constant returns (bool initialized,bool approved,uint timeCreated,uint timeStart,uint timeEnd,address hackathon){
    if (index==hackathons.length){
      initialized=false;
      return;
    }

    if (index>hackathons.length){
      initialized=false;
      return;
    }
    HackEntry theEntry = hackathons[index];

    if (theEntry.approved){
        initialized=theEntry.initialized;
        approved=theEntry.approved;
        timeCreated=theEntry.timeCreated;
        timeStart=theEntry.timeStart;
        timeEnd=theEntry.timeEnd;
        hackathon=theEntry.hackathon;
        timeEnd = 6;
      } else {
        initialized=theEntry.initialized;
        approved = false;
        timeEnd = 7;

      }


  }




}


contract Hackathon{


  struct Team{
    bool initialized;
    bool exists;
    string name;
    uint256 teamPaper;
    address[] members;
  }

  string name;
  uint256 description;
  uint256 release;
  mapping(address=>uint8) teamsLink;
  Team[] teams;
  address[] peopleAsk;
  bool[] peopleApproved;
  mapping (address => uint256) peopleApplication;

  mapping (address => bool) public people;
  mapping (address => bool) public voted;
  uint8[] votesValues;
  mapping (address => bool) public administrator;
  bool canVote;

  function Hackathon(){
    administrator[msg.sender]=true;
    address[] memory members;
    teams.push(Team(true,false,"Choose Your Team",0,members));
    canVote = true;
  }

  function setVote(bool can){
    if (administrator[msg.sender]){
      canVote = can;
    }
  }

  function getPeople(uint256 index) constant returns(address person, bool personApproved, bool end, uint256 application){
    if (index==peopleAsk.length||index>peopleAsk.length){
      end = true;
    } else{
      person = peopleAsk[index];
      application = peopleApplication[person];
      personApproved = peopleApproved[index];
    }
  }

  function areYouApproved() constant returns(bool personApproved){
    return people[msg.sender];
  }

  function describe(address stonePaperAccount) constant returns(string nameR,uint256 descriptionD, uint256 releaseD  ){
    nameR = name;
    descriptionD = description;
    releaseD = release;
  }


  function nameHackathon(address stonePaperAccount,string newName){
    if (administrator[msg.sender]){
      name = newName;
      StonePaper stonePaperC = StonePaper(stonePaperAccount);
      stonePaperC.assignLawyer(newName);
    }
  }

  function setDescription(uint256 newDescription){
    if (administrator[msg.sender]){
      description = newDescription;
    }
  }

  function setDescriptionWithPaper(
         address stonePaperAccount,
         string nameI,
         bytes32 signI,
         uint256 databaseI,
         uint256[] metaI,
         address contractLoc,
         address[] goToLocation){
    if (administrator[msg.sender]){
      StonePaper stonePaperC = StonePaper(stonePaperAccount);
      description = stonePaperC.createPaper(nameI,signI,databaseI,metaI,contractLoc,goToLocation);
    }
  }

  function setReleaseWithPaper(
         address stonePaperAccount,
         string nameI,
         bytes32 signI,
         uint256 databaseI,
         uint256[] metaI,
         address contractLoc,
         address[] goToLocation){
    if (administrator[msg.sender]){
      StonePaper stonePaperC = StonePaper(stonePaperAccount);
      release = stonePaperC.createPaper(nameI,signI,databaseI,metaI,contractLoc,goToLocation);
    }
  }



  function apply(address stonePaperAccount, bytes32 signI, uint256 databaseI,
    uint256[] metaI,
    address[] goToLocation){
    if (people[msg.sender]==false){
      StonePaper stonePaperC = StonePaper(stonePaperAccount);
      peopleApplication[msg.sender] = stonePaperC.createPaper("Applicant",signI,databaseI,metaI,this,goToLocation);
      peopleAsk.push(msg.sender);
      peopleApproved.push(false);
    }
  }

  function verifyPeople(uint256 index){
    if (administrator[msg.sender]){
        peopleApproved[index]=true;
        people[peopleAsk[index]]=true;
    }

  }

  function vote(uint8 index){
    if (!canVote){
      throw;
    }
      if (voted[msg.sender]==false){
        voted[msg.sender]=true;
        votesValues.push(index);
      }else{
        throw;
      }

  }

  function createTeam(string name){
    if (teamsLink[msg.sender]==0){
      address[] memory members;
      teams.push(Team(true,true,name,0,members));
      teamsLink[msg.sender]=uint8(teams.length-1);
      } else {
        teams[teamsLink[msg.sender]].name=name;
      }
    }

  function getTeam(uint index) constant returns (bool initialized,bool exists,string name,uint256 teamPaper,address[] members, bool end){
    if (index>teams.length||index==teams.length){
      end=true;
      return;
    }
    Team aTeam = teams[index];

    initialized = aTeam.initialized;
    exists = aTeam.exists;
    name = aTeam.name;
    teamPaper = aTeam.teamPaper;
    members = aTeam.members;

  }

  function addMember(address newUser){
    uint8 theTeam = teamsLink[msg.sender];
    if (theTeam!=0&&teamsLink[newUser]==0&&people[newUser]==true){
      teams[theTeam].members.push(newUser);
      teamsLink[newUser]=theTeam;
    } else {
      throw;
    }
  }

  function updateDescription(bytes32 signI,uint256[] metaI,address stonePaperAccount){
    uint8 theTeam = teamsLink[msg.sender];
    if (theTeam!=0){
      StonePaper stonePaperC = StonePaper(stonePaperAccount);
      teams[theTeam].teamPaper = stonePaperC.createPaperLight("Team Description",signI,0,msg.sender,metaI);
    }
  }

  function updateName(string name){
    uint8 theTeam = teamsLink[msg.sender];
    if (theTeam!=0){
      teams[theTeam].name=name;
    }
  }

  function calculateVotes()constant returns (uint16[256]){
    uint16[256] memory theVotes;
    for (uint counter = 0; counter<votesValues.length; counter++){
      uint8 vote = votesValues[counter];
      theVotes[vote]=theVotes[vote]+1;
    }
    return theVotes;
  }


}





contract StonePaper {


    /* Public variables of the token */
    string public standard = 'Token 0.2';
    string public name = "Stone Paper";

    address public godUser = 0x0;

  /* The token that hold all the data */
   struct Paper{
       string name; //Document Name
       bytes32 sig; //Hash of Document and Signiture
       uint256 database; // Number to identify the URL of the site which hold the data
       uint time; // Time the document was created
       address creator; // Creator of said document
       address lawyer; // Lawyer who authorized said document
       uint256[] meta; // All Meta data for document
       address contractLoc; // Contract Location
   }

   function StonePaper(){
     godUser=msg.sender;
   }


   uint16 numberOfAdmins;

   struct AdminAddVote{
       address creator;
       address newSupervisor;
       uint16 voteYes;
       uint16 voteNo;
       uint time;
       bool resolved;
       bool deathOrBirth;
       mapping (address => bool) alreadyVoted;

   }

   AdminAddVote[] public currentVotes;


    /* All of the Dictionary's with info */
    Paper[] public papers;
    mapping (address => uint256[]) public briefcase;
    mapping (address => string) public lawyerList;
    mapping (uint256 => string) public metaList;
    mapping (uint256 => string) public databaseList;
    mapping (uint256 => address) public databaseOwner;
    mapping (address => bool) public superVisor;
    mapping (uint256 => mapping(address => bool)) public publicMeta;
    mapping (uint256 => bool) public isPublic;
    mapping (uint256 => uint256[]) public metaDatabase;
    mapping (address => mapping(address => uint256)) public lastPaperAdded;


    //Used in the debugger to determine the number of userss
    address[] public users;
    mapping (address => uint256) public lookupUsers;

    function getUser(uint256 index) constant returns (address userAddress, string userName, uint256 length){
      if (index<users.length){
        userAddress = users[index];
        userName = lawyerList[users[index]];
        length = users.length;
      } else{
        userAddress = 0;
        userName = "No User";
        length = users.length;
      }
    }


    /* This generates a public event on the blockchain that will notify clients */
/*
    event ThereIsANewVote(address newSupervisor, address motionMadeBy,bool deathOrBirth, uint256 index);
    event NewSupervisor(address newSupervisor);
    event RemovedSupervisor(address oldSupervisor);
*/

    //Assign the lawyer's name in plaintext to a wallet

    function assignLawyer(string name){
      if (bytes(name).length==0){
        throw;
      }
        if (bytes(lawyerList[msg.sender]).length == 0){
            lawyerList[msg.sender]=name;
            lookupUsers[msg.sender]=users.length;
            users.push(msg.sender);
        }else{
          lawyerList[msg.sender]=name;
        }
    }

    // Return the text of the Lawyer in plaintext

    function getLawyer(address lawyer) constant returns (string) {
        return lawyerList[lawyer];
    }

    // Assign url to database, the database will be owned by whoever creates the database

    function setDatabase(string url, uint256 database){
        if (databaseOwner[database]==0){
            databaseList[database]=url;
            databaseOwner[database]=msg.sender;
        }else{
          if (databaseOwner[database]==msg.sender){
            databaseList[database]=url;
          }
        }
    }

    // Return the url of the database

    function getDatabase(uint256 database) constant returns (string){
        return databaseList[database];
    }


    // Assign a text description to a meta tag allowing the user to own it
    function assignMeta(string name, uint256 meta){
        if (bytes(metaList[meta]).length==0){
            metaList[meta]=name;
            publicMeta[meta][msg.sender]=true;
        }else{
            throw;
        }
    }

    /* Add another user able to apply a private meta tag */

    function addUserToMeta(address newUser, uint256 meta){
        if (publicMeta[meta][msg.sender]==true){
            publicMeta[meta][newUser]=true;
        } else {
            throw;
        }

    }

    /* Allow the Meta Tag to be used by all users. Can only be done by the meta tag owner */

    function makeMetaPublic(uint256 meta, bool newState){
        if (publicMeta[meta][msg.sender]==true){
            isPublic[meta]=newState;
        } else {
            throw;
        }

    }

    /* Edit the description of a meta tag can only be done by the meta tag creator */

    function editMeta(string text, uint256 meta){
        if (publicMeta[meta][msg.sender]==true){
            metaList[meta]=text;
        } else {
            throw;
        }
    }

    /* Return the English description of a meta tag */

    function getMeta(uint256 meta) constant returns (string metaName){
        metaName = metaList[meta];
        return metaList[meta];
    }




    /* Test Meta*/
    function testMeta(uint256 _index) constant returns ( bool result){

        if (isPublic[_index]){

            return true;
        } else {
            return publicMeta[_index][msg.sender];
        }

    }

    /* Initializes Create a New Paper

    nameI = The name of the document in planetext
    signI = the hash of the document
    databaseI = the database where the data is stored
    metaI = all metaData to attach to the Paper
    lawyerI = the lawyer who has added the document

    */

    function createPaperLight(
      string nameI,
      bytes32 signI,
      uint256 databaseI,
      address goToLocation,
      uint256[] metaI
      ) returns (uint256){

        uint256 theIndex = papers.length;
        papers.push(Paper(nameI,signI,databaseI,now,tx.origin,msg.sender,metaI,msg.sender));

        briefcase[msg.sender].push(theIndex);
        lastPaperAdded[msg.sender][msg.sender]=theIndex;

        briefcase[goToLocation].push(theIndex);
        lastPaperAdded[goToLocation][msg.sender]=theIndex;

        return theIndex;


      }

    function createPaper(
       string nameI,
       bytes32 signI,
       uint256 databaseI,
       uint256[] metaI,
       address contractLoc,
       address[] goToLocation
        ) returns (uint256){

            for(uint x = 0; x <metaI.length; x++) {
                if (!testMeta(metaI[x])){
                    throw;
                }
            }

        uint256 theIndex = papers.length;
        papers.push(Paper(nameI,signI,databaseI,now,tx.origin,msg.sender,metaI,contractLoc));

        for(x = 0; x <metaI.length; x++) {
                metaDatabase[metaI[x]].push(theIndex);
        }

        briefcase[msg.sender].push(theIndex);
        lastPaperAdded[msg.sender][contractLoc]=theIndex;
        for (uint y =0; y<goToLocation.length;y++){
          briefcase[goToLocation[y]].push(theIndex);
          lastPaperAdded[goToLocation[y]][contractLoc]=theIndex;
        }
        return theIndex;


    }

    /* Get last paper for a contract for a user;
    */

    function getLastPaperFromContract(address targetI, address contractI) constant returns (
      string name,
   bytes32 sig,
   uint256 database,
   uint time,
    address creator,
    address lawyer,
    address contractLoc){

      Paper data  = papers[lastPaperAdded[targetI][contractI]];
      sig=data.sig;
      name=data.name;
      database=data.database;
      time = data.time;
      creator = data.creator;
      lawyer = data.lawyer;
      contractLoc = data.contractLoc;

    }



    /* Copy data to another user Account
    _to the address where the data should go
    _index the index of the document

    */

    function copyPaper(address toI, uint256 indexI){
        if ( briefcase[msg.sender].length < indexI){
            briefcase[toI].push(briefcase[msg.sender][indexI]);
        }else {
            throw;
        }
    }

    /* Get's the paper in a readable format
    indexI = the index of the paper
    RETURN
    name = name of the doc
    sig = the hash of the document
    database = the database where the document is stored
    time = the time the doc was created
    creator = who created the document
    lawyer = the lawyer who authenticated the document

    */
    function getPaperQuick(uint256 indexI) constant returns (
      bytes32 sig,
      uint256 database

      ){

        Paper data  = papers[indexI];
        sig=data.sig;
        database=data.database;

    }

    function getPaper(uint256 indexI) constant returns (
        string name,
       bytes32 sig,
       uint256 database,
       uint time,
        address creator,
        address lawyer,
        address contractLoc,
        uint256 lastIndex){

          if (indexI<briefcase[msg.sender].length){

        Paper data  = papers[briefcase[msg.sender][indexI]];
        sig=data.sig;
        name=data.name;
        database=data.database;
        time = data.time;
        creator = data.creator;
        lawyer = data.lawyer;
        contractLoc = data.contractLoc;
        lastIndex = briefcase[msg.sender].length;
}else{
}


    }


    /* Get's the paper in a readable format
    metaI = the metadata required
    indexI = the index of the metadata in the array

    RETURN
    name = name of the doc
    sig = the hash of the document
    database = the database where the document is stored
    time = the time the doc was created
    creator = who created the document
    lawyer = the lawyer who authenticated the document

    */


    function getPaperFromMeta(uint256 metaI, uint256 indexI) constant returns (
      string text,
      bytes32 sig,
      uint256 database,
      uint time,
      address creator,
      address lawyer,
      address contractLoc){
    Paper data = papers[metaDatabase[metaI][indexI]];
    sig=data.sig;
    text=data.name;
    database=data.database;
    time = data.time;
    creator = data.creator;
    lawyer = data.lawyer;
    contractLoc = data.contractLoc;
    }

    /* This unnamed function is called whenever someone tries to send ether to it */
    function () {
        throw;     // Prevents accidental sending of ether
    }

/*
    function addSupervisor(address newSuper){
        if (godUser == 0x0){
            godUser = msg.sender;
            superVisor[msg.sender]=true;
            numberOfAdmins=numberOfAdmins+1;
            return;
        }

        if (godUser == msg.sender){
            if (superVisor[newSuper]!=true && numberOfAdmins < 5){
            superVisor[newSuper]=true;
            numberOfAdmins=numberOfAdmins+1;
            return;
            }
        }

        if (superVisor[msg.sender]==true){
            if (superVisor[newSuper]!=true){
              currentVotes.push(AdminAddVote(msg.sender,newSuper,0,0,now,false,true));
              ThereIsANewVote(newSuper,msg.sender,true,currentVotes.length-1);
            } else {
                throw;
            }
        } else{
            throw;
        }
    }




        function resolveSupervisorVote(uint256 index){
            if (currentVotes[index].creator != msg.sender){
                if (currentVotes[index].time != now  - (48 hours)){
                    if (currentVotes[index].resolved == false){
                        if (currentVotes[index].voteYes>currentVotes[index].voteNo){
                            if (currentVotes[index].deathOrBirth==false){
                                superVisor[currentVotes[index].newSupervisor]=false;
                                numberOfAdmins=numberOfAdmins-1;
                                NewSupervisor(currentVotes[index].newSupervisor);
                            }else{
                                superVisor[currentVotes[index].newSupervisor]=true;
                                numberOfAdmins=numberOfAdmins+1;
                                RemovedSupervisor(currentVotes[index].newSupervisor);
                            }
                        } else {
                            currentVotes[index].resolved = true;
                        }
                    } else {
                        throw;
                    }
                } else {
                    throw;
                }
            } else {
                throw;
            }
        }

        function supervisorVote(uint256 index, bool vote){
            if (superVisor[msg.sender]!=true ){
             throw;
            }

            if (index<currentVotes.length){
                if (currentVotes[index].alreadyVoted[msg.sender]!=true){
                    currentVotes[index].alreadyVoted[msg.sender]=true;
                    if (vote){
                        currentVotes[index].voteYes++;
                    }else{
                        currentVotes[index].voteNo++;
                    }
                }

            }else{
                throw;
            }
        }




        function removeSupervisor(address oldSuper){
            if (godUser == 0x0){
                godUser = msg.sender;
                superVisor[msg.sender]=true;
                numberOfAdmins=numberOfAdmins+1;
            }

            if (godUser == msg.sender){
                if (superVisor[oldSuper]==true && numberOfAdmins < 5){
                superVisor[oldSuper]=false;
                numberOfAdmins=numberOfAdmins-1;
                return;
                }
            }

            if (superVisor[msg.sender]==true){
                if (superVisor[oldSuper]!=true){
                  currentVotes.push(AdminAddVote(msg.sender,oldSuper,0,0,now,false,false));
                  ThereIsANewVote(oldSuper,msg.sender,false,currentVotes.length-1);
                } else {
                    throw;
                }
            } else{
                throw;
            }
        }



    */






}
