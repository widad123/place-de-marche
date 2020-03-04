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
        const networkData=PlaceDeMarche.networks[networkId];
        if (networkData) {
          const placeDeMarche = new web3.eth.Contract(
            PlaceDeMarche.abi,
            networkData && networkData.address,
          );
          
        setweb3(web3);
        setAccounts(accounts);
        setContract(placeDeMarche);
        }
      } catch (error) {
        alert(
          'failed to load web3, accounts, or marches, Check console for details',
        );
        console.error(error);
      }
    }
    init();
  },[]);

 
  useEffect(()=>{
    const load = async()=>{
      
    }
    if(typeof web3!=='undefined'
    && typeof accounts!=='undefined'
    && typeof contract!=='undefined'){
      load();
    }
  },[web3, accounts, contract]);


  if(typeof web3 ==='undefined'){
    return <div>Loading web3, accounts, and contract ...</div>;
  }

  return (
    <div className="App">
      <header className="App-header">
       
      </header>
    </div>
  );
}

export default App;
