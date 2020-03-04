import React,{useState, useEffect}from 'react';
import PlaceDeMarche from './contracts/placeDeMarche.json';
import getWeb3 from './getWeb3';
import './App.css';

function App (){
  const [balance,setbalance ]=useState(undefined);
  const [web3,setweb3]=useState(undefined);
  const [accounts,setAccounts]=useState([]);
  const [contract,setContract]=useState([]);

  useEffect(()=>{
    const init = async()=>{
      try {
        const web3=await getWeb3();
        const accounts=await web3.eth.getAccounts();
        const networkId= await web3.eth.net.getId();
        const deployedNetwork=PlaceDeMarche.networks[networkId];
        const contract = new web3.eth.Contract(
          PlaceDeMarche.abi,
          deployedNetwork && deployedNetwork.address,
        );

        setweb3(web3);
        setAccounts(accounts);
        setContract(contract);
      } catch (error) {
        alert(
          'failed to load web3, accounts, or contracts, Check console for details',
        );
        console.error(error);
      }
    }
    init();
  },[]);

  useEffect(()=>{
    const load = async()=>{
      const balance= await contract.methods.balanceOf().call();
      setbalance(balance);
    }
    if(typeof web3!=='undefined'
    && typeof accounts!=='undefined'
    && typeof contract!=='undefined'){
      load();
    }
  },[web3, accounts, contract]);

  if(typeof web3!=='undefined'){
    return <div>Loading web3, accounts, and contracts ...</div>;
  }

  return (
    <div className="App">
      <header className="App-header">
       balance is:  {balance}
      </header>
    </div>
  );
}

export default App;
