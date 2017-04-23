/*globals $, SimpleStorage, document*/


function enthalpy(dataLength)
{
  var text = "";
  var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

  for( var i=0; i < dataLength; i++ )
  text += possible.charAt(Math.floor(Math.random() * possible.length));

  return text;
}

//var serverAddress = "http://stonepapergaestorage.appspot.com";
var serverAddress = "http://localhost:41080";

// ===========================
// Blockchain example
// ===========================
$(document).ready(function() {


  var addressToName={};
  var addressToIndex={};

  function generateSig(data){
    return "<img width=600 src='"+ data.Signiture+ "'>";
  }

  function generateContractSign(data){
    var signatureHtml = '<p>Sign Here</p><div class="Center"><canvas style="border: black;border-style: double;width:100%;min-height:150px" id="Supplier"></canvas><br><button class="clearSupplier btn btn-primary" id="clearSupplier">Clear</button></div>';

    return "<div>"+data.ContractText+"</div>"+signatureHtml+"<div>"+'<button class="set btn btn-primary" id="SendPlay">Send This Data To Organizer</button>'+"</div>";

  }
  function generateDescription(data){
    return "<div>"+data.ContractText+"</div>";

  }

  function generateHackathon(data){

    return "<div>"+data.Title+"</div><div>"+data.ContractText+"</div>";



      //return "<div>"+ data.Title+ "</div>" + "<div>"+ data.Affidavit+ "</div>" + "<div>Contract Created On - "+ data.DateCreated+ "</div>";

  }

  var countApprove=0;
  var approvedList=[];

  var getAllApproved = function(index){
    HackathonPrime.getHackathonApproved(index,{gas: 3000000}).then(function(value){
      if (value[0]=="0x0000000000000000000000000000000000000000"){
        console.log("end");
        } else {
        if (value[1]){
          if (value[5] in addressToName){
            $("#HackPrimeList").append($('<option></option>').attr("value",value[5]).text(addressToName[value[5]]).attr("id",value[5]));
          }else{
            $("#HackPrimeList").append($('<option></option>').attr("value",value[5]).text(value[5]).attr("id",value[5]));
          }
        }
        countApprove++;
        getAllApproved(countApprove);
      }
    },function(value){
      console.log(value);
    });
  };







  //Run At Start up to set up all Hackathons
  var countMe=0;
  var quickList;
  var getAllHacks = function(index){
    HackathonPrime.getHackathon(index,{gas: 3000000}).then(function(value){
      if (value[0]=="0x0000000000000000000000000000000000000000"){
        console.log("end");
        } else {
          addressToIndex[value[5]]=countMe;
        if (value[5] in addressToName){
          $("#HackPrimeStorage").append($('<option></option>').attr("value",value[5]).text(addressToName[value[5]]).attr("id",value[5]));
        }else{
          $("#HackPrimeStorage").append($('<option></option>').attr("value",value[5]).text(value[5]).attr("id",value[5]));
        }
        quickList[countMe]=value;
        countMe++;
        getAllHacks(countMe);
      }
    },function(value){
      console.log(value);
    });
  };

  var currentlySelectApproveHackathon;

  $('#HackPrimeStorage').on('change', function(){
    var theIndex = this.value;
    var theID = this.id;
    if (theID == "Choose Hackathon"){return;}
    var theHackathon = new EmbarkJS.Contract({
      abi: Hackathon.abi,
      address: this.value
    });

    currentlySelectApproveHackathon=this.value;

    theHackathon.describe(StonePaper.address).then(function(value){
      var testIfThere = $("#"+theIndex);
      testIfThere.text(value[0]);
      addressToName[theIndex]=value[0];

      StonePaper.getPaperQuick(value[1].toNumber(),{gas: 3000000}).then(function(value){

        $.get(serverAddress+"/GrabInfo?Key="+value[0],
        {},
        function(data){
          var testTheFuckingThing = $("#HackPrimeStorageR");
          $("#HackPrimeStorageR").html(generateHackathon(data));
          console.log("HERE");
          $("#HackPrimeStorageR").append($('<input class="btn-primary" type="button" value="Approve" id="ApproveHack">'));
          $('#HackPrimeStorageR').on('click', '#ApproveHack', function(){
            HackathonPrime.approveEntry(addressToIndex[currentlySelectApproveHackathon],true,{gas: 3000000}).then(function(value){
              $("#HackPrimeApproveR").html("This Hackathon has been listed publically.");
            });
            console.log("Approved");
          });
          $("#HackPrimeStorageR").append($('<input class="btn-primary" type="button" value="Disapproved" id="DisapprovedHack">'));
          $('#HackPrimeStorageR').on('click', '#DisapprovedHack', function(){
            HackathonPrime.approveEntry(addressToIndex[currentlySelectApproveHackathon],false,{gas: 3000000}).then(function(value){
              $("#HackPrimeApproveR").html("This Hackathon has delisted.");
            });
            console.log("Not Approved");
          });
        });


      }).then(function(value){

      });
    });
  });


  $("#GetHacksPrimeB").click(function() {
    countMe=0;
    quickList=[];
    $("#HackPrimeStorage").empty();
    $("#HackPrimeStorage").append($('<option></option>').attr("value","Choose Hackathon").text("Choose Hackathon").attr("id","Choose Hackathon"));
    getAllHacks(0);

  });


  $("#HackPrimeListB").click(function() {
    countApprove=0;
    approvedList=[];
    $("#HackPrimeList").empty();
    $("#HackPrimeList").append($('<option></option>').attr("value","Choose Hackathon").text("Choose Hackathon").attr("id","Choose Hackathon"));
    getAllApproved(0);
  });






  var currentCreatedHack;

  $("#CreateHackFactB").click(function() {
    Hackathon.deploy([], {gas: 3000000}).then(function(newContract) {
      currentCreatedHack = newContract;
      $("#CreateHackFactR").html("Your Hackathon has been created at the address: " + newContract.address );
      $("#AddressHackFact").val(newContract.address);
    });

  });



  $("#NameHackFactB").click(function() {
    currentCreatedHack.nameHackathon(StonePaper.address,$('#NameHackFact').val(), {gas: 3000000}).then(function(){
      $("#NameHackFactR").html("Your Hackathon has been updated with the name:" + $('#NameHackFact').val());
      console.log("Name Changed on Hackathon");
    },function(){
      console.log("Error Name Not Changed");
    });
  });

  $("#DescriptionHackFactB").click(function() {
    var aDataZ = JSON.stringify(
      {
        Title:"Hackathon Description for " + $('#NameHackFact').val() + " at address " + currentCreatedHack.address,
        ContractText:$('#DescriptionHackFact').val(),
        Address:currentCreatedHack.address,
        DateCreated:Date(),
        Enthalpy:enthalpy(32)
      }
    );

    $.post( serverAddress+"/GrabInfo", {
      ID:aDataZ,Key:web3.sha3(aDataZ)
    }, function(data){
      currentCreatedHack.setDescriptionWithPaper(StonePaper.address,"Description for:"+currentCreatedHack.address,web3.sha3(aDataZ), 0,[],currentCreatedHack.address,[currentCreatedHack.address], {gas: 3000000}).then(function(){
        $("#DescriptionHackFactR").html("Your Hackathon has been updated with a new description");
      },function(){
        alert("Something Went Wrong");
      });
    } );
  });

  $("#ReleaseHackFactB").click(function() {
    var aData = JSON.stringify(
      {
        Title:"Hackathon Release for " + $('#NameHackFact').val() + " at address " + currentCreatedHack.address,
        ContractText:$('#ReleaseHackFact').val(),
        Address:currentCreatedHack.address,
        DateCreated:Date(),
        Enthalpy:enthalpy(32)
      }
    );

    $.post( serverAddress+"/GrabInfo", {
      ID:aData,Key:web3.sha3(aData)
    }, function(data){
      currentCreatedHack.setReleaseWithPaper(StonePaper.address,"Description for:"+currentCreatedHack.address,web3.sha3(aData), 0,[],currentCreatedHack.address,[currentCreatedHack.address], {gas: 3000000}).then(function(){
        $("#ReleaseHackFactR").html("Your Hackathon has been updated with a new Release");
      },function(){
        alert("Something Went Wrong");
      });
    } );
  });

  $("#EtherHackFactB").click(function() {
    $("#EtherHackFactR").html("The amount of Ether required for people to apply has changed");


  });

  $("#PrimeHackFactB").click(function() {
    HackathonPrime.addEntry(currentCreatedHack.address,0,0,{gas: 3000000}).then(function(){
      $("#PrimeHackFactR").html("Your Hackathon has been deployed to the Hack Prime");
    },function(){
      console.log("Something Went Wrong");
    });
  });




  var playHackList;
  var countPlayHack;

  var getAllSelect = function(index){
    HackathonPrime.getHackathonApproved(index,{gas: 3000000}).then(function(value){
      if (value[0]=="0x0000000000000000000000000000000000000000"){
        console.log("end");
        } else {
        if (value[1]){
          if (value[5] in addressToName){
            $("#playHackSelS").append($('<option></option>').attr("value",value[5]).text(addressToName[value[5]]).attr("id",value[5]+"s"));
          }else{
            $("#playHackSelS").append($('<option></option>').attr("value",value[5]).text(value[5]).attr("id",value[5]+"s"));
          }
        }
        countPlayHack++;
        getAllSelect(countPlayHack);
      }
    },function(value){
      console.log(value);
    });
  };

  $("#playHackSelB").click(function() {
    countPlayHack=0;
    playHackList=[];
    $("#playHackSelS").empty();
    $("#playHackSelS").append($('<option></option>').attr("value","Choose Hackathon").text("Choose Hackathon").attr("id","Choose Hackathon"));
    getAllSelect(0);
  });


  var currentlySelectPlayHackathon;



  $("#AreAcceptedB").click(function() {
    currentlySelectPlayHackathon.areYouApproved(0,{gas: 3000000}).then(function(data){
      if (data===true){
        $("#AreAcceptedR").html("You've Been Accepted");

      } else {
        $("#AreAcceptedR").html("I'm sorry you haven't been accepted yet.");
      }

    });

  });


  $('#playHackSelS').on('change', function(){
    var theIndex = this.value;
    var theID = this.id;
    if (theID == "Choose Hackathon"){return;}

    var theHackathon = new EmbarkJS.Contract({
      abi: Hackathon.abi,
      address: this.value
    });

    currentlySelectPlayHackathon=theHackathon;

    theHackathon.describe(StonePaper.address).then(function(value){
      var testIfThere = $("#"+theIndex+"s");
      testIfThere.text(value[0]);
      addressToName[theIndex]=value[0];

      StonePaper.getPaperQuick(value[1].toNumber(),{gas: 3000000}).then(function(value){

        $.get(serverAddress+"/GrabInfo?Key="+value[0],
        {},
        function(data){
          var testTheFuckingThing = $("#HackPrimeStorageR");
          $("#playHackSelR").html(generateHackathon(data));
        });


      }).then(function(value){

      });
    });
  });

  var canvasS;
  var signaturePadS2;

  $("#playHackSignUp").click(function() {
    var userAddress = $("#playHackSelS option:selected");
    currentlySelectPlayHackathon.describe(0,{gas: 3000000}).then(function(data){
      StonePaper.getPaperQuick(data[2],{gas: 3000000}).then(function(value){
        $.get(serverAddress+"/GrabInfo?Key="+value[0],
        {},
        function(data){
          $("#ContractView").html(generateContractSign(data));
          var dataContractHolderStatic = data.ContractText;
            setTimeout(function(){

              canvasS = document.getElementById('Supplier');
              signaturePadS2 = new SignaturePad(canvasS);

              var ratio = Math.max(window.devicePixelRatio || 1,1);
              var allCanvas = [canvasS];



              $( "#SendPlay" ).click(function( event ) {
                event.preventDefault();
                  var aDataX = JSON.stringify(
                    {
                      Title:'Application',
                      Contract:dataContractHolderStatic,
                      Signiture:signaturePadS2.toDataURL(),
                      DateCreated:Date(),
                      Enthalpy:enthalpy(32)
                    }
                  );
                  $.post( serverAddress+"/GrabInfo", {
                    ID:aDataX,Key:web3.sha3(aDataX)
                  }, function(data){
                    currentlySelectPlayHackathon.apply(StonePaper.address,web3.sha3(aDataX),0,[],[], {gas: 3000000}).then(function(data){
                      alert("Application Sent");
                      $("#ContractView").html("");

                    });

                  } );
              });





              $( "#clearSupplier" ).click(function( event ) {
                event.preventDefault();
                signaturePadS2.clear();
              });



              for (var i =0; i<allCanvas.length;i++){
                if (!allCanvas[i]){continue;}
                allCanvas[i].width=allCanvas[i].offsetWidth * ratio;
                allCanvas[i].height = allCanvas[i].offsetHeight * ratio;
                allCanvas[i].getContext("2d").scale(ratio,ratio);
              }
            },1000);







        });
      });


    });

    //currentlySelectPlayHackathon.getTeam(index,{gas: 3000000}).then(function(value)

    return;

  });


  var getAllPeople = function(index){
    var indexHolder = index;
    currentlySelectPlayHackathon.getPeople(index,{gas: 3000000}).then(function(value){
      if (value[2]){
        console.log("End");
      }else{
        if (value[0] in addressToName){
          $("#PlayPeople1").append($('<option></option>').attr("value",value[0]).text(addressToName[value[0]]).attr("id",value[0]).attr("indexC",indexHolder));
        }else{
          $("#PlayPeople1").append($('<option></option>').attr("value",value[0]).text(value[0]).attr("id",value[0]).attr("indexC",indexHolder));
        }
        indexHolder++;
        getAllPeople(indexHolder);
      }
  });
};

  var teamDict = {};

  var getAllTeams = function(index){
    var indexHolder = index;
    currentlySelectPlayHackathon.getTeam(index,{gas: 3000000}).then(function(value){
      if (value[5]){
        console.log("end");
        } else {
          teamDict[indexHolder]=value;
            $("#teamSelS").append($('<option></option>').attr("value",indexHolder).text(value[2]).attr("id",indexHolder+"_team"));
            $("#teamSelS_2").append($('<option></option>').attr("value",indexHolder).text(value[2]).attr("id",indexHolder+"_team"));

        indexHolder++;
        getAllTeams(indexHolder);
      }
    },function(value){
      console.log(value);
    });
  };

  $("#CastAVote").click(function(){
    console.log("Working");
    var userAddress = $("#teamSelS_2 option:selected");
    currentlySelectPlayHackathon.vote(userAddress.index(),{gas: 3000000}).then(function(value){
      alert("You Voted for "+userAddress.text());

    }).catch(function(){
      alert("You Already Voted");
    });
  });

  $("#CountVotes").click(function(){
    currentlySelectPlayHackathon.calculateVotes({gas: 3000000}).then(function(value){


      var w1 = 0;
      var i1 = 0;
      var w2 = 0;
      var i2 = 0;
      var w3 = 0;
      var i3 = 0;

      for (var counter = 0; counter< value.length; counter++){
        var voteVal = value[counter].toNumber();
        if (voteVal>w3){
          i3 = counter;
          w3 = voteVal;
        }

        if (w3>w2){
          var ip = i2;
          var wp = w2;

          w2=w3;
          i2=i3;

          i3=ip;
          w3=wp;
        }

        if (w2>w1){
          var ipX = i2;
          var wpX = w2;

          w2=w1;
          i2=i1;

          i1=ipX;
          w1=wpX;
        }



      }


      $("#CountVotesR").html("The Winner is " + teamDict[i1][2]);
      console.log(teamDict);

    });


  });


  function createTeamSelectors(){
    countTeams=0;
    teamList=[];
    $("#teamSelS").empty();
    $("#teamSelS_2").empty();
    getAllTeams(0);


  }


  $("#GrabTeamB").click(function(){
    createTeamSelectors();
  });

  var currentlySelectTeam=0;

  $('#teamSelS').on('change', function(){
    var theIndex = this.value;
    var theID = this.id;
    if (theIndex == "0"){return;}
    var theValue = teamDict[theIndex][3].toNumber();
    if (theValue==0){
      $("#TeamDescriptionR").html("");
      return;
    }


    StonePaper.getPaperQuick(teamDict[theIndex][3].toNumber(),{gas: 3000000}).then(function(value){

      $.get(serverAddress+"/GrabInfo?Key="+value[0],
      {},
      function(data){
        $("#TeamDescriptionR").html(generateDescription(data));//generateHackathon(data));
        $("#DescriptionTeam").html(data.ContractText);
      });
    });

    currentlySelectTeam=this.value;
  });


  $("#ApprovePeopleS").click(function(){
    //countTeams=0;
    //teamList=[];
    $("#PlayPeople1").empty();
    $("#PlayPeople1").append($('<option></option>').attr("value","Choose A Person").text("Choose A Person").attr("id","Choose A Person"));
    getAllPeople(0);


  });

  $('#PlayPeople1').on('change', function(){
    var theIndex = this.value;
    var theID = this.id;
    var id = this.selectedIndex-1;
    if (theID == "Choose Hackathon"){return;}
    console.log("Changed");
    currentlySelectPlayHackathon.getPeople(id,{gas: 3000000}).then(function(value){
      StonePaper.getPaperQuick(value[3].toNumber(),{gas: 3000000}).then(function(value){
        $.get(serverAddress+"/GrabInfo?Key="+value[0],
        {},
        function(data){
          $("#SigPoint").html(generateSig(data));
        });

      });

    });


  });

  $("#PersonApprove").click(function(){
    var userAddress = $("#PlayPeople1 option:selected");
    currentlySelectPlayHackathon.verifyPeople(0,{gas: 3000000}).then(function(data){
      console.log("Worked");
    });
  });

  $("#CreateTeamB").click(function(){
    currentlySelectPlayHackathon.createTeam($('#CreateTeamT').val(),{gas: 3000000}).then(function(data){
      console.log("Team Created");
    });

  });


  $("#TeamAddressB").click(function(){

    currentlySelectPlayHackathon.addMember($("#TeamAddress").val(),{gas: 3000000}).then(function(data){
      $("#TeamAddressR").html("A Member has been added you your team");
    });
  });




  $("#DescriptionTeamB").click(function(){

    var aData = JSON.stringify(
      {
        Title:"Team Description",
        ContractText:$('#DescriptionTeam').val(),
        Address:currentlySelectPlayHackathon.address,
        DateCreated:Date(),
        Enthalpy:enthalpy(32)
      }
    );

    $.post( serverAddress+"/GrabInfo", {
      ID:aData,Key:web3.sha3(aData)
    }, function(data){
      currentlySelectPlayHackathon.updateDescription(web3.sha3(aData),[],StonePaper.address,{gas: 3000000}).then(function(data){
        $("#DescriptionTeamR").html("Your Team has been updated with a new description");
      },function(){
        alert("Something Went Wrong");
      });
    } );
  });












});
