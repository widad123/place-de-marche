pragma solidity 0.5.16;

import '@openzeppelin\contracts\math\SafeMath.sol';

contract PlaceDeMarche is {
    using SafeMath for uint256;
       
        
    struct Utilisateur{
        uint256 reputation;
        string nom;
        bool estUtilisateur;
        bool accepte;
        
    }
    
    struct Demande{
            address entreprise;
            uint256 delai;
            uint256 startTime;
            uint256 miniReputation;
            uint256 remuniration;
            string description;
            string lien;
            Etat etat;
            mapping(address=>Utilisateur) listeCandidats;
            bool estDemande;
            bool estLivre;
            
    }
    
       
    address owner;
    mapping(address =>uint256)public balance;
    mapping (address=>Utilisateur) public listeUtilisateur;
    mapping (uint256=>Demande) public listeDemande;
    
    uint256 indice;
    uint256 frais=1.02 ether;
    uint256 compteurIndice;

    
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    enum Etat {OUVERTE, ENCOURS, FERMEE}
    Etat etat;

    
    modifier etatDemande(Etat _etat){
        require(etat == _etat,'pas possible');
        _;
    }
    
    function nextEtat()internal{
        etat=Etat(uint(etat)+1);
    }
    
    modifier nextEtatDemande(){
        _;
        nextEtat();
    }
 

    constructor()public{
        owner=msg.sender;
    }

    //inscrir un utilisateur
    function inscription (string memory nom,uint256 _experience)public pasUtilisateur(msg.sender){
        uint256 reputation=experience(_experience);
       Utilisateur memory nouveauUtilisateur=Utilisateur(reputation,nom,true,false);
       listeUtilisateur[msg.sender]=nouveauUtilisateur;
      //  utilisateurs.push(msg.sender);
    }

//pour donner une reputation en fonction de l'experience
    function experience(uint256 experience)internal pure returns(uint256){
        uint256 exp;
        if(experience<2){
           exp=1;
        }else if(experience>=2 && experience<5){
            exp=3;
        }else if(experience>=5){
            exp=5;
        }
         return exp;
    }
    
//fonction pour véridier si c'est un utilisateurs
modifier estUtilisateur(address _adress){
   require(listeUtilisateur[_adress].estUtilisateur,"Already User");
   _;  
}

modifier pasUtilisateur(address _adress){
   require(!listeUtilisateur[_adress].estUtilisateur,"Already User");
   _;  
}

function balanceOf()external view returns(uint256){
    return address(this).balance;
}


modifier chekDemande(uint256 _indice){
  require(listeDemande[_indice].estDemande);
        _;
}


function payer(uint256 _somme) private{
    uint256 somme=_somme;
    require(msg.value==somme.mul(frais),'Pas assez de ETH');
    balance[owner]=balance[owner].add(msg.value);
}

function remunerer(uint256 _indice)private{
    uint256 remuniration=listeDemande[_indice].remuniration;
    balance[owner]=balance[owner].sub(remuniration);
    balance[msg.sender]=balance[msg.sender].add(remuniration);
    msg.sender.transfer(remuniration);
}

function ajouterDemande(string calldata description,uint256 miniReputation,uint256 _delai, uint256 remuniration) external payable estUtilisateur(msg.sender){
    require(msg.data.length == 0);
    payer(remuniration);
    uint256 startTime;
    Demande memory nouvelleDemande=Demande(msg.sender,_delai,startTime,miniReputation,remuniration,description,"",Etat.OUVERTE,true,false);
    listeDemande[indice]=nouvelleDemande;
    indice++;
    compteurIndice++;
}

function listerDemande()public view{
    for(uint256 i=0;i<compteurIndice;i++){
        listeDemande[i];
    }
}

function postuler(uint256 _indice) public estUtilisateur(msg.sender) chekDemande(_indice) etatDemande(Etat.OUVERTE) {
//avant tout faut verifier l'etat de la demande
    require(listeDemande[_indice].miniReputation<=listeUtilisateur[msg.sender].reputation);
    Utilisateur memory candidat=listeUtilisateur[msg.sender];
    listeDemande[_indice].listeCandidats[msg.sender]=candidat;
    //creation event pour prevenir recruteur
}


function accepterOffre(uint256 _indice,address _add) public estUtilisateur(msg.sender) chekDemande(_indice) etatDemande(Etat.OUVERTE) nextEtatDemande {
   uint256 startTime=listeDemande[_indice].startTime=now;
   listeDemande[_indice].listeCandidats[_add].accepte=true;
       //envoi event au candidat
}



function checkDemande(uint256 _indice,address _add)private  estUtilisateur(msg.sender) chekDemande(_indice) etatDemande(Etat.ENCOURS) returns(bool){
    uint256 startTime=listeDemande[_indice].startTime;
    uint256 delai=startTime+listeDemande[_indice].delai;
     if(delai<now){
       if(!listeDemande[indice].estLivre){
           listeDemande[_indice].listeCandidats[_add].reputation--;
           //event informer candidat sanction
       }
     }
}


function livraison(string memory _lien,uint256 _indice) public estUtilisateur(msg.sender) chekDemande(_indice) etatDemande(Etat.ENCOURS) nextEtatDemande{
    require(!listeDemande[indice].estLivre);
    require(msg.sender==listeDemande[indice].entreprise);
    string memory lien = _lien;
    listeDemande[_indice].lien=lien;//faut hacher le lien
    //event pour prevenir lentreprise
    remunerer(_indice);
    listeDemande[_indice].listeCandidats[msg.sender].reputation++;
   listeDemande[indice].estLivre=true;
}


}