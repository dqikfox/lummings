(function(root){
 'use strict';
 function create({fetcher=root.fetch.bind(root),legacyStorage,onChange=()=>{}}={}){
  let data=root.LummingFamilyStore.fresh(),revision=-1,token='',directory='',warning='',pending=0,failed=false,ready=false;
  let queue=Promise.resolve();
  const clone=value=>JSON.parse(JSON.stringify(value));
  async function request(path,body){
   const response=await fetcher(path,body===undefined?{cache:'no-store'}:{method:'POST',headers:{'Content-Type':'application/json','X-Lummings-Token':token},body:JSON.stringify(body),keepalive:false});
   let result;try{result=await response.json();}catch(e){throw Error('Start the Lummings project server. The old static preview cannot save family data.');}
   if(!response.ok)throw Error(result.error||'The local project server could not save this change.');
   return result;
  }
  function announce(){onChange();}
  const api={
   get data(){return data;},get profile(){return data.profiles.find(p=>p.id===data.active);},get warning(){return warning;},get directory(){return directory;},get ready(){return ready;},get pending(){return pending;},get failed(){return failed;},
   async load(){
    let result=await request('/api/family');token=result.token;
    let raw=null;try{raw=legacyStorage?.getItem(root.LummingFamilyStore.KEY);}catch(e){warning='Browser storage could not be inspected for old saves.';}
    if(raw){
     result=await request('/api/family/migrate',{data:JSON.parse(raw)});
     // The migration response is sent only after the SQLite transaction commits.
     try{legacyStorage.removeItem(root.LummingFamilyStore.KEY);}catch(e){warning='Browser saves were imported, but the old browser copy could not be removed. Importing it again is safe.';}
    }
    data=result.data;revision=result.revision;directory=result.directory;ready=true;announce();return api;
   },
   save(){
    if(!ready||failed){warning=warning||'Not saved. Reconnect to the project server before continuing.';announce();return Promise.resolve(false);}
    const snapshot=clone(data);snapshot.saving=true;pending++;announce();
    const operation=queue.then(async()=>{
     if(failed){pending--;announce();return false;}
     try{const result=await request('/api/family',{revision,data:snapshot});revision=result.revision;warning='';return true;}
     catch(e){failed=true;warning='Not saved: '+e.message;return false;}
     finally{pending--;announce();}
    });
    // A failed earlier operation skips remaining writes; still settle their counters.
    queue=operation;return operation;
   },
   async retry(){
    await queue;
    try{const result=await request('/api/family');token=result.token;if(result.revision!==revision)throw Error('The project has newer changes. Export this page’s pending work, then reload to load the project version.');failed=false;pending=0;warning='';return await api.save();}
    catch(e){warning=e.message;announce();return false;}
   },
   flush(){return queue;},
   enable(){return api.save();},
   add(name){name=name.trim().slice(0,24);if(!name)throw Error('Choose a nickname.');if(data.profiles.length>=6)throw Error('Up to six explorers fit in this family.');const p={id:'p'+Date.now().toString(36)+Math.random().toString(36).slice(2,6),name,character:'lumo',progress:{},discoveries:[],creations:[],draft:''};data.profiles.push(p);data.active=p.id;api.save();return p;},
   select(id){if(!data.profiles.some(p=>p.id===id))throw Error('Unknown explorer');data.active=id;api.save();},
   remove(id){data.profiles=data.profiles.filter(p=>p.id!==id);if(!data.profiles.length)data.profiles=root.LummingFamilyStore.fresh().profiles;if(!data.profiles.some(p=>p.id===data.active))data.active=data.profiles[0].id;api.save();},
   async reset(){await queue;const previous=data;data=root.LummingFamilyStore.fresh();data.saving=true;if(await api.save())return true;data=previous;return false;},
   async export(){await queue;const auth=await request('/api/family');token=auth.token;return (await request('/api/family/export',{data:clone(data)})).path;}
  };
  return api;
 }
 const api={create};if(typeof module!=='undefined')module.exports=api;else root.LummingProjectStore=api;
})(typeof globalThis!=='undefined'?globalThis:this);
