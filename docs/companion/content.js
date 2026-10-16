(function(root) {
  'use strict';
  const characters = [
    {id:'lumo',name:'Lumo',light:'Questlight',color:'#ed4054',portrait:'../lead-magnet/assets/lumo-portrait.png',description:'Your ruby-red co-op captain. Big questions become little quests.'},
    {id:'luna',name:'Luna',light:'Dreamlight',color:'#b59aff',portrait:'../lead-magnet/assets/lila-portrait.png',description:'A gentle spooky poet who finds a story in the ordinary.'},
    {id:'sprout',name:'Sprout',light:'Traillight',color:'#57db91',portrait:'../lead-magnet/assets/pip-portrait.png',description:'A curious scout with a new route for every puzzle.'},
    {id:'nori',name:'Nori',light:'Tidelight',color:'#9edbff',portrait:'../lead-magnet/assets/nori-portrait.png',description:'Quiet wonder, thoughtful questions, and room to pause.'},
    {id:'moki',name:'Moki',light:'Sparklight',color:'#ffa2cc',portrait:'../lead-magnet/assets/moki-portrait.png',description:'Playful ideas and kind jokes. Mistakes welcome.'}
  ];
  const aliases = {lila:'luna',pip:'sprout'};
  const story = {id:'constellation-gate',version:1,characterId:'lumo',title:'The Constellation Gate',start:'arrival',nodes:{
    arrival:{type:'narration',title:'A very dramatic door',text:'Lumo swept his ruby-red quiff away from his eyes. His Questlight scattered gold stars over a locked gate. “Captain’s log: extremely dramatic door. Suspiciously ordinary maths.”',next:'puzzle'},
    puzzle:{type:'choice',title:'Choose our first move',text:'Four constellations hung above the gate. Each held six stars. “Twenty?” Lumo guessed. Nothing happened. “I rushed. Your turn to choose our strategy.”',hint:'Imagine four separate groups. You can draw them, count aloud, or just listen.',choices:[{id:'count',label:'Count in sixes',next:'count'},{id:'split',label:'Split six into five and one',next:'split'},{id:'draw',label:'Imagine or draw four groups',next:'draw'}],skipNext:'explain'},
    count:{type:'narration',title:'One group at a time',text:'“Six… twelve… eighteen… twenty-four.” Lumo lit one constellation with each number. “Four groups. Four steps. We checked every star.”',next:'explain'},
    split:{type:'narration',title:'Two smaller quests',text:'“Four groups of five make twenty,” Lumo said. “Each group has one more star. Four extra ones make four. Twenty plus four makes twenty-four!”',next:'explain'},
    draw:{type:'narration',title:'Make the stars visible',text:'Imagine or draw four circles, with six dots in each. Count the dots if you want. “A picture can help us see what the numbers mean,” Lumo said. There is no need to share your drawing.',next:'explain'},
    explain:{type:'narration',title:'Different routes, same stars',text:'There are 24 stars: four equal groups of six. The gate opened onto a room of floating books. “You checked my guess,” Lumo said. “That’s co-op leadership.”',next:'practice'},
    practice:{type:'choice',title:'An optional little quest',text:'On a desk were three groups of four crystal keys. How many keys altogether? Choose an answer, use a drawing, or skip to the explanation.',hint:'Count four, then add four, then add four again.',choices:[{id:'seven',label:'7 keys',next:'seven'},{id:'twelve',label:'12 keys',next:'twelve'},{id:'sixteen',label:'16 keys',next:'sixteen'}],skipNext:'keys'},
    seven:{type:'narration',title:'Let’s check the groups',text:'Seven is three plus four. Here, three tells us how many groups there are, and each group has four keys. Try counting: four, eight, twelve. Noticing the difference is useful.',next:'reflection'},
    twelve:{type:'narration',title:'A strategy that fits',text:'Yes: four, eight, twelve. Three groups of four make 12. “You used the groups,” Lumo said. “Want to show me your route with words or a picture? You can also keep it to yourself.”',next:'reflection'},
    sixteen:{type:'narration',title:'One group too many',text:'Sixteen would be four groups of four. We have three groups: four, eight, twelve. “Excellent moment to count the groups again,” Lumo said. “Changing our answer is part of learning.”',next:'reflection'},
    keys:{type:'narration',title:'The key explanation',text:'Three groups of four make 12: four plus four plus four. You can draw the groups or come back to this idea another time.',next:'reflection'},
    reflection:{type:'reflection',title:'What shall we carry?',text:'Which helped you: counting, splitting, drawing, or listening? Tell someone, point, or imagine your answer. There is no correct preference, and you don’t have to answer.',next:'closing',skipNext:'closing'},
    closing:{type:'closing',title:'Quest complete. Crew first.',text:'“A discovery, another question, or a quiet goodbye?” Lumo asked. Every choice was welcome. If schoolwork still feels confusing, ask a teacher or trusted adult to try another explanation with you.'}
  }};
  const api={characters,aliases,story};
  if(typeof module!=='undefined')module.exports=api;else root.LummingContent=api;
})(typeof globalThis!=='undefined'?globalThis:this);
