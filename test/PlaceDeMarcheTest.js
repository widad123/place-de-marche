const PlaceDeMarche = artifacts.require("PlaceDeMarche");
const contract = require('@openzeppelin/test-environment');

contract('PlaceDeMarche',()=>{
    it('verifie si le contrat se deploie',async()=>{
const placeDeMarche= await PlaceDeMarche.deployed();
console.log(placeDeMarche.address);
assert(placeDeMarche.address !== '');
    });
});