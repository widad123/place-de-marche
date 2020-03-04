import React,{useState, useEffect}from 'react';
import placeDeMarche from './contracts/placeDeMarche.json';
import getWeb3 from './getWeb3';
import './App.css';

function App (){
  const [balance,setbalance ]=useState(undefined);
  const [web3,setweb3]=useState(undefined);
  const [accounts,setAccounts]=useState([]);
  const [marche,setmarche]=useState([]);

  useEffect(()=>{
    const init = async()=>{
      try {
        const web3=await getWeb3();
        const accounts=await web3.eth.getAccounts();
        const networkId= await web3.eth.net.getId();
        const networkData=placeDeMarche.networks[networkId];
        if (networkData) {
          const marche = new web3.eth.Contract(
            placeDeMarche.abi,
            networkData && networkData.address,
          );
          
        setweb3(web3);
        setAccounts(accounts);
        setmarche(marche);
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
      const response= await marche.methods.balanceOf().call();
      setbalance(response);
    }
    if(typeof web3!=='undefined'
    && typeof accounts!=='undefined'
    && typeof marche!=='undefined'){
      load();
    }
  },[web3, accounts, marche]);

  if(typeof web3 ==='undefined'){
    return <div>Loading web3, accounts, and marches ...</div>;
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
