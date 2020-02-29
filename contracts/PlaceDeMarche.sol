pragma solidity 0.6.2;

import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol';

contract placeDeMarche{
    
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
    uint256 frais=102;
    uint256 compteurIndice;

    event Transfer(address indexed from, address indexed to, uint256 value);
    
    enum Etat {OUVERTE, ENCOURS, FERMEE}
    Etat etat;
    
//constructor
    constructor()public{
        owner=msg.sender;
    }
    
    //l'etat de la demande

    modifier etatDemande(Etat _etat){
        require(etat == _etat,'pas possible');
        _;
    }
    
    //fonction pour passer à l'etat suivante
    function nextEtat()internal{
        etat=Etat(uint(etat)+1);
    }
    
    //passer à l'eta suivante apres l'execution de la fonction
    modifier nextEtatDemande(){
        _;
        nextEtat();
    }
 
 //fonction pour véridier si c'est un utilisateurs
modifier estUtilisateur(address _adress){
    bool estUtilisateur=listeUtilisateur[_adress].estUtilisateur;
     require(estUtilisateur,'pas utilisateur');
        estUtilisateur = true;
        _;
}

modifier chekDemande(uint256 _indice){
    bool estDemande=listeDemande[_indice].estDemande;
  require(estDemande,'pas Demande');
    estDemande=true;
        _;
}


modifier estCandidat(uint256 _indice,address _add){
    bool estCandidat = listeDemande[_indice].listeCandidats[_add].accepte;
     require(estCandidat,'pas Candidat');
        estCandidat = true;
        _;
}

modifier estEntreprise(uint256 _indice){
    address entreprise= listeDemande[_indice].entreprise;
    bool estEntreprise ;
     require(entreprise==msg.sender,'pas entreprise');
        estEntreprise= true;
        _;
}

    //inscrir un utilisateur
    function inscription (string memory nom,uint256 _experience)public{
        require(!listeUtilisateur[msg.sender].estUtilisateur);
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
    


function balanceOf()external view returns(uint256){
    return address(this).balance;
}

function payer(uint256 _somme) private{
    uint256 somme=_somme;
    require(msg.value==somme.mul(frais),'Pas assez de WEI');
    balance[owner]=balance[owner].add(msg.value);
}

function remunerer(uint256 _indice)private{
    uint256 remuniration=listeDemande[_indice].remuniration;
    balance[owner]=balance[owner].sub(remuniration);
    balance[msg.sender]=balance[msg.sender].add(remuniration);
    msg.sender.transfer(remuniration);
}

function ajouterDemande(string calldata description,uint256 miniReputation,uint256 _delai, uint256 remuniration) external payable estUtilisateur(msg.sender){
    payer(remuniration);
    uint256 startTime;
    Demande memory nouvelleDemande=Demande(msg.sender,_delai,startTime,miniReputation,remuniration,description,"",Etat.OUVERTE,true,false);
    listeDemande[indice]=nouvelleDemande;
    indice++;
    compteurIndice++;
}


function listerDemande () public view returns(string memory ,uint256){
    uint256 miniReputation;
    string memory description;
    for(uint256 i=0;i<compteurIndice;i++){
        miniReputation=listeDemande[i].miniReputation;
        description=listeDemande[i].description;
      return (description,miniReputation);
    }
}

function postuler(uint256 _indice) public estUtilisateur(msg.sender) chekDemande(_indice) etatDemande(Etat.OUVERTE) {
//avant tout faut verifier l'etat de la demande
    require(listeDemande[_indice].miniReputation<=listeUtilisateur[msg.sender].reputation);
    Utilisateur memory candidat=listeUtilisateur[msg.sender];
    listeDemande[_indice].listeCandidats[msg.sender]=candidat;
    //creation event pour prevenir recruteur
}


function accepterOffre(uint256 _indice,address _add) public estEntreprise(_indice) chekDemande(_indice) etatDemande(Etat.OUVERTE) nextEtatDemande {
   uint256 startTime=listeDemande[_indice].startTime=now;
   listeDemande[_indice].listeCandidats[_add].accepte=true;
       //envoi event au candidat
}




function checkDemande(uint256 _indice,address _add)private estEntreprise(_indice) estCandidat( _indice, _add) chekDemande(_indice) etatDemande(Etat.ENCOURS) returns(bool){
    uint256 startTime=listeDemande[_indice].startTime;
    uint256 delai=startTime+listeDemande[_indice].delai;
     if(delai<now){
       require(!listeDemande[_indice].estLivre);
           listeDemande[_indice].listeCandidats[_add].reputation--;
           //event informer candidat sanction
           return false;
     }else{
         return true;
     }
}

function livraison(string memory _lien,uint256 _indice) public estCandidat( _indice,msg.sender) chekDemande(_indice) etatDemande(Etat.ENCOURS) nextEtatDemande{
    require(!listeDemande[indice].estLivre,'deja livre');
    string memory lien = _lien;
    listeDemande[_indice].lien=lien;//faut hacher le lien
    //event pour prevenir lentreprise
    remunerer(_indice);
    listeDemande[_indice].listeCandidats[msg.sender].reputation++;
   listeDemande[indice].estLivre=true;
}


}