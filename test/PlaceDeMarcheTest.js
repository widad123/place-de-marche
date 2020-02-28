const PlaceDeMarche = artifacts.require("PlaceDeMarche");

contract('PlaceDeMarche',()=>{
    it('verifie si le contrat se deploie proprement',async()=>{
const placeDeMarche= await PlaceDeMarche.deployed();
console.log(placeDeMarche.address);
assert(placeDeMarche.address !== '');
    });
});