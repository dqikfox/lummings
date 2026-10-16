(function(root){
 'use strict';
 const KEY='lummings.family.v1';
 const fresh=()=>({version:1,active:'guest',profiles:[{id:'guest',name:'Explorer',character:'lumo',progress:{},discoveries:[],creations:[]}],settings:{large:false,calm:false,session:20},saving:false});
 function create(storage){
  let data=fresh(),warning='';
  try{const raw=storage.getItem(KEY);if(raw){const parsed=JSON.parse(raw);if(parsed.version!==1||!Array.isArray(parsed.profiles)||!parsed.profiles.length||!parsed.profiles.every(p=>typeof p.id==='string'&&typeof p.name==='string'&&p.progress&&Array.isArray(p.discoveries)&&Array.isArray(p.creations))||!parsed.settings)throw Error('Invalid saved data');data=parsed;if(!data.profiles.some(p=>p.id===data.active))data.active=data.profiles[0].id;}}
  catch(e){warning='Saved data could not be loaded. This visit is temporary; existing browser data has not been overwritten.';}
  const api={get data(){return data;},get warning(){return warning;},get profile(){return data.profiles.find(p=>p.id===data.active);},save(){if(!data.saving)return true;try{storage.setItem(KEY,JSON.stringify(data));warning='';return true;}catch(e){warning='This browser could not save changes. Keep this page open or export your data.';return false;}},enable(){data.saving=true;return api.save();},add(name){name=name.trim().slice(0,24);if(!name)throw Error('Choose a nickname.');if(data.profiles.length>=6)throw Error('Up to six explorers fit in this family.');const p={id:'p'+Date.now().toString(36)+Math.random().toString(36).slice(2,6),name,character:'lumo',progress:{},discoveries:[],creations:[]};data.profiles.push(p);data.active=p.id;api.save();return p;},select(id){if(!data.profiles.some(p=>p.id===id))throw Error('Unknown explorer');data.active=id;api.save();},remove(id){data.profiles=data.profiles.filter(p=>p.id!==id);if(!data.profiles.length)data.profiles=fresh().profiles;if(!data.profiles.some(p=>p.id===data.active))data.active=data.profiles[0].id;api.save();},reset(){try{storage.removeItem(KEY);}catch(e){warning='Browser storage could not be cleared. Use browser site settings to remove it.';return false;}data=fresh();warning='';return true;}};
  return api;
 }
 const api={create,fresh,KEY};if(typeof module!=='undefined')module.exports=api;else root.LummingFamilyStore=api;
})(typeof globalThis!=='undefined'?globalThis:this);
