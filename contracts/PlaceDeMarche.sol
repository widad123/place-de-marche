pragma solidity 0.6.2;

import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol';

contract placeDeMarche{
    
      using SafeMath for uint256;
    
    struct Utilisateur{
        uint256 reputation;
        string nom;
        bool estUtilisateur;
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
            mapping(address=>bool) listeCandidats;
            bool estDemande;
            bool estLivre;
    }
    
    address owner;
    mapping(address =>uint256)public balance;
    mapping (address=>Utilisateur) public listeUtilisateur;
    mapping (uint256=>Demande) public listeDemande;
    
    uint256 indice;
    uint256 decimal=100;
    uint256 frais=102;
    uint256 compteurIndice;

    event OffreAccepte(uint256 _indice,address _add);
    
    enum Etat {OUVERTE, ENCOURS, FERMEE}
    Etat etat;
    
//constructor
    constructor()public{
        owner=msg.sender;
    }
    
    //l'etat de la demande

    modifier etatDemande(uint256 _indice,Etat _etat){
        require(listeDemande[_indice].etat == _etat,'pas possible');
        _;
    }
    
    //fonction pour passer à l'etat suivante
    function changeEtat(uint256 _indice,Etat _etat)internal{
        listeDemande[_indice].etat=_etat;
    }
    
    //passer à l'eta suivante apres l'execution de la fonction
    modifier nextEtatDemande(uint256 _indice,Etat _etat){
        _;
        changeEtat(_indice,_etat);
    }
 
 //fonction pour véridier si c'est un utilisateurs
modifier estUtilisateur(address _adress){
     require(listeUtilisateur[_adress].estUtilisateur,'pas utilisateur');
  //      estUtilisateur = true;
        _;
}

modifier chekDemande(uint256 _indice){
  require(listeDemande[_indice].estDemande,'pas Demande');
  //  estDemande=true;
        _;
}


modifier estCandidat(uint256 _indice,address _add){
     require(listeDemande[_indice].listeCandidats[_add],'pas Candidat');
 //       estCandidat = true;
        _;
}

modifier estEntreprise(uint256 _indice){
     require(listeDemande[_indice].entreprise==msg.sender,'pas entreprise');
   //     estEntreprise= true;
        _;
}

modifier estAccepte (uint256 _indice,address _add){
       require(listeDemande[_indice].listeCandidats[_add],'Vous netes pas accepté');
       _;
}

    //inscrir un utilisateur
function inscription (string memory nom,uint256 _experience)public{
        require(!listeUtilisateur[msg.sender].estUtilisateur);
        uint256 reputation=experience(_experience);
       Utilisateur memory nouveauUtilisateur=Utilisateur(reputation,nom,true);
       listeUtilisateur[msg.sender]=nouveauUtilisateur;
      //  utilisateurs.push(msg.sender);
    }

//pour donner une reputation en fonction de l'experience
function experience(uint256 _experience)internal pure returns(uint256){
        uint256 exp;
        if(_experience<2){
           exp=1;
        }else if(_experience>=2 && _experience<5){
            exp=3;
        }else if(_experience>=5){
            exp=5;
        }
         return exp;
    }
    

function balanceOf()external view returns(uint256){
    return address(this).balance;
}

function payer(uint256 _somme) private{
   uint256 somme=(_somme.mul(frais)).div(decimal);
    require(msg.value>=somme,'Pas assez de WEI');
    balance[owner]=balance[owner].add(msg.value);
}

function remunerer(uint256 _indice)private{
    uint256 remuniration=listeDemande[_indice].remuniration;
    balance[owner]=balance[owner].sub(remuniration);
    balance[msg.sender]=balance[msg.sender].add(remuniration);
    msg.sender.transfer(remuniration);
}

function ajouterDemande(string calldata description,uint256 miniReputation,uint256 _delai, uint256 remuniration)
    external
    payable 
    estUtilisateur(msg.sender){
        payer(remuniration);
        uint256 startTime;
        Demande memory nouvelleDemande=Demande(msg.sender,_delai,startTime,miniReputation,remuniration,description,"",Etat.OUVERTE,true,false);
        listeDemande[indice]=nouvelleDemande;
        indice++;
        compteurIndice++;
    }

function listerDemande () 
        public 
        view
        returns(string memory ,uint256)
        {
            uint256 miniReputation;
            string memory description;
            for(uint256 i=0 ; i<compteurIndice ; i++){
                miniReputation=listeDemande[i].miniReputation;
                description=listeDemande[i].description;
              return (description,miniReputation);
            }
        }

function postuler(uint256 _indice) 
        public 
        view
        estUtilisateur(msg.sender) 
        chekDemande(_indice)
        etatDemande( _indice,Etat.OUVERTE)
        {
            require(msg.sender!=listeDemande[_indice].entreprise,'vous etes entreprise');
        //avant tout faut verifier l'etat de la demande
            require(listeDemande[_indice].miniReputation<=listeUtilisateur[msg.sender].reputation,'pas assez dexperience');
            listeDemande[_indice].listeCandidats[msg.sender];
            //creation event pour prevenir recruteur
        }


function accepterOffre(uint256 _indice,address _add)
        public
        estEntreprise(_indice) 
        estCandidat(_indice,_add)
        chekDemande(_indice)
        etatDemande( _indice,Etat.OUVERTE)
        nextEtatDemande(_indice,Etat.ENCOURS)
        {
           listeDemande[_indice].startTime=now;
            listeDemande[_indice].listeCandidats[_add]=true;
                emit OffreAccepte(_indice, _add);
        }



function checkDemande(uint256 _indice,address _add)
        public
        estEntreprise(_indice) 
        estAccepte( _indice, _add)
        chekDemande(_indice)
        etatDemande( _indice,Etat.ENCOURS)
        returns(bool)
    {
    uint256 startTime=listeDemande[_indice].startTime;
    uint256 delai = startTime+listeDemande[_indice].delai;
     if(delai<now){
       require(!listeDemande[_indice].estLivre);
           listeUtilisateur[_add].reputation--;
           return false;
     }else{
         return true;
     }
}

function livraison(string memory _lien,uint256 _indice)
        public
        estAccepte( _indice,msg.sender) 
        chekDemande(_indice) 
        etatDemande( _indice,Etat.ENCOURS)
        nextEtatDemande(_indice,Etat.FERMEE)
        {
            require(!listeDemande[indice].estLivre,'deja livre');
            string memory lien = _lien;
            listeDemande[_indice].lien=lien;//faut hacher le lien
            remunerer(_indice);
            listeUtilisateur[msg.sender].reputation++;
           listeDemande[_indice].estLivre=true;
        }


}